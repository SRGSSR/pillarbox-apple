#!/bin/bash

set -e

mint run swiftlint --fix && mint run swiftlint
