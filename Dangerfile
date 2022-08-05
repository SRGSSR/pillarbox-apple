# frozen_string_literal: true

failure 'Please re-submit this Pull Request to main.' if github.branch_for_base != 'main'

prose.lint_files if prose.proselint_installed?
swiftlint.lint_files inline_mode: true
