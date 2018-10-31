#!/bin/bash
if [ "${BASH_SOURCE[0]}" = "\${0}" ]; then
	echo This script intends to be sourced rather than be called
	exit 1
fi

if [ -n "$VIRTUAL_ENV" ]; then
	deactivate
fi
rm -rf "$HOME/bin"
rm -rf "$HOME/Documents/Work"
find "$HOME/Downloads" -mindepth 1 -maxdepth 1 -not -name '.localized' -print0 \
	| xargs -0 -n1 -I'{}' -- rm -rf "{}"
find "$HOME/Desktop" -mindepth 1 -maxdepth 1 \( -not -name 'Workarea' -and -not -name '.localized' \) -print0 \
	| xargs -0 -n1 -I'{}' -- rm -rf "{}"
rm -f "$HOME/.bash_profile"
rm -f "$HOME/.vimrc"
