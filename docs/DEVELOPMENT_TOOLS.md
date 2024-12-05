
# Development tools

This article discusses the various development tools available when working on Pillarbox.

## Makefile

A [Makefile](../Makefile) provides several useful development-oriented commands. Simply run:

```shell
make
```

to list all available commands.

### Local test streams

Since Apple players [cannot play local manifests](https://developer.apple.com/forums/thread/69357?answerId=202051022#202051022) we are using Python to run a simple [web server](https://docs.python.org/3/library/http.server.html) serving various [test streams](TEST_STREAM_GENERATION.md) from a local directory. These streams are used throughout unit test suites.

The web server must be manually started using:

```shell
make test-streams-start
```

before running tests. It can be stopped at any time with:

```shell
make test-streams-stop
```

If unit tests fail you should check that streams are served correctly at [http://localhost:8123](http://localhost:8123) and start the server if needed. Note that some sample streams require ~20 seconds to be fully available after the server was started.

### Quality checks

Quality checks can be run using:

```shell
make check-quality
```

This ensures that Swift files, scripts and documentation conform to common best practices. Many issues can be automatically fixed by running:

```shell
make fix-quality
```

### Git hooks

Git hooks can be installed by running the following command:

```shell
make git-hook-install
```

and uninstalled by running the following command:

```shell
make git-hook-uninstall
```

### Clean imports

Run this command to remove unnecessary imports:

```shell
make clean-imports
```

### Find dead code

Run this command to remove unused code:

```shell
make find-dead-code
```

### Reload SPM dependencies

You can reload SPM dependencies by running:

```shell
make spm-reload
```

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

We are currently using [cloud signing](https://developer.apple.com/wwdc21/10204) with automatic provisioning updates.
