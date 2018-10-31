#!/bin/bash
if ! which brew > /dev/null; then
	echo "brew not found; trying to source ~/.bash_profile first"
	. ~/.bash_profile
	if ! which brew > /dev/null; then
		echo "brew not found; aborted"
		exit 1
	fi
fi

# This is Python-3.6.5. It seems that PyTorch-0.4.1 does not work in the
# latest Python-3.7.x
brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/f2a764ef944b1080be64bd88dca9a1d80130c558/Formula/python.rb
brew install tmux
brew install gnu-tar
