#!/bin/bash

if [[ $1 == '--install' ]]; then
	echo "Installing git hooks..."
	git config core.hooksPath hooks
	echo "... done."
elif [[ $1 == '--uninstall' ]]; then
	echo "Uninstalling git hooks..."
	git config --unset core.hooksPath
	echo "... done."
else
    echo "[!] Usage: $0 [--install | --uninstall]"
fi