# Notes

This file is a compilation of notes and technical bits learned during this project.

# Neovim Pass Settings Via Commandline

```bash
nvim "+set <param>=<value>" <file-name-here>
# to set multiple params in one line...
nvim "+set <param0>=<value> | <param1>=<value> | ..." <file-name-here>
```



# Neovim Auto Line Wrap

> [!NOTE]
> From [here](https://stackoverflow.com/questions/36950231/auto-wrap-lines-in-vim-without-inserting-newlines)
### Automatically soft-wrap text (only visually) at the edge of the window:

```vim
set number # (optional - will help to visually verify that it's working)
set textwidth=0
set wrapmargin=0
set wrap
set linebreak # (optional - breaks by word rather than character)
```

### Automatically hard-wrap text (by inserting a new line into the actual text file) at 80 columns:
```vim
set number # (optional - will help to visually verify that it's working)
set textwidth=80
set wrapmargin=0
set formatoptions+=t
set linebreak # (optional - breaks by word rather than character)
```
### Automatically soft-wrap text (only visually) at 80 columns:
```vim
set number # (optional - will help to visually verify that it's working)
set textwidth=0
set wrapmargin=0
set wrap
set linebreak # (optional - breaks by word rather than character)
set columns=80 # <<< THIS IS THE IMPORTANT PART
```
