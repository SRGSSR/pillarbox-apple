
# Development setup

This article briefly discusses local development setup.

## Required tools

The following tools are required for the best possible development experience:

- The tvOS simulator (otherwise provisioning fails for tvOS when archiving the tvOS app).
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

An [editor configuration file](../.editorconfig) and several linter configuration files are provided to ensure common styling and best practices. Editors can usually be configured to apply some of these rules automatically and consistently.

### Visual Studio Code

- [.editorconfig extension](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig).
- [shellcheck extension](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck).
- [rubocop extension](https://marketplace.visualstudio.com/items?itemName=misogi.ruby-rubocop).
