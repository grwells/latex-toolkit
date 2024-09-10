#!/usr/bin/lua
--[[
--  Author: Garrett Wells 
--  Date:   08/16/2023
--  This script defines a toolkit api for LaTeX projects.
--
--  The directory structure will be structured as follows:
--
--   ./
--   |
--   |
--   *--> src/
--   |        makefile
--   |        <latex source files>.tex
--   |
--   |
--   *--> include/
--   |           |
--   |           *--> diagrams/
--   |           |
--   |           *--> images/
--   |                      |
--   |                      *-->title-background/
--   |
--   |
--   *--> bibliography/
--   |                 <bib_file>.bib
--   |
--   *--> scripts/
--]]

-- FLAGS
-- these are flags for operation, the default unset value is nil, otherwise expect boolean
enable_shell_escape = nil

function make_directory_structure(base)
	-- make directory structure, substituting in base as project name
	mkdir_cmd_str = string.format(
		"mkdir -p ./%s/src ./%s/include/images ./%s/include/diagrams ./%s/bibliography",
		base,
		base,
		base,
		base
	)
	os.execute(mkdir_cmd_str)
	-- create main latex file
	os.execute(string.format("touch ./%s/src/main.tex", base))
end

function clone_latex_toolkit()
	-- clone toolkit from github
	os.execute([[git clone https://github.com/grwells/latex-toolkit.git ./scripts]])
end

function file_exists(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

function create_new_project(base)
	-- create a new LaTeX project directory
	txt = string.format("Project Name: %s ", base)
	cap = string.rep("*", string.len(txt) + 2)
	io.write(cap, "\n", txt, " *\n", cap, "\n")
	make_directory_structure(base)
	-- clone_latex_toolkit()
end

function infer_project_name(t)
	-- default function params
	-- all calls to this function must be of form infer_project_name{...}
	setmetatable(t, { __index = { silent = true } })

	local fp = io.popen("basename $PWD", "r")
	local base = fp:read("*a")
	base = string.sub(base, 1, -2) -- remove newline character
	fp:close()

	txt = string.format("Project Name: %s", base)
	cap = string.rep("*", string.len(txt) + 2)

	if not silent then
		io.write(cap, "\n", txt, " *\n", cap, "\n")
	end

	return base
end

local argparse = require("argparse")

-- [[
-- Define arguments and flags for this program to be printed by argparse.
-- ]]
local parser = argparse():name("LaTeX - Toolkit"):description([[
██╗      █████╗ ████████╗███████╗██╗  ██╗              ████████╗██╗  ██╗
██║     ██╔══██╗╚══██╔══╝██╔════╝╚██╗██╔╝              ╚══██╔══╝██║ ██╔╝
██║     ███████║   ██║   █████╗   ╚███╔╝     █████╗       ██║   █████╔╝ 
██║     ██╔══██║   ██║   ██╔══╝   ██╔██╗     ╚════╝       ██║   ██╔═██╗ 
███████╗██║  ██║   ██║   ███████╗██╔╝ ██╗                 ██║   ██║  ██╗
╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝                 ╚═╝   ╚═╝  ╚═╝
                                                                        

A script for autogenerating, evaluating, and managing any LaTeX project. 

Simple Usage -> ltk -b -g -v
1. compiles bibliography with biber
2. compiles/generates pdf
3. opens pdf in system pdf viewer
]])

parser
	:flag("-b --build-bibliography")
	:description("compiles with biber to include citation/bibliography, requires pdflatex/latex be run after to generate output")
	:action(function(args)
		io.write("[DEBUG] building for bibtex")
		os.execute([[cd ./src/ && biber main]])
	end)

parser:flag("-c --word-count"):description("print word count summary by section"):action(function(args)
	os.execute([[texcount ./src/main.tex]])
end)

parser
	:flag("-e --escape-shell")
	:description("set the -shell-escape flag for pdflatex, this is required for packages such as minted, tikz, etc. to run external tools")
	:action(function(args)
		io.write("[DEBUG] LTK setting enabling external tools with -shell-escape option")
        enable_shell_escape = true
	end)

parser
	:flag("-g --generate-pdf")
	:description("compile and generate a pdf of the latex document in ./src/ using pdflatex main.tex")
	:action(function(args)

        if enable_shell_escape == nil then
            -- enable_shell_escape is undeclared
            -- compile without shell escape (default)
            io.write("[DEBUG] shell escape nil")
            os.execute([[cd ./src/ && pdflatex main.tex]])
        elseif enable_shell_escape == true then
            -- enable shell escape
            io.write("[DEBUG] shell escape true")
            os.execute([[cd ./src/ && pdflatex --shell-escape main.tex]])
        elseif enable_shell_escape == false then
            -- absolutely disable all shell escape dependent behavior
            -- WARNING: will disable packages such as bibtex
            io.write("[DEBUG] shell escape false")
            os.execute([[cd ./src/ && pdflatex --no-shell-escape main.tex]])
        end

	end)

parser:flag("-p --print-pdf"):description("print generated pdf on default printer"):action(function(args)
	os.execute([[lpr ./src/main.pdf]])
end)

parser
	:flag("-o --open-document")
	:description("open the LaTeX document in ./src/ in NeoVim for editing")
	:action(function(args)
		os.execute([[nvim +TZAtaraxis ./src/main.tex]])
	end)

parser
	:flag("-v --view")
	:description("open generated pdf in default system pdf viewer without compiling")
	:action(function(args)
		os.execute([[xdg-open ./src/main.pdf]])
	end)


parser
    :flag("-t --tree-view")
    :description("list directory structure and files in tree format")
    :action(function(args)
        os.execute([[find . | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"]])
    end)

parser
	:option("-n --new-project")
	:description("generate a new project directory and default LaTeX file from scratch")
	:args("?")
	:action(function(args, _, fn)
        project_str = string.format(
        "\n========================================================\n\tNew LaTeX Project: ./%s\n========================================================",
        fn[1]
        )
		io.write(project_str)
		make_directory_structure(fn[1])
        -- print the file tree for the new directory
        cd_dir_str = string.format(
            "cd ./%s" ,
            fn[1]
        )
        cd_dir_str = cd_dir_str .. [[ && find . | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"]]
        os.execute(cd_dir_str)
	end)

local args = parser:parse()
