# frozen_string_literal: true

source 'https://rubygems.org'

gem 'danger'
gem 'danger-swiftlint'
gem 'fastlane'
gem 'jazzy'
gem 'xcode-install'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
