require 'bigdecimal'
require 'bigdecimal/util'
require 'distribution'

KEYS = %i[sek btc usd goog].freeze

INITIAL_AMOUNTS = {
  sek: