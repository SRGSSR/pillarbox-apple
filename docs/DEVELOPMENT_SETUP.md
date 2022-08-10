
# Development setup

This article briefly discusses local development setup.

## Required tools

The following tools are required for the best possible development experience:

- [gem](https://rubygems.org)
- [bundler](https://bundler.io)
- [swiftlint](https://github.com/realm/SwiftLint)
- [shellcheck](https://www.shellcheck.net)
- [yamllint](https://github.com/adrienverge/yamllint)

swiftlint, shellcheck and yamllint can easily be installed with [Homebrew](https://brew.sh).

## Demo

The project provides a demo application which can be run to test features offered by the Pillarbox package.

## Unit tests

Unit tests are provided with the Pillarbox package.

## Makefile

A [Makefile](../Makefile) provides several commands to perform quality checks, run unit tests or deliver demo app builds. Just run:

```shell
make
```

to list all available commands.

## Quality checks

Quality checks can be run using:

```shell
make check-quality
```

This ensures that Swift files, scripts and documentation conform to common best practices.

## Editor configuration

An [editor configuration file](../.editorconfig) is provided to ensure common styling (tabs, spaces, etc.).

[Various widely used editors](https://editorconfig.org) support this file automatically. A [plugin](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig) is required for Visual Studio Code users.
