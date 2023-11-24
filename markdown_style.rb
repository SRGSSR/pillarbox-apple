# frozen_string_literal: true

all

exclude_rule 'MD013'
exclude_rule 'MD033'
exclude_rule 'MD041'

rule 'MD024', allow_different_nesting: true
rule 'MD029', style: :ordered
