# Continuous integration

The project provides support for continuous integration. Several commands have been implemented using [fastlane](https://fastlane.tools) and are exposed in a `Makefile` for convenient use. The idea is to provide commands that can be executed locally and run by a continuous integration server with minimal configuration.

Commands are available to:

- Build the project documentation.
- Run unit tests.
- Perform nightly and release deliveries on TestFlight.
- Lint the code.
- Run code quality checks using [Danger](https://danger.systems/ruby/).

Use of these commands requires access to a [private configuration repository](https://github.com/SRGSSR/pillarbox-apple-configuration) which contains all secrets required for TestFlight and GitHub integration.

We currently use TeamCity for continuous integration and GitHub for issue and pull request management. This document describes the steps required to fully integrate the tool suite with TeamCity and GitHub.

## Required tools

The continuous integration server should have the following tools installed:

- [gem](https://rubygems.org) and [bundler](https://bundler.io).
- [proselint](https://github.com/amperser/proselint/), which can be easily installed with Homebrew.

## Continuous integration user

Our current workflow is based on pull requests, which TeamCity is able to automatically monitor with a dedicated [build feature](https://www.youtube.com/watch?v=4yFck9PvXI4). When a pull request is created TeamCity can automatically trigger various jobs which can post their result as pull request GitHub comments.

Proper integration with GitHub requires the use of a dedicated continuous integration user (a bot) with write access to the repository. We already have a dedicated [RTS devops](https://github.com/rts-devops) user, we therefore only need a few additional configuration steps:

1. Ensure the bot has write access to the GitHub repository.
2. Integration with GitHub requires the creation of a dedicated [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with minimal permissions.

Of course a proper SSH setup is also required so that repositories can be pulled by the continuous integration server.

## Code quality checks

To have TeamCity run code quality checks for GitHub pull requests and post the corresponding status back to GitHub:

1. Create a TeamCity configuration called _Code quality_.
2. Add a VCS _Trigger_ on `+:pull/*`.
3. Add a _Command Line_ build step which simply executes `make code-quality`.
4. Add a _Pull Requests_ build feature which monitors GitHub (requires a personal access token).
5. Checks are performed by Danger, which requires a few [environment variables](https://danger.systems/guides/getting_started.html) to be properly set. Add the following three environment variable _Parameters_ to the configuration:
	- `env.GITHUB_PULL_REQUEST_ID` with value  `%teamcity.pullRequest.number%`.
	- `env.GITHUB_REPO_SLUG` with value `SRGSSR/pillarbox-apple`.
	- `env.GITHUB_REPO_URL` with value `https://github.com/SRGSSR/pillarbox-apple`.
6. Add two _Agent Requirements_ ensuring that `env.GEM_HOME` and `tools.xcode.home` exist. Check that some agents are compatible and assignable (if agents are configured manually you might need to explicitly allow the configuration to be run).

## Documentation

To have TeamCity build and validate the documentation for GitHub pull requests and post the corresponding status back to GitHub:

1. Create a TeamCity configuration called _Documentation_.
2. Add a VCS _Trigger_ on `+:pull/*`.
3. Add a _Command Line_ build step which simply executes `make doc`.
4. Add a _Pull Requests_ build feature which monitors GitHub (requires a personal access token).
5. Add a _Commit status publisher_ build feature which posts to GitHub (requires a personal access token).
6. Add two _Agent Requirements_ ensuring that `env.GEM_HOME` and `tools.xcode.home` exist. Check that some agents are compatible and assignable (if agents are configured manually you might need to explicitly allow the configuration to be run).

## Unit tests

To have TeamCity run unit tests for GitHub pull requests and post the corresponding status back to GitHub:

1. Create a TeamCity configuration called _Tests iOS_.
2. Add a VCS _Trigger_ on `+:pull/*`.
3. Add a _Command Line_ build step which simply executes `make test-ios`.
4. Add a _Pull Requests_ build feature which monitors GitHub (requires a personal access token).
5. Add a _Commit status publisher_ build feature which posts to GitHub (requires a personal access token).
6. Add an _XML report processing_ build feature formatting test output as _Ant JUnit_ and which monitors `+:fastlane/test_output/*.xml`.
7. Add two _Agent Requirements_ ensuring that `env.GEM_HOME` and `tools.xcode.home` exist. Check that some agents are compatible and assignable (if agents are configured manually you might need to explicitly allow the configuration to be run).

For comprehensive results a second _Tests tvOS_ configuration must be created for tvOS. This is easily achieved by copying the configuration you just created and editing the _Command Line_ build step to execute `make test-tvos`.

## Deliveries

To have TeamCity deliver nightly and release builds of the demo application to TestFlight:

1. Create a TeamCity configuration called _Demo Nightly iOS_.
2. Add a _Command Line_ build step which simply executes `make deliver-demo-nightly-ios`.
3. Add two _Agent Requirements_ ensuring that `env.GEM_HOME` and `tools.xcode.home` exist. Check that some agents are compatible and assignable (if agents are configured manually you might need to explicitly allow the configuration to be run).

For comprehensive deliveries other _Demo Release iOS_, _Demo Nightly tvOS_ and _Demo Release tvOS_ configurations must be created, running `make deliver-demo-release-ios`, `make deliver-demo-nightly-tvos` and `make deliver-demo-release-tvos` respectively. These can be easily created by copying the first configuration you just created and editing the _Command Line_ build step accordingly.

### Remark

Nightly and release applications must be created with proper identifiers first on App Store Connect. For submission to succeed each application _Beta App Information_ and _Beta App Review Information_ must also have been properly filled in the TestFlight section of the App Store Connect portal.