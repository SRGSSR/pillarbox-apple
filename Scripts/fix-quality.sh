#!/bin/bash

set -e

eval "$(pkgx --shellcode)"
env +swiftlint

swiftlint --fix && swiftlint
