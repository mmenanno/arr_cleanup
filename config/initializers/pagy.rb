# frozen_string_literal: true

require "pagy/extras/overflow"

# Pagy initializer file
# See https://ddnexus.github.io/pagy/docs/api/pagy#instance-variables
Pagy::DEFAULT[:limit] = 25 # items per page
Pagy::DEFAULT[:overflow] = :last_page # return last page if out of range
