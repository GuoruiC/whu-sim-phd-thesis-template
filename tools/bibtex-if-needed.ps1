param([Parameter(Mandatory=$true)][string]$Document)

$ErrorActionPreference = 'Stop'
$auxPath = $Document + '.aux'
$aux = Get-Content -LiteralPath $auxPath -Raw
if ($aux -notmatch '\\bibdata\{') {
    Write-Host 'No bibliography citations; skipping BibTeX.'
    exit 0
}
Push-Location -LiteralPath (Split-Path (Resolve-Path -LiteralPath $auxPath).Path -Parent)
try {
    & bibtex ([IO.Path]::GetFileNameWithoutExtension($auxPath))
    $bibtexExitCode = $LASTEXITCODE
} finally {
    Pop-Location
}
exit $bibtexExitCode
