## Install
`./install` will run a script that checks what OS you're on, and if you have 
all the necessary programs installed. If you dont, it installs them for you!
Once the dependencies are installed, it will run any third party installations,
and create symlinks for the necessary config files in the correct locations.

## Dotfiles
Here's my collection of dotfiles I use on linux/osx environments.
I continuously add to this repo over time, as I customise my dev environment.
Feel free to fork this and modify the scripts/dotfiles to suit your own needs!

ZSH and Oh-My-Zsh must be installed:
- http://ohmyz.sh/

**Git**
Make sure to edit the gitconfig and add your credentials instead of mine

**VIM Installation Tips**
I use neovim and vim-plug. So if you're using regular vim you might want to
remove the neovim specific plugins from my vimrc. Also, you might need to run
:PlugClean to remove the plugin directories then run :PlugInstall to reinstall
them.

### OSX Stuff
Seil: Remap Capslock to esc
- https://pqrs.org/osx/karabiner/seil.html.en

Karabiner: Key repeat 400ms 25ms
- https://pqrs.org/osx/karabiner/seil.html.en
![Karabiner Settings 400ms Delay 25ms Repeat](/img/karabinersettings.png)

#### Aliases
Here are the aliases I use in my shell to utilize these scripts. This allows you to save
this folder wherever you want. Just modify the path if you dont clone to your home
directory.
````
alias tmpc='source ~/.dotfiles/scripts/CTemplate.sh'
alias tdev='source ~/.dotfiles/scripts/tmux-dev.sh'
alias project='source ~/.dotfiles/scripts/ProjectLayout.sh'
alias mdtopdf='source ~/.dotfiles/scripts/MDtoPDF.sh'
````

#### MDtoPDF
MDtoPDF Uses **Python Markdown** and **wkhtmltopdf** to convert a markdown file into a pdf
file.

Usage: `mdtopdf <filenamewithoutextension> <optionaldirectory>`  
Example: `mdtopdf notes pdf` would convert notes.md to a pdf and save it to the /pdf
directory

This script uses Python Markdown to export the markdown file to an html file, then it uses
wkhtmltopdf to convert the html file to a pdf. It can take a little time to convert to
PDF, but is a lot simpler than using pandoc in my opinion.

* https://pythonhosted.org/Markdown/install.html
* Install (Requires Python):
* `$ sudo pip install markdown`
* * http://wkhtmltopdf.org/
* Install:
* `$ sudo apt-get install wkhtmltopdf`
*
* #### ProjectLayout.sh
* Creates a file system structure to begin a project. The Makefile in files/ is really
only setup for C at the moment. Edit it based on the project's needs.

#### Tmux-Dev.sh
This is a simple script I made to setup a tmux environment, it looks like this when its
running. I usually have code open in vim on the left, a man page or other code open in the
bottom right corner, and use the top right for running commands and compiling on the go.
![tmux](files/tmux.png)

#### CTemplate.sh
This script copies a skeleton C file to either your current directory or one you provide.
This could also just be done with a copy alias. I use a script so I can provide a custom
file name/directory.
* Usage: `~/.dotfiles/scripts/CTemplate.sh <Directory/Filename>`
