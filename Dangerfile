# frozen_string_literal: true

failure 'Please re-submit this Pull Request to main.' if github.branch_for_base != 'main'

if prose.proselint_installed?
  prose.lint_files
else
  warn('proselint is not installed. Markdown linting could not be made.')
end

swiftlint.lint_files inline_mode: true
