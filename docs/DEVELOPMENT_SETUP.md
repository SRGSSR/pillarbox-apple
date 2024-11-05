
# Development setup

This article briefly discusses local development setup.

## Required tools

The following tools are required for the best possible development experience:

- The latest version of Xcode.
- The tvOS simulator (otherwise provisioning fails for tvOS when archiving the tvOS app).
- [bundler](https://bundler.io)
- [ffmpeg](https://ffmpeg.org)
- [gem](https://rubygems.org)
- [markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli)
- [Periphery](https://github.com/peripheryapp/periphery)
- [Python](https://www.python.org)
- [shellcheck](https://www.shellcheck.net)
- [swiftlint](https://github.com/realm/SwiftLint)
- [xcodes](https://github.com/RobotsAndPencils/xcodes)
- [yamllint](https://github.com/adrienverge/yamllint)

Most of these tools can easily be installed with [Homebrew](https://brew.sh).

## Demo

The project provides a demo application which can be run to test features offered by the Pillarbox package.

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

## Git hooks

### Installation

Git hooks can be installed by running the following command:

```shell
make git-hook-install
```

### Uninstallation

Git hooks can be uninstalled by running the following command:

```shell
make git-hook-uninstall
```

### Clean imports

This ensures to keep a clean codebase by removing unnecessary imports from the code.

```shell
make clean-imports
```

### Find dead code

This ensures to catch some parts of code which are potentially unused.

```shell
make find-dead-code
```

Before using the `make find-dead-code` command, ensure you have installed [Periphery](https://github.com/peripheryapp/periphery).

## Editor configuration

An [editor configuration file](../.editorconfig) and several linter configuration files are provided to ensure common styling and best practices. Editors can usually be configured to apply some of these rules automatically and consistently.

### Xcode

Xcode _Text Editing_ settings should be configured as follows:

- Enable _Automatically trim trailing whitespaces_ with _Including whitespace-only lines_ enabled as well.
- Set _Default Text Encoding_ to _UTF-8_.
- Set _Default Line Endings_ to _macOS / Unix (LF)_.
- Use _Spaces_ for indentation (with 4 spaces both for _Tab Width_ and _Indent Width_).

### Visual Studio Code

- [EditorConfig extension](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)
- [shellcheck extension](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck)
- [rubocop extension](https://marketplace.visualstudio.com/items?itemName=misogi.ruby-rubocop)

## Xcode previews

Please ensure that the target an Xcode preview belongs to is selected before attempting to render an Xcode preview (otherwise rendering will crash). Note that attempting to use the `Pillarbox` umbrella target does not work.

## Code signing

We are currently using [cloud signing](https://developer.apple.com/wwdc21/10204) with automatic provisioning updates. Code signing requires access to our [internal configuration repository](https://github.com/SRGSSR/pillarbox-apple-configuration) which is automatically pulled when running `make setup`, provided you have been granted access to it.

## Other resources

SwiftUI view behavior is documented with the terminology introduced in the [following article](http://defagos.github.io/understanding_swiftui_layout_behaviors).
