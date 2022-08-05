# Continuous integration

The project provides support for continuous integration. Several commands have been implemented using [fastlane](https://fastlane.tools) and are exposed in a `Makefile` for convenient use. In particular you can:

- Build the project documentation.
- Run unit tests.
- Perform nightly and release deliveries on TestFlight.
- Lint the code.
- Run code quality checks using [Danger](https://danger.systems/ruby/).

The use of these commands require access to a [private configuration repository](https://github.com/SRGSSR/pillarbox-apple-configuration) which contains all secrets required for TestFlight and GitHub integration.

Most commands can be run locally but also on a continuous integration server. We currently use TeamCity for continuous integration and GitHub for issue and pull request management. This document describes the steps required to fully integrate the tool suite with TeamCity and GitHub.

# Unit tests

TODO: Text

# Deliveries

TODO: Text

# Code quality checks

TODO: Text