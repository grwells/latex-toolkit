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
--   |           *--> pictures/
--   |
--   |
--   *--> bibliography/
--   |                 <bib_file>.bib
--   |
--   *--> scripts/
--]]

local argparse = require "argparse"

-- [[
-- Define arguments and flags for this program to be printed by argparse.
-- ]]
local parser = argparse() 
    :name "LaTeX Tool-Kit"
    :description "A script for autogenerating, evaluating, and managing any LaTeX project."

parser:flag "-c --word-count"
    :description "print word count summary by section"

parser:flag "-g --generate-pdf"
    :description "compile and generate a pdf of the latex document in ./src/ using pdflatex command"

parser:flag "-p --print-pdf"
    :description "compile and generate a pdf and print on default printer"

parser:flag "-o --open-document" 
    :description "open the LaTeX document in ./src/ in NeoVim for editing"

parser:flag "-v --view" 
    :description "open generated pdf without compiling"

parser:flag "-w --pdf-view" 
    :description "generate and open the pdf in the default system pdf viewer"

parser:option "-+ --create" 
    :description "generate a new project directory and default LaTeX file from scratch"
    :default "none"
    :args "?"     


local args = parser:parse()

function make_directory_structure (base) 
 -- make directory structure, substituting in base as project name
    mkdir_cmd_str = string.format("mkdir -p ./%s/src ./%s/include/pictures ./%s/include/diagrams ./%s/bibliography", base, base, base, base)
    os.execute(mkdir_cmd_str)
 -- create main latex file
    os.execute(string.format("touch ./%s/src/main.tex", base))
end

function clone_latex_toolkit ()
    -- clone toolkit from github
    os.execute([[git clone https://github.com/grwells/latex-toolkit.git ./scripts]])
end


function create_new_project (base) 
    -- create a new LaTeX project directory
    txt = string.format("Project Name: %s ", base)
    cap = string.rep("*", string.len(txt) + 2)
    io.write(cap, "\n", txt, " *\n", cap, "\n")
    make_directory_structure(base)
    -- clone_latex_toolkit()
end


function infer_project_name (t)
    -- default function params
    -- all calls to this function must be of form infer_project_name{...}
    setmetatable(t, {__index={silent=true}})

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


function handle_args ()

    if args.word_count then
        local proj_name = infer_project_name{}
        os.execute(string.format("texcount ./src/main.tex", proj_name))
    end

    if args.generate_pdf then
        local proj_name = infer_project_name{}
        os.execute(string.format("cd ./src/ && pdflatex main.tex", proj_name))
    end

    if args.create then
        -- do something here
        if args.create[1] == nil then
            -- read project name from input
            p_name = ""
            repeat 
                io.write("enter name for project -> ")
                p_name = io.read()
                io.write("'", p_name, "'", " : is this the name you wish to use?(y/n) -> ")
            until io.read() == "y" 

            create_new_project(p_name)

        else
            create_new_project(args.create[1])
        end
    end
end

handle_args()
