The following was given to chatGPT to create this package. The code needed a fair amount of editing and re-requesting (which is an interesting process in its own right).

With a single function, and the `usethis::create_package()` function to create the project outline, all that's needed is the `R` code for the function, edits to description/license/readme, and calls to `usethis::use_package("")` and `devtools::check()` and `devtools::build()` to setup basic package. 
This is useful to know because this package is pretty dumb, but it would be very easy to modify it for whatever purposes you might want. 

## Details

`projectR::create_projectR`

Should:

Take as arguments, path, git (T/F), repo (if used, git is automatically T), languages (to add gitignore), renv (T/F), 

It should then:

(1a) Run usethis::create_project(path) to create the project
(1b) OR usethis::create_from_github(path, repo)

(2) add use gitignore::gi_fetch_templates(languages, append_gitignore = T) 
AND gitignore::gi_write_gitignore("*.ini") to add ini files to gitignore in all projects

(3) create a default directory structure:
/data
/R
/output

(4) run if (!require("pacman")) install.packages("pacman")

(5) create a single R function in the /R directory called setup.R and add useful initiation functions there. These could include loading some packages, e.g.:
pacman::p_load(here).

Any other useful functions to support good practice, and to help new users engage with setting up R projects should go here. 

(6) create a README file describing the project setup that has occurred, and giving options for other useful steps that might be taken on project setup (such as connecting to git or/and github). Include a note that pacman::p_load and pacman::p_load_gh can be used to check packages are installed, and if not, install and load them; along with other useful functions.

(7) create a license file, and add a line to README with a useful link to guidance on how to select a license. 

