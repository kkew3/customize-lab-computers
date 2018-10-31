#!/bin/bash

#
# This script has only been tested on Mac computers of University of
# California San Diego (UCSD).
#
# Basic configurations:
# - install python-pip
# - install a wide collection of Python packages to user directory
# - install homebrew under $HOME/Library/
# - set .bashrc, .vimrc, .tmux.conf
#
# Optional environment variable:
# - WITH_MLSUITE_PY2=1  to install a full suite of Machine Learning
#                       packages suite with pip; otherwise install
#                       it yourself to `$HOME/Library/Python/2.7/lib
#                       /python/site-packages`
# - WITH_TEXLIVE=1      to install TeXLive 2012 under user library
#                       directory
#

CURDIR="`pwd`"

if ! python -m pip --help > /dev/null 2>&1; then
	curl -O https://bootstrap.pypa.io/get-pip.py
	python get-pip.py --user --no-warn-conflicts
	rm get-pip.py
fi

if python -m pip --help > /dev/null 2>&1 && [ "$WITH_MLSUITE_PY2" = 1 ]; then
	if ! python -c "import numpy, scipy, matplotlib, clipboard, pandas, sklearn, skimage, torch, torchvision, hickle, h5py, IPython"; then
		# install a collection of ML packages in user directory
		python -m pip install -t $HOME/Library/Python/2.7/lib/python/site-packages \
			numpy scipy matplotlib clipboard jupyter notebook virtualenv \
			pandas scikit-learn scikit-image future nltk torch torchvision \
			hickle h5py ipython \
			--upgrade
		# to launch jupyter notebook at directory `xxx', do: cd xxx && python -m notebook
		# seem that matplotlib needs to install some font at first use
		python -c "import matplotlib.pyplot as plt"
		python -m nltk.downloader brown stopwords
	fi
fi

# create bash profile
cat > $HOME/.bash_profile << EOF
alias ll="ls -hlrt"
alias la="ls -a"
alias lla="ls -ahlrt"

PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin"
PATH="\$HOME/bin:\$PATH"

# turn off special handling of ._* files in tar, etc.
export COPYFILE_DISABLE=1

# color in bash
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# prompt with time
export PS1="[\D{%T}] \h:\W \u\$ "

# some functions
# Usage: rieng6 [ssh | sftp] [sftp-init-dir]
function rieng6() {
	if [ -z "\$1" -o "\$1" = ssh ]; then
		ssh \$USER@ieng6.ucsd.edu
	elif [ "\$1" = sftp -a -z "\$2" ]; then
		sftp -s /usr/local/bin/cluster-sftp \$USER@ieng6.ucsd.edu
	elif [ "\$1" = sftp -a -n "\$2" ]; then
		sftp -s /usr/local/bin/cluster-sftp \$USER@ieng6.ucsd.edu:"\$2"
	fi
}

# Usage: no argument
function set_darkbackground_vimrc() {
	if [ ! -f "\$HOME/.vimrc" ] || ! grep -q 'set background=dark' "\$HOME/.vimrc"; then
		echo 'set background=dark' >> "\$HOME/.vimrc"
	fi
}

# Usage: no argument
function alias_tar2gtar() {
	if ! which gtar > /dev/null; then
		echo 'gtar not found' >> /dev/stderr
		return 1
	fi
	if ! grep -q 'alias tar=' "\$HOME/.bash_profile"; then
		echo 'alias tar="gtar"' >> "\$HOME/.bash_profile"
	fi
}

# Usage: pipinstall numpy scipy torch ...
function pipinstall() {
	python -m pip install -t "\$HOME/Library/Python/2.7/lib/python/site-packages" "\$@" --upgrade
}

# Usage: cleardsstore [DIR]
# where DIR is default to \$(pwd)
function clear_dsstore() {
	local directory="\$(pwd)"
	if [ -n "\$1" ]; then directory="\$1"; fi
	find "\$directory" -name '.DS_Store' | xargs rm
}

# Usage: no argument
function ipython() {
	if python -c "import IPython" 2> /dev/null; then
		python -m IPython
	else
		echo 'IPython not found' >> /dev/stderr
		return 1
	fi
}
EOF

# directories
mkdir -p $HOME/bin
mkdir -p $HOME/Documents/Work

if [ ! -d $HOME/Library/homebrew ]; then
	# Install homebrew if not yet installed
	cd $HOME/Library
	mkdir homebrew
	curl -s -L https://github.com/Homebrew/brew/tarball/master \
		| tar xz --strip 1 -C homebrew
	# first-time launch caching
	homebrew/bin/brew --help > /dev/null
fi
if ! which brew > /dev/null; then
	cat >> $HOME/.bash_profile << EOF
PATH="\$HOME/Library/homebrew/bin:\$PATH"
export HOMEBREW_NO_ANALYTICS=1
EOF
fi


if [ "$WITH_TEXLIVE" = 1 ]; then
	# download and install TeXLive
	LATEXPREFIX=$HOME/Library
	curl -L http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz -s > install-tl-unx.tar.gz
	tar xzf install-tl-unx.tar.gz
	rm install-tl-unx.tar.gz
	cd install-tl-*
	cat > $HOME/tlprofile << EOF
TEXDIR $LATEXPREFIX/texlive/2012
TEXMFLOCAL $LATEXPREFIX/texlive/texmf-local
TEXMFSYSVAR $LATEXPREFIX/texlive/2012/texmf-var
TEXMFSYSCONFIG $LATEXPREFIX/texlive/2012/texmf-config
TEXMFVAR $HOME/.texlive2012/texmf-var
TEXMFCONFIG $HOME/.texlive2012/texmf-config
TEXMFHOME $HOME/texmf
EOF
	./install-tl -profile $HOME/tlprofile > /dev/null
	cat >> $HOME/.bash_profile << EOF
PATH="$LATEXPREFIX/texlive/2012/bin/x86_64-darwin:\$PATH"
MANPATH="$LATEXPREFIX/texlive/2012/texmf-dist/doc/man:$MANPATH"; export MANPATH
INFOPATH="$LATEXPREFIX/texlive/2012/texmf-dist/doc/info:$INFOPATH"; export INFOPATH
EOF
	cd ..
	rm -rf install-tl-unx
	rm $HOME/tlprofile
fi

# wrap up .bash_profile
cat >> $HOME/.bash_profile << EOF

export PATH
EOF

# Install teleconsole
if [ ! -f $HOME/bin/teleconsole ]; then
	echo Installing teleconsole to $HOME/bin
	curl https://www.teleconsole.com/get.sh -O get.sh
	sed -i -e 's/sudo//' get.sh
	sed -i -e '/DEST=/c\
	DEST="$HOME/bin"' get.sh
	sh get.sh
	rm -f get-e.sh get.sh 
fi

cd "$CURDIR"

# copy some configurations
if [ -f vimrc ]; then
	mv vimrc $HOME/.vimrc;
	echo "Found vimrc; installed to $HOME/.vimrc"
fi
if [ -f tmux.conf ]; then
	mv tmux.conf $HOME/.tmux.conf
	echo "Found tmux.conf; installed to $HOME/.tmux.conf"
fi
if [ -d PyCharmCE2018.2 ]; then
	mv PyCharmCE2018.2 $HOME/.PyCharmCE2018.2
	echo "Found PyCharmCE2018.2; installed to $HOME/.PyCharmCE2018.2"
fi
if [ -f Pro.terminal ]; then
	cp Pro.terminal "$HOME/Desktop"
fi

# my favorite desktop background
if [ -f penguin_darkened.png ]; then
	osascript -e 'tell application "Finder" to set desktop picture to POSIX file "'"$(pwd)/penguin_darkened.png"'"'
fi

echo Done.
echo You may want to do \". \~/.bash_profile\" now.
if python -m pip --help > /dev/null 2>&1 && python -m pip list | grep -q jupyter; then
	echo "You may launch notebook by \"python -m notebook\""
	echo "You may launch ipython console by \"ipython\""
fi

if [ -f brews.sh ]; then
	echo You may install additional packages using \"./brews.sh\"
fi
