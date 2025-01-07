#!/bin/bash

function usage {
    echo
    echo "Usage: $0 [OPTION]"
    echo "   -i         install git hooks."
    echo "   -u         uninstall git hooks."
    echo
    exit 1
}

if [[ -z "$1" ]]; then
    usage
fi

while getopts iu OPT; do
    case "$OPT" in
        i)
            echo "Installing git hooks..."
            git config core.hooksPath hooks
            echo "... done."
            ;;
        u)
            echo "Uninstalling git hooks..."
            git config --unset core.hooksPath
            echo "... done."
            ;;
        *)
            usage
            ;;
    esac
done