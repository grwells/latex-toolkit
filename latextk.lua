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
--   |        main.tex
--   |        <?> beamer/latex theme files
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
--   |
--   |
--   *--> backup/ 
--]]

--[[
-- FLAGS
--      These are flags for compile time arguments, the default unset value is nil, otherwise expect boolean.
--]]
enable_shell_escape = nil
include_beamer_theme = nil
project_path = nil
--[[
-- Helper Functions
--      These functions provide modular operations that are fundamental for different arguments 
--]]
function make_directory_structure(base)
	-- make directory structure, substituting in base as project name
	mkdir_cmd_str = string.format(
		"mkdir -p ./%s/src ./%s/include/images ./%s/include/diagrams ./%s/bibliography ./%s/backup",
		base,
		base,
		base,
		base,
		base
	)
	os.execute(mkdir_cmd_str)
	-- create main latex file
	os.execute(string.format("touch ./%s/src/main.tex", base))
end

function add_beamer_theme(theme_path)
	-- copy a beamer theme to the project source folder
	--  a) copy single file
	--  b) copy set of files in directory including something like
	--      * beamertheme<themename>.sty
	--      * title-background/default-background.jpg
	--      * logos/default-logo<option number>

	if project_path == nil then
		-- set project path if not known
		project_path = infer_project_name()
	end

	dest_path = project_path .. "/src"

	if string.find(theme_path, ".sty") == nil then
		-- if path doesn't contain .sty,
		copy_directory_contents(theme_path, dest_path)
	else
		-- if path ends in `.sty` -> file
		copy_file(theme_path, dest_path)
	end
end

function copy_directory_contents(src_dir_path, dest_dir_path)
	-- copy all files (recursive) from source directory to destination directory
	cmd_str = string.format("cp -r %s/* %s", src_dir_path, dest_dir_path)
	os.execute(cmd_str)
end

function copy_file(src_file_path, dest_path)
	-- copy one file at source path to directory in destination path
	os.execute(string.format("cp %s %s"), src_file_path, dest_path)
end

function clone_latex_toolkit()
	-- clone toolkit from github
	os.execute([[git clone https://github.com/grwells/latex-toolkit.git ./scripts]])
end

function file_exists(name)
	-- check if file path exists, return bool
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

function split_str(input_str, sep)
	if sep == nil then
		sep = "%s"
	end

	local t = {}
	for str in string.gmatch(input_str, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

function increment_version_str(current_ver, increment_type)
	-- increment the version string patch/minor/major and return new version string
	local versions = split_str(string.sub(current_ver, 2), ".")
	local major_ver = tonumber(versions[1])
	local minor_ver = tonumber(versions[2])
	local patch_ver = tonumber(versions[3])

	print(string.format("[DEBUG] current version: v%i.%i.%i", major_ver, minor_ver, patch_ver))

	if increment_type == "p" then
		-- increment patch
		patch_ver = patch_ver + 1
		print(string.format("[DEBUG] increment patch %i -> %i", patch_ver - 1, patch_ver))
	elseif increment_type == "ma" then
		-- increment major
		major_ver = major_ver + 1
		minor_ver = 0
		patch_ver = 0
		print(string.format("[DEBUG] increment major %i -> %i", major_ver - 1, major_ver))
	else
		-- increment minor
		minor_ver = minor_ver + 1
		patch_ver = 0
		print(string.format("[DEBUG] increment minor", minor_ver - 1, minor_ver))
	end

	return string.format("v%i.%i.%i", major_ver, minor_ver, patch_ver)
end

local argparse = require("argparse")

-- [[
-- Define arguments and flags for this program to be printed by argparse.
-- ]]
local parser = argparse():name("LaTeX - Toolkit"):add_complete():description([[
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
	:flag("--add-theme")
	:description("copy theme file(s) to project src folder from path")
	:args("1+")
	:action(function(args, index, arg_array, overwrite_flag)
		io.write("\n[DEBUG] LTK importing theme files from: ", arg_array[1])

		add_beamer_theme(arg_array[1])

		--print("\nadd theme args contents:\n\t", table.concat(args), index, arg_array, overwrite_flag)
		--print("first & second in array", arg_array[0], arg_array[1], arg_array[2])
		--print("args.add_theme = ", args.add_theme);
	end)

parser
	:flag("-b --build-bibliography")
	:description(
		"compiles with biber to include citation/bibliography, requires pdflatex/latex be run after to generate output"
	)
	:action(function(args)
		io.write("\n[DEBUG] building for bibtex")
		os.execute([[cd ./src/ && biber main]])
	end)

parser:flag("-c --word-count"):description("print word count summary by section"):action(function(args)
	os.execute([[texcount ./src/main.tex]])
end)

parser
	:flag("--clean")
	:description("backup main.tex, remove all build files in src starting with main.*, and restore main.tex")
	:action(function(args)
		-- backup main.tex
		local success = false
		success = os.execute("cp ./src/main.tex ./backup")

		print("success? ", success)

		if not success then
			-- check if backup of source file succeeded
			print("[ERROR] ltk couldn't backup main.tex, canceling operation")
		else
			-- remove all files generated by build, main.*
			os.execute("rm ./src/main.*")
			-- restore main.tex, leave backup
			os.execute("cp ./backup/main.tex ./src/")
		end
	end)

parser
	:flag("-e --escape-shell")
	:description(
		"set the -shell-escape flag for pdflatex, this is required for packages such as minted, tikz, etc. to run external tools"
	)
	:action(function(args)
		io.write("\n[DEBUG] LTK setting enabling external tools with -shell-escape option")
		enable_shell_escape = true
	end)

parser
	:flag("--export")
	:description(
		"export the current version of the document, src/main.pdf, to ./<project_name>_<version_str>_<date>.pdf"
	)
	:action(function(args)
		-- get document version string
		-- most recent tag `git describe --tags --abbrev=0 # 0.1.0-dev
		-- most recent annotated tag `git describe --abbrev=0`
		local fp = io.popen("git describe --tags --abbrev=0", "r")
		local ver = fp:read("*a")
		ver = string.sub(ver, 1, -2) -- remove newline character
		-- print(string.format("output = '%s'", base))

		-- get date string
		local date_str = os.date("%m-%d-%Y")

		-- write document to output file in project root
		local fn_str = string.format("%s_%s_%s.pdf", infer_project_name({ silent = true }), ver, date_str)
		print("[DEBUG] exporting file -> ./" .. fn_str)

		os.execute(string.format("cp src/main.pdf ./%s", fn_str))
	end)

parser
	:flag("-g --generate-pdf")
	:description("compile and generate a pdf of the latex document in ./src/ using pdflatex main.tex")
	:action(function(args)
		if enable_shell_escape == nil then
			-- enable_shell_escape is undeclared
			-- compile without shell escape (default)
			io.write("\n[DEBUG] shell escape nil")
			os.execute([[cd ./src/ && pdflatex main.tex]])
		elseif enable_shell_escape == true then
			-- enable shell escape
			io.write("\n[DEBUG] shell escape true")
			os.execute([[cd ./src/ && pdflatex --shell-escape main.tex]])
		elseif enable_shell_escape == false then
			-- absolutely disable all shell escape dependent behavior
			-- WARNING: will disable packages such as bibtex
			io.write("\n[DEBUG] shell escape false")
			os.execute([[cd ./src/ && pdflatex --no-shell-escape main.tex]])
		end
	end)

parser
	:flag("--init-git")
	:description("initialize a local git repository in the project root for version management")
	:action(function(args)
		-- initialize repository
		os.execute([[git init]])
		-- add all files in root and subdirectories of project
		os.execute([[git add *]])
		-- initial commit
		os.execute([[git commit -m "initial commit"]])
		-- tag this as initial version, v0.0.0
		os.execute([[git tag v0.0.0]])
	end)

parser
	:flag("--inc-version")
	:description(
		"create a new version of the project, i.e. create a commit, increment the version and add tag, fails on tag conflict"
	)
	:args("?")
	:action(function(args, _, fn)
		-- note, will fail for tag conflicts
		-- add all files in root and subdirectories of project
		os.execute([[git add *]])
		-- initial commit, don't supply message so user can add
		os.execute([[git commit]])
		-- get the latest tag
		-- most recent tag `git describe --tags --abbrev=0 # 0.1.0-dev
		-- most recent annotated tag `git describe --abbrev=0`
		local fp = io.popen("git describe --tags --abbrev=0", "r")
		local ver = fp:read("*a")
		ver = string.sub(ver, 1, -2) -- remove newline character

		-- increment major/minor/patch based on argument to function
		local ver_inc_type = fn[1]
		local new_ver = increment_version_str(ver, ver_inc_type)

		print("[DEBUG] new version string:", new_ver)
		-- tag this as new version
		os.execute("git tag " .. new_ver)
	end)

parser:flag("-p --print-pdf"):description("print generated pdf on default printer"):action(function(args)
	os.execute([[lpr ./src/main.pdf]])
end)

parser
	:flag("-o --open-document")
	:description("open the LaTeX document in ./src/ in NeoVim for editing")
	:action(function(args)
		--os.execute([[nvim +TZAtaraxis ./src/main.tex]])
		os.execute([[nvim ./src/main.tex]])
	end)

parser
	:flag("-v --view")
	:description("open generated pdf in default system pdf viewer without compiling")
	:action(function(args)
		os.execute([[xdg-open ./src/main.pdf]])
	end)

parser:flag("-t --tree-view"):description("list directory structure and files in tree format"):action(function(args)
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
		project_path = fn[1]
		io.write(project_str)
		make_directory_structure(fn[1])
		-- print the file tree for the new directory
		cd_dir_str = string.format("cd ./%s", fn[1])
		cd_dir_str = cd_dir_str .. [[ && find . | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"]]
		os.execute(cd_dir_str)
	end)

local args = parser:parse()
