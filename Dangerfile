# frozen_string_literal: true

failure 'Please re-submit this Pull Request to main.' if github.branch_for_base != 'main'

if prose.proselint_installed?
  prose.lint_files
  prose.ignored_words = ["SRG", "SSR", "comScore", "Webtrekk", "Mapp", "TagCommander"]
  prose.check_spelling
end

swiftlint.lint_files inline_mode: true
