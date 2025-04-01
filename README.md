# LaTeX - Toolkit

This is a Lua script which can be used to manage and standardize the file structure of your LaTeX projects on the command line.

### Example Output

![help options](images/help_output.png)

# Dependencies
- [argparse](https://luarocks.org/modules/argparse/argparse) command line arguments parsing and other cool stuff.
- [LuaLogging](https://lunarmodules.github.io/lualogging/) API for logging in Lua.

### Installing with LuaRocks

```bash
# to install luarocks
sudo apt install luarocks 

luarocks install argparse lualogging
# or 
luarocks install --local argparse lualogging
```

# Installation

```bash
git clone https://github.com/grwells/latex-toolkit.git &&
./install.sh
```

Afterward, verify installation with:

```
$ ltk -h
# or
$ latextk -h
```

# Future Feature Ideas
1. Config file to pass startup commands to vim/neovim after startup. See [commands](https://neovim.io/doc/user/starting.html) documentation for passing commands to neovim from command line. Ex. `nvim "+set cc=80" <filename>`.

2. Project export as an archive/zipped archive. This would reduce file size, make more transportable with git directories, _etc._

3. Option/Command/Argument Completion. It would be nice to have command completion via tabs in commmand line. Currently broken, not sure why.

