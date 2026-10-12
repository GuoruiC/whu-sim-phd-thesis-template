param(
    [string]$ProjectPath = (Split-Path $PSScriptRoot -Parent),
    [ValidateSet('manual', 'latexmk')][string]$Recipe = 'manual'
)

$ErrorActionPreference = 'Stop'
$ProjectPath = (Resolve-Path -LiteralPath $ProjectPath).Path
$testRoot = Join-Path (Split-Path $ProjectPath -Parent) ('tmp\whu-bib-' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $testRoot | Out-Null
foreach ($name in @('whu-thesis.cls', 'whu-local.sty', 'thesis-info.tex', '.latexmkrc', 'gbt7714-2005-author-year.bst')) {
    Copy-Item -LiteralPath (Join-Path $ProjectPath $name) -Destination $testRoot
}
Copy-Item -LiteralPath (Join-Path $ProjectPath 'tools') -Destination $testRoot -Recurse
$settings = Get-Content -LiteralPath (Join-Path $ProjectPath '.vscode\settings.json') -Raw | ConvertFrom-Json
$recipeIndex = if ($Recipe -eq 'manual') { 1 } else { 0 }
$toolNames = $settings.'latex-workshop.latex.recipes'[$recipeIndex].tools
$document = @'
\documentclass[type=doctor,class=academic]{whu-thesis}
\input{thesis-info.tex}
\whusetup{style={bib-resource={references.bib}}}
\usepackage{whu-local}
\ExplSyntaxOn
\cs_set_protected:Npn \__whu_doctor_frontmatter_output: {__FRONT__}
\ExplSyntaxOff
\begin{document}
\mainmatter
\chapter{Bibliography check}
__CONTENT__
\printbibliography
\end{document}
'@
$entry = @'
@book{lamport1994,
  author = {Lamport, Leslie},
  title = {{LaTeX}: A Document Preparation System},
  publisher = {Addison-Wesley},
  year = {1994}
}
'@
# Reuse the same output name to check removal of citations and stale .bbl files.
$cases = @(
    @{Name='empty'; Bib=''; Content='No references yet.'; Expected=$false},
    @{Name='uncited'; Bib=$entry; Content='No citations yet.'; Expected=$false},
    @{Name='cited'; Bib=$entry; Content='\citet{lamport1994}; \citep{lamport1994}; \parencite{lamport1994}.'; Expected=$true},
    @{Name='removed'; Bib=$entry; Content='Citations removed.'; Expected=$false},
    @{Name='nocite'; Bib=$entry; Content='\nocite{*}'; Expected=$true},
    @{Name='frontmatter'; Bib=$entry; Front='\citet{lamport1994}'; Content='Citation in front matter.'; Expected=$true}
)
Push-Location -LiteralPath $testRoot
try {
    foreach ($case in $cases) {
        [IO.File]::WriteAllText((Join-Path $testRoot 'main.tex'), $document.Replace('__CONTENT__', $case.Content).Replace('__FRONT__', [string]$case.Front))
        [IO.File]::WriteAllText((Join-Path $testRoot 'references.bib'), $case.Bib)
        foreach ($toolName in $toolNames) {
            $tool = $settings.'latex-workshop.latex.tools' | Where-Object name -eq $toolName
            $toolArgs = @($tool.args | ForEach-Object { $_.Replace('%DIR%', $testRoot).Replace('%DOC%', (Join-Path $testRoot 'main')) })
            $output = & $tool.command @toolArgs 2>&1
            $compileExitCode = $LASTEXITCODE
            $output | Out-File -LiteralPath ($case.Name + '-' + $toolName + '-compile.log') -Encoding utf8 -Append
            if ($compileExitCode -ne 0) {
                $output | Select-Object -Last 25 | Write-Host
                throw "$($case.Name) / $toolName failed. Logs: $testRoot"
            }
        }
        $aux = Get-Content -LiteralPath 'main.aux' -Raw
        $log = Get-Content -LiteralPath 'main.log' -Raw
        if (($aux.Contains('\bibdata{')) -ne $case.Expected) { throw "$($case.Name): unexpected bibliography activation" }
        if ($log -match 'undefined citations|Citation .+ undefined|Empty .thebibliography') { throw "$($case.Name): unresolved or empty bibliography" }
        if (-not (Test-Path -LiteralPath 'main.pdf')) { throw "$($case.Name): PDF missing" }
        if ($case.Expected -and ((Get-Content -LiteralPath 'main.bbl' -Raw) -notmatch '\\bibitem')) { throw "$($case.Name): bibliography entries missing" }
        Write-Host "PASS $($case.Name)"
    }
} finally {
    Pop-Location
}
Write-Host "Logs: $testRoot"
