# 武汉大学信息管理学院博士学位论文 LaTeX 参考模板

本模板面向武汉大学信息管理学院博士学位论文写作，基于 [whutug/whu-thesis](https://github.com/whutug/whu-thesis) 为基础，依据学院发布的论文印制规格附件改编。它是个人维护的非官方参考模板，未获得学校或学院的审核授权。

## 格式来源

依据为信息管理学院发布的[《信息管理学院2026年上半年博士学位论文答辩工作流程及安排》](https://sim.whu.edu.cn/info/1775/111542.htm)（2026-04-01）及其**附件3《武汉大学2016年博士学位论文撰写及印制规格的规定》**。本模板对照该附件中的印制规格及附页示例制作。附件名称中的 2016 年与通知发布日期 2026 年应分别理解。

本模板以该附件为格式依据。正式提交时仍须核对所在学科、当年通知和学院要求；模板编译通过不等于论文内容或格式已经获得学院认可。

## 模板内容

正式版顺序：中文封面、英文题目页、原创性声明、授权协议书、论文创新点、目录、中文摘要、英文摘要、绪论及正文、参考文献、攻博期间科研成果、致谢。

**目录在摘要之前**，遵循附件“装订格式的排列顺序”；目录条目仍按附页四列出中文摘要 I、英文摘要 II。目录不计入摘要页码，也不显示页眉；摘要起使用页眉。摘要采用大写罗马数字，绪论从阿拉伯数字 1 开始并保证落在物理右页。前置部分页数改变时，模板会在需要的位置插入空白页。

正文为宋体小四，基本行距 20 磅，四周边距均至少 25 mm；二级标题前后留空行。英文采用 Times New Roman。参考文献标题为黑体四号加粗，条目为宋体五号。引文按附件采用 GB/T 7714—2005，默认使用推荐的著者—出版年制，也支持顺序编码制。封面含分类号、UDC、密级及学校编号 10486。

## 开始写作

1. 在 `thesis-info.tex` 中填写题目、姓名、导师、学科专业、研究方向、学号、年月和 3—5 个中英文关键词。
2. 在 `pages/innovation.tex`、`pages/abstract.tex`、`pages/enabstract.tex` 中填写创新点和摘要。
3. 编辑 `pages/chapter*.tex`，在 `main.tex` 中添加或调整章节。
4. 在 `ref/references.bib` 中维护参考文献，在 `pages/achievement.tex` 中填写攻博成果。
5. 在本文件夹运行：

```bash
latexmk -xelatex main.tex
```

输出为 `main.pdf`。不用 latexmk 时，先运行 `xelatex main`；正文有引用或使用了 `\nocite` 时，再运行 `bibtex main`、`xelatex main`、`xelatex main`。

没有文献条目，或 `.bib` 中有条目但正文尚未引用时，模板自动跳过参考文献输出及 BibTeX，仍可正常编译。加入 `\cite`、`\citet`、`\citep`、`\parencite` 等引用后自动恢复；需要列出未引用的条目时，在 `\printbibliography` 前使用 `\nocite{文献键}` 或 `\nocite{*}`。真实的文献语法错误和缺失引用键仍会报告。

暂时禁用 `.bib` 条目应使用 `@comment{ ... }` 包住完整条目，不要用 `%` 逐行注释含 `@book`、`@article` 的条目。

当前示例仅含占位文字、一个占位图框和两条真实书籍参考文献；不会预填研究结论或个人科研成果。默认学院为信息管理学院，专业名称需按自己的培养信息填写。


### VS Code 编译

项目自带 `.vscode/settings.json`。在 VS Code 中打开本目录，使用 LaTeX Workshop 编译 `main.tex`；默认配方为 `latexmk (XeLaTeX)`。原来的 `xelatex -> bibtex -> xelatex*2` 配方也可使用，其中 BibTeX 步骤会通过 `tools/bibtex-if-needed.ps1` 在没有引用时自动跳过；有引用时照常运行 BibTeX。该四步配方的条件脚本适用于 Windows PowerShell。

模板的回归检查可运行 `powershell -NoProfile -ExecutionPolicy Bypass -File tests/bibliography-smoke.ps1`，覆盖空文献库、未引用条目、正常引用、移除引用后的旧缓存及 `\nocite{*}`。

英文封面除题目和作者外，还显示导师（`Supervised by`）、英文学院名、Wuhan University 及年月，自动读取 `thesis-info.tex` 中的对应字段。导师职称 `Professor` 显示为 `Prof.`。这些附加信息是模板的排版补充；英文题目二号、作者四号仍按附件要求设置。中文论文题目采用正常字距；封面信息采用三列表格，标签与填写内容按 Word 附页分散对齐，导师姓名和职称位于同一单元格。

## 字体与在线编译

默认使用 Windows 中的宋体、黑体、楷体、仿宋和 Times New Roman，采用 XeLaTeX。字体不随项目分发。在 Overleaf 等没有这些字体的平台，可临时将 `cjk-font=windows` 改为 `fandol`、`font=times` 改为 `termes`；替代字体会改变字形及行宽，正式版仍需核对对应字体。数学字体保留 TeX Gyre Termes Math。

## 盲审版

学院 2026 年通知要求送审全文不出现作者和导师姓名，并去掉致谢。模板提供单独入口：

```bash
latexmk -xelatex main-blind.tex
```

输出为 `main-blind.pdf`。它隐藏包含个人信息的封面、英文题目页、声明和授权页，清空模板中的姓名、导师和学号字段，并省略致谢；保留创新点、目录、摘要、正文、参考文献和成果目录。

这个入口不会自动改写正文、图件或成果条目，必须人工检查其中的身份信息、自述、签名以及 PDF 文件属性。通知要求论文 PDF 不超过 20 MB，文件名按 `10486_学号_LW.pdf` 保存；这些提交规则以当次学院通知为准，不固定写入模板输出名。

## 书脊与印刷

单独修改 `spine.tex` 的题目和作者，使它们与 `thesis-info.tex` 一致，再运行 `latexmk -xelatex spine.tex`。书脊文字条使用仿宋四号，上方题目、下方作者；实际书脊宽度由装订厚度决定。正式纸本正文双面印制，封面白色 120 克铜版纸。

## 文件说明

| 文件 | 用途 |
| --- | --- |
| `main.tex` / `main-blind.tex` | 正式版 / 盲审版入口 |
| `thesis-info.tex` | 信息、字体、引用方式 |
| `whu-local.sty` | 信息管理学院附件要求的本地修改 |
| `whu-thesis.cls` | 原样保留的上游核心类 |
| `pages/` / `ref/` | 页面内容 / 参考文献数据库 |
| `spine.tex` | 单独编译的书脊文字条 |
| `格式核对说明.md` / `编译验证.md` | 格式依据与实际验证范围 |
| `UPSTREAM.md` / `LICENSE` | 上游版本及许可 |

修改引用方式时，将 `bib-style=author-year` 改为 `numerical` 并重新完整编译。混合语种条目、拼音排序和所有文献类型仍需对照附件检查；示例不能覆盖全部著录情况。

上游代码遵循 LPPL 1.3c 许可，核心类及 BST 保留原维护者信息。封面校名字图来自学院规范附件，仅用于论文封面排版，不代表校方授权使用标识。源文件不打包商业字体。
