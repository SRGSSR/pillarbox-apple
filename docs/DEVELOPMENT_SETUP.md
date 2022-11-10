
# Development setup

This article briefly discusses local development setup.

## Required tools

The following tools are required for the best possible development experience:

- The latest version of Xcode.
- The tvOS simulator (otherwise provisioning fails for tvOS when archiving the tvOS app).
- [Python](https://www.python.org)
- [gem](https://rubygems.org)
- [bundler](https://bundler.io)
- [ffmpeg](https://ffmpeg.org)
- [swiftlint](https://github.com/realm/SwiftLint)
- [shellcheck](https://www.shellcheck.net)
- [yamllint](https://github.com/adrienverge/yamllint)

ffmpeg, swiftlint, shellcheck and yamllint can easily be installed with [Homebrew](https://brew.sh).

## Demo

The project provides a demo application which can be run to test features offered by the Pillarbox package.

## Playground

A playground can be used to visualize Swift body refreshes.

## Unit tests

Unit tests are provided with the Pillarbox package. Since Apple players [cannot play local manifests](https://developer.apple.com/forums/thread/69357?answerId=202051022#202051022) we are using Python to run a simple [web server](https://docs.python.org/3/library/http.server.html) serving various [test streams](TEST_STREAM_GENERATION.md) from a local directory.

### Remark

The web server must be manually started using `make test-streams-start` before running the tests and remains running afterwards. It can be stopped at any time with `make test-streams-stop`.

If unit tests fail you should check that streams are served correctly at `http://localhost:8123` and start the server if this is not the case. Note that some sample streams require ~20 seconds to be fully available after the server started.

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

- [EditorConfig extension](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)
- [shellcheck extension](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck)
- [rubocop extension](https://marketplace.visualstudio.com/items?itemName=misogi.ruby-rubocop)

## Code signing

We are currently using [cloud signing](https://developer.apple.com/wwdc21/10204) with automatic provisioning updates. Code signing requires access to our [internal configuration repository](https://github.com/SRGSSR/pillarbox-apple-configuration) which is automatically pulled when running `make setup`, provided you have been granted access to it.

## Timelane

The project supports instrumentation with [Timelane](https://timelane.tools). Simply follow the  instructions to install the dedicated instrument so that you can inspect player events directly within Instruments.
