# Continuous integration

The project provides support for continuous integration. Several commands have been implemented using [fastlane](https://fastlane.tools) and are exposed in a `Makefile` for convenient use. The idea is to provide commands that can be executed locally as well as by a continuous integration server with minimal configuration.

Commands are available to:

- Build the project documentation.
- Run unit tests.
- Archive the demo.
- Perform nightly and release deliveries on TestFlight.
- Run code quality checks.

We currently use TeamCity for continuous integration and GitHub for issue and pull request management. This document describes the steps required to fully integrate the tool suite with TeamCity and GitHub. We want to:

- Execute status checks and post results to GitHub when a pull request is opened, updated or [enqueued](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue).
- Avoid running status checks for draft pull requests.
- Build demo apps during the night if changes have been pushed to `main` during the day.

## Required tools

The continuous integration agents must have the following tools installed:

- The latest version of Xcode (preferably several versions, including beta releases).
- The tvOS simulator (otherwise provisioning fails for tvOS when archiving the tvOS app).
- [Python](https://www.python.org)
- [gem](https://rubygems.org)
- [bundler](https://bundler.io)
- [ffmpeg](https://ffmpeg.org)
- [markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli)
- [shellcheck](https://www.shellcheck.net)
- [swiftlint](https://github.com/realm/SwiftLint)
- [xcodes](https://github.com/RobotsAndPencils/xcodes)
- [yamllint](https://github.com/adrienverge/yamllint)

Most of these tools can easily be installed with [Homebrew](https://brew.sh).

## TeamCity configuration

TeamCity offers support for [GitHub hooks](https://github.com/JetBrains/teamcity-commit-hooks) to avoid polling GitHub for new commits.

## Private configuration

Use of archive and delivery commands requires access to a [private configuration repository](https://github.com/SRGSSR/pillarbox-apple-configuration). This repository is transparently pulled before the commands are executed (provided the continuous integration server has access to it).

## Workflow

Our current workflow is based on pull requests and [merge queues](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue), which TeamCity is able to automatically monitor with dedicated build features and triggers.

When a non-draft pull request is created or updated TeamCity triggers various status checks required for the pull request to be queued for merging. Pull request detection is performed using a dedicated build feature and results are posted to the GitHub pull request.

Once all status checks are successful and the pull request reviewed it can be added to the merge queue. GitHub then automatically creates a temporary branch which is detected by a TeamCity branch trigger so that the status checks are automatically performed with the most recent changes from `main`. Once all status checks pass the pull request is merged automatically.

## GitHub configuration

To support our worflow GitHub `main` branch protection settings must be configured as follows:

1. Enable _Require a pull request before merging_, _Require approvals_ with 1 approval as well as _Require approval of the most recent reviewable push_.
2. Enable _Require status checks to pass before merging_, _Require branches to be up to date before merging_ and the following required status checks:
  a. Demo Archiving iOS (Apple)
  b. Demo Archiving tvOS (Apple)
  c. Documentation (Apple)
  d. Quality (Apple)
  e. Tests iOS (Apple)
  f. Tests tvOS (Apple)
3. Enable _Require conversation resolution before merging_.
4. Enable _Require signed commits_.
5. Enable _Require linear history_.
6. Enable _Require linear history_ with _Squash and merge_ as method and _Only merge non-failing pull requests_.
7. Enable _Do not allow bypassing the above settings_.

In the general project settings:

1. Disable _Allow merge commits_.
2. Disable _Allow rebase merging_.
3. Enable _Allow squash merging_ with _Default to pull request title_.
4. Enable _Allow auto-merge_.
5. Enable _Always suggest updating pull request branches_.
6. Enable _Automatically delete head branches_.

## Continuous integration user

Proper integration with GitHub requires the use of a dedicated continuous integration user (a bot) with write access to the repository. We already have a dedicated [RTS devops](https://github.com/rts-devops) user, we therefore only need a few additional configuration steps:

1. Ensure the bot has write access to the GitHub repository.
2. Create a [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with the following minimal permissions:
  a. _public_repo_ since our repository is public.
  b. _read:org_ so that the pull request feature is able to read members of the organization. This way only PRs emerging from members trigger jobs (this is namely the default for the GitHub [pull request build feature](https://www.jetbrains.com/help/teamcity/pull-requests.html#Bitbucket+Cloud+Pull+Requests)).

Of course a proper SSH setup is also required so that main and configuration repositories can be properly pulled by the continuous integration server.

## App Store Connect configuration

Nightly and release applications must be created with proper identifiers first on App Store Connect. For submission to succeed each application _Beta App Information_ and _Beta App Review Information_ must also have been properly filled in the TestFlight section of the App Store Connect portal.

## Quality checks

To have TeamCity run quality checks for GitHub pull requests and post the corresponding status back to GitHub:

1. Create a TeamCity configuration called _Quality_.
2. Add a _VCS Trigger_ on `+:pull/*` and `+:gh-readonly-queue/*`.
3. Add a _Command Line_ build step which simply executes `make check-quality`.
4. Add a _Pull Requests_ build feature which monitors GitHub (requires a personal access token). Check the _Ignore Drafts_ option to avoid triggering work for draft pull requests.
5. Add a _Commit status publisher_ build feature which posts to GitHub (requires a personal access token).
6. Add an _Agent Requirement_ ensuring that `tools.xcode.home` exists. Check that some agents are compatible and assignable (if agents are configured manually you might need to explicitly allow the configuration to be run).

## Demo archiving

To have TeamCity archive the demo (archive for all configurations without TestFlight submission) for GitHub pull requests and post the corresponding status back to GitHub:

1. Create a TeamCity configuration called _Demo Archiving iOS_.
2. Add a _VCS Trigger_ on `+:pull/*` and `+:gh-readonly-queue/*`.
3. Add a _Command Line_ build step which simply executes `make archive-demo-ios`.
4. Add a _Pull Requests_ build feature which monitors GitHub (requires a personal access token). Check the _Ignore Drafts_ option to avoid triggering work for draft pull requests.
5. Add a _Commit status publisher_ build feature which posts to GitHub (requires a personal access token).
6. Add an _Agent Requirement_ ensuring that `tools.xcode.home` exists. Check that some agents are compatible and assignable (if agents are configured manually you might need to explicitly allow the configuration to be run).

For comprehensive results a second _Demo Archiving tvOS_ configuration must be created for tvOS. This is easily achieved by copying the configuration you just created and editing the _Command Line_ build step to execute `make archive-demo-tvos`.

## Documentation

To have TeamCity build and validate the documentation for GitHub pull requests and post the corresponding status back to GitHub:

1. Create a TeamCity configuration called _Documentation_.
2. Add a _VCS Trigger_ on `+:gh-readonly-queue/*`.
3. Add a _Command Line_ build step which simply executes `make doc`.
4. Add a _Pull Requests_ build feature which monitors GitHub (requires a personal access token). Check the _Ignore Drafts_ option to avoid triggering work for draft pull requests.
5. Add a _Commit status publisher_ build feature which posts to GitHub (requires a personal access token).
6. Add an _Agent Requirement_ ensuring that `tools.xcode.home` exists. Check that some agents are compatible and assignable (if agents are configured manually you might need to explicitly allow the configuration to be run).

## Tests

To have TeamCity run tests for GitHub pull requests and post the corresponding status back to GitHub:

1. Create a TeamCity configuration called _Tests iOS_.
2. Add a _VCS Trigger_ on `+:gh-readonly-queue/*`.
3. Add a _Command Line_ build step which simply executes `make test-ios`.
4. Add a _Pull Requests_ build feature which monitors GitHub (requires a personal access token). Check the _Ignore Drafts_ option to avoid triggering work for draft pull requests.
5. Add a _Commit status publisher_ build feature which posts to GitHub (requires a personal access token).
6. Add an _XML report processing_ build feature formatting test output as _Ant JUnit_ and which monitors `+:fastlane/test_output/*.xml`.
7. Add an _Agent Requirement_ ensuring that `tools.xcode.home` exists. Check that some agents are compatible and assignable (if agents are configured manually you might need to explicitly allow the configuration to be run).

For comprehensive results a second _Tests tvOS_ configuration must be created for tvOS. This is easily achieved by copying the configuration you just created and editing the _Command Line_ build step to execute `make test-tvos`.

## Demo nightlies

To have TeamCity deliver nightly builds of the demo application to TestFlight:

1. Create a TeamCity configuration called _Demo Nightly iOS_.
2. Add a _Schedule Trigger_ to deliver nightlies from `+:main` during the night.
3. Add a _Command Line_ build step which simply executes `make deliver-demo-nightly-ios`.
4. Add an _Agent Requirement_ ensuring that `tools.xcode.home` exists. Check that some agents are compatible and assignable (if agents are configured manually you might need to explicitly allow the configuration to be run).
5. Add a _Parameter_ with `teamcity.git.fetchAllHeads` as name, _Configuration parameter_ as kind and `true` as value.

For comprehensive results a second _Demo Nightly tvOS_ configuration must be created for tvOS. This is easily achieved by copying the configuration you just created and editing the _Command Line_ build step to execute `make deliver-demo-nightly-tvos`.

### Troubleshooting

If submission to App Store Connect fails with a timeout, please check the [service status](https://developer.apple.com/system-status/) and, if status is all green, [login](https://appstoreconnect.apple.com) to check the binary status directly. A manual action (e.g. compliance) might be required.

## Demo releases

To have TeamCity deliver release builds of the demo application to TestFlight manually when required:

1. Create a TeamCity configuration called _Demo Release iOS_.
2. Add a _Command Line_ build step which simply executes `make deliver-demo-release-ios`.
3. Add an _Agent Requirement_ ensuring that `tools.xcode.home` exists. Check that some agents are compatible and assignable (if agents are configured manually you might need to explicitly allow the configuration to be run).
4. Add a _Parameter_ with `teamcity.git.fetchAllHeads` as name, _Configuration parameter_ as kind and `true` as value.

For comprehensive results a second _Demo Release tvOS_ configuration must be created for tvOS. This is easily achieved by copying the configuration you just created and editing the _Command Line_ build step to execute `make deliver-demo-release-tvos`.

## Ruby version support

The tools we use might require a minimum version of Ruby which might not always be the default one available on an agent.

If this is the case then we can manage Ruby versions with [rbenv](https://github.com/rbenv/rbenv) on each agent and run `rbenv local [version]` in all _Command Line_ builds steps first to ensure a compatible Ruby version is used.
