# Continuous integration

The project provides support for continuous integration. Several commands have been implemented using [fastlane](https://fastlane.tools) and are exposed in a `Makefile` for convenient use. The idea is to provide commands that can be executed locally as well as by a continuous integration server with minimal configuration.

Commands are available to:

- Build the project documentation.
- Run unit tests.
- Archive the demo.
- Perform nightly and release deliveries on TestFlight.
- Run code quality checks.

We currently use TeamCity for continuous integration and GitHub for issue and pull request management. This document describes the steps required to fully integrate the tool suite with TeamCity and GitHub. We want to:

- Execute status checks and post results to GitHub when a pull request is opened or updated.
- Build nightly demo apps when a pull request is opened or updated.
- Use draft pull requests for early preview of features in development (without on-commit status checks or deliveries, though).

## Required tools

The continuous integration agents must have the following tools installed:

- The latest version of Xcode (preferably several versions, including beta releases).
- The tvOS simulator (otherwise provisioning fails for tvOS when archiving the tvOS app).
- [Python](https://www.python.org).
- [gem](https://rubygems.org)
- [bundler](https://bundler.io)
- [swiftlint](https://github.com/realm/SwiftLint)
- [shellcheck](https://www.shellcheck.net)
- [yamllint](https://github.com/adrienverge/yamllint)

swiftlint, shellcheck and yamllint can easily be installed with [Homebrew](https://brew.sh).

## TeamCity configuration

To avoid commits on draft pull requests triggering status checks and nightly deliveries we must use an [internal TeamCity setting](https://youtrack.jetbrains.com/issue/TW-64444) `teamcity.internal.pullRequests.github.ignoreDraft` [set](https://www.jetbrains.com/help/teamcity/server-startup-properties.html#TeamCity+Internal+Properties) to `true` as follows:

1. Go under _Administration | Server Administration | Diagnostics | Internal Properties_.
2. Click _Edit internal properties_.

TeamCity also offers support for [GitHub hooks](https://github.com/JetBrains/teamcity-commit-hooks) to avoid polling GitHub for new commits.

## Private configuration

Use of archive and delivery commands requires access to a [private configuration repository](https://github.com/SRGSSR/pillarbox-apple-configuration). This repository is transparently pulled before the commands are executed (provided the continuous integration server has access to it).

## Continuous integration user

Our current workflow is based on pull requests, which TeamCity is able to automatically monitor with a dedicated [build feature](https://www.youtube.com/watch?v=4yFck9PvXI4). When a pull request is created TeamCity can automatically trigger various jobs which can post their result as pull request GitHub comments.

Proper integration with GitHub requires the use of a dedicated continuous integration user (a bot) with write access to the repository. We already have a dedicated [RTS devops](https://github.com/rts-devops) user, we therefore only need a few additional configuration steps:

1. Ensure the bot has write access to the GitHub repository.
2. Integration with GitHub requires the creation of a dedicated [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with minimal permissions (_public_repo_ is sufficient for a public repository).

Of course a proper SSH setup is also required so that main and configuration repositories can be properly pulled by the continuous integration server.

## App Store Connect configuration

Nightly and release applications must be created with proper identifiers first on App Store Connect. For submission to succeed each application _Beta App Information_ and _Beta App Review Information_ must also have been properly filled in the TestFlight section of the App Store Connect portal.

## Quality checks

To have TeamCity run quality checks for GitHub pull requests and post the corresponding status back to GitHub:

1. Create a TeamCity configuration called _Quality_.
2. Add a VCS _Trigger_ on `+:pull/*`.
3. Add a _Command Line_ build step which simply executes `make check-quality`.
4. Add a _Pull Requests_ build feature which monitors GitHub (requires a personal access token).
5. Add a _Commit status publisher_ build feature which posts to GitHub (requires a personal access token).
6. Add two _Agent Requirements_ ensuring that `env.GEM_HOME` and `tools.xcode.home` exist. Check that some agents are compatible and assignable (if agents are configured manually you might need to explicitly allow the configuration to be run).

## Demo archiving

To have TeamCity archive the demo (archive for all configurations without TestFlight submission) for GitHub pull requests and post the corresponding status back to GitHub:

1. Create a TeamCity configuration called _Demo Archiving iOS_.
2. Add a VCS _Trigger_ on `+:pull/*`.
3. Add a _Command Line_ build step which simply executes `make archive-demo-ios`.
4. Add a _Pull Requests_ build feature which monitors GitHub (requires a personal access token).
5. Add a _Commit status publisher_ build feature which posts to GitHub (requires a personal access token).
6. Add two _Agent Requirements_ ensuring that `env.GEM_HOME` and `tools.xcode.home` exist. Check that some agents are compatible and assignable (if agents are configured manually you might need to explicitly allow the configuration to be run).

For comprehensive results a second _Demo Archiving tvOS_ configuration must be created for tvOS. This is easily achieved by copying the configuration you just created and editing the _Command Line_ build step to execute `make archive-demo-tvos`.

## Documentation

To have TeamCity build and validate the documentation for GitHub pull requests and post the corresponding status back to GitHub:

1. Create a TeamCity configuration called _Documentation_.
2. Add a VCS _Trigger_ on `+:pull/*`.
3. Add a _Command Line_ build step which simply executes `make doc`.
4. Add a _Pull Requests_ build feature which monitors GitHub (requires a personal access token).
5. Add a _Commit status publisher_ build feature which posts to GitHub (requires a personal access token).
6. Add two _Agent Requirements_ ensuring that `env.GEM_HOME` and `tools.xcode.home` exist. Check that some agents are compatible and assignable (if agents are configured manually you might need to explicitly allow the configuration to be run).

## Tests

To have TeamCity run tests for GitHub pull requests and post the corresponding status back to GitHub:

1. Create a TeamCity configuration called _Tests iOS_.
2. Add a VCS _Trigger_ on `+:pull/*`.
3. Add a _Command Line_ build step which simply executes `make test-ios`.
4. Add a _Pull Requests_ build feature which monitors GitHub (requires a personal access token).
5. Add a _Commit status publisher_ build feature which posts to GitHub (requires a personal access token).
6. Add an _XML report processing_ build feature formatting test output as _Ant JUnit_ and which monitors `+:fastlane/test_output/*.xml`.
7. Add two _Agent Requirements_ ensuring that `env.GEM_HOME` and `tools.xcode.home` exist. Check that some agents are compatible and assignable (if agents are configured manually you might need to explicitly allow the configuration to be run).

For comprehensive results a second _Tests tvOS_ configuration must be created for tvOS. This is easily achieved by copying the configuration you just created and editing the _Command Line_ build step to execute `make test-tvos`.

## Demo nightlies

To have TeamCity deliver nightly builds of the demo application to TestFlight when pull requests are updated or merged back to `main`:

1. Create a TeamCity configuration called _Demo Nightly iOS_.
2. Add a VCS _Trigger_ on `+:main` and `+pull/*`.
3. Add a _Command Line_ build step which simply executes `make deliver-demo-nightly-ios`.
4. Add a _Pull Requests_ build feature which monitors GitHub (requires a personal access token).
5. Add a _Commit status publisher_ build feature which posts to GitHub (requires a personal access token).
6. Add the following environment variable _Parameters_ to the configuration to provide GitHub contextual information to our delivery tools:
    1. `env.GITHUB_API_TOKEN` with a valid personal access token.
    2. `env.GITHUB_PULL_REQUEST_ID` with value `%teamcity.pullRequest.number%`.
    3. `env.GITHUB_REPO_SLUG` with value `SRGSSR/pillarbox-apple` (organization/repository).
7. Add two _Agent Requirements_ ensuring that `env.GEM_HOME` and `tools.xcode.home` exist. Check that some agents are compatible and assignable (if agents are configured manually you might need to explicitly allow the configuration to be run).

For comprehensive results a second _Demo Nightly tvOS_ configuration must be created for tvOS. This is easily achieved by copying the configuration you just created and editing the _Command Line_ build step to execute `make deliver-demo-nightly-tvos`.

## Demo releases

To have TeamCity deliver release builds of the demo application to TestFlight manually when required:

1. Create a TeamCity configuration called _Demo Release iOS_.
2. Add a _Command Line_ build step which simply executes `make deliver-demo-release-ios`.
3. Add the following environment variable _Parameters_ to the configuration to provide GitHub contextual information to our delivery tools:
    1. `env.GITHUB_API_TOKEN` with a valid personal access token.
    2. `env.GITHUB_PULL_REQUEST_ID` with value `%teamcity.pullRequest.number%`.
    3. `env.GITHUB_REPO_SLUG` with value `SRGSSR/pillarbox-apple` (organization/repository).
4. Add two _Agent Requirements_ ensuring that `env.GEM_HOME` and `tools.xcode.home` exist. Check that some agents are compatible and assignable (if agents are configured manually you might need to explicitly allow the configuration to be run).

For comprehensive results a second _Demo Release tvOS_ configuration must be created for tvOS. This is easily achieved by copying the configuration you just created and editing the _Command Line_ build step to execute `make deliver-demo-release-tvos`.
