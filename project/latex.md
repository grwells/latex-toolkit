# LaTeX Cheatsheet

Quick reference for LaTeX solutions organized by writing process step/function such as drafts, editing, notes, editing, _etc._

# Editing

> [!note]
> When drafting a new version of a document, it may be preferable to pass the `draft` option to the `\documentclass` command, _i.e._ `\documentclass[draft]`. This has various affects on different packages such as reducing compile time, but generally optimizes for drafting. Switching to `final` will force final document formatting such as hiding comments.


| Function | Solution | Resources |
| :---: | :--- | :--- |
| Remove word | `\sout{<word>` | See `ulem` package. 
| Highlighting | `\hl{<text>}`, _ex._: `\textbf{\textcolor{red}{\hl{foo}}}` | See `soul` and `color` packages.
| Douplespaced Lines | `\linespread{2}` | See `setspace` package.|
| Margin note | `\marginpar{<text>}` or `\reversemargin{<text>}` or `\todo{<text>}` for colored output | See `marginnote` package for margin notes in footnotes. See `todonotes` package for colored notes in margins. | Drafts vs. final versions | `\documentclass[draft]{article} | If using

### Douplespace Lines: `setspace`

```latex
\usepackage{setspace}
\doublespacing
% or:
\onehalfspacing
```
