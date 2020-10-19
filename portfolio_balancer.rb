require 'bigdecimal'
require 'bigdecimal/util'
require 'distribution'

KEYS = %i[sek btc usd goog].freeze

INITIAL_AMOUNTS = {
  sek: 10_000.to_d,
  usd: 1000.to_d,
  btc: 0.2.to_d,
  goog: 1.to_d
}.freeze

INITIAL_RATES_SEK = {