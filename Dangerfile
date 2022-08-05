# frozen_string_literal: true

failure 'Please re-submit this Pull Request to main.' if github.branch_for_base != 'main'

if prose.proselint_installed?
  prose.lint_files
  if prose.mdspell_installed?
    prose.ignored_words = ['SRG', 'SSR', 'comScore', 'Webtrekk', 'Mapp', 'TagCommander']
    prose.check_spelling
  else
    warn('mdspell is not installed. Markdown spellchecking could not be made.')
  end
else
  warn('proselint is not installed. Markdown linting could not be made.')
end

swiftlint.lint_files inline_mode: true
