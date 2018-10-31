#!/bin/bash
if [ -f "Mendeley-Desktop-1.19.2-OSX-Universal.dmg" ]; then
	hdiutil attach "Mendeley-Desktop-1.19.2-OSX-Universal.dmg"
	cp -R "/Volumes/Mendeley Desktop/Mendeley Desktop.app" $HOME/Desktop
	hdiutil detach "/Volumes/Mendeley Desktop" 
	rm "Mendeley-Desktop-1.19.2-OSX-Universal.dmg"
fi
if [ -f "pycharm-community-2018.2.4.dmg" ]; then
	hdiutil attach "pycharm-community-2018.2.4.dmg"
	cp -R "/Volumes/PyCharm CE/PyCharm CE.app" $HOME/Desktop
	hdiutil detach "/Volumes/PyCharm CE"
	rm "pycharm-community-2018.2.4.dmg"
fi
if [ -f "Preferences.sublime-settings" -a ! -f "$HOME/Application Support/Sublime Text 3/Packages/User/Preferences.sublime-settings" ]; then
	mkdir -p "$HOME/Application Support/Sublime Text 3/Packages/User"
	cp "Preferences.sublime-settings" "$HOME/Application Support/Sublime Text 3/Packages/User"
	echo "Installed Preferences.sublime-settings to \"$HOME/Application Support/Sublime Text 3/Packages/User\""
fi
if [ -f "Sublime Text Build 3176.dmg" ]; then
	hdiutil attach "Sublime Text Build 3176.dmg"
	cp -R "/Volumes/Sublime Text/Sublime Text.app" $HOME/Desktop
	hdiutil detach "/Volumes/Sublime Text"
	rm "Sublime Text Build 3176.dmg"
fi
