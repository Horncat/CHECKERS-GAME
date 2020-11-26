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
  sek: 1.to_d,
  usd: 8.04.to_d,
  btc: 90_594.66.to_d,
  goog: 1137.51.to_d * 8.04
}.freeze

class MovingAverage
  def initialize(period)
    @period = period
    @n = 0
    @total = 0.to_d
  end

  def append(value)
    if @n >= @period
      @total = ((@total / @period) * (@period - 1) + value).round(10)
    else
      @n += 1
      @total += value
    end
  end

  def current_value
    @total / @n
  end
end

# daily std dev of rate relative to 90 days rolling mean price
RATES_STD_DEV = {
  sek: 0.to_d,
  usd: 0.005.to_d,
  btc: 0.07.to_d,
  goog: 0.01.to_d
}.freeze

GROWTH_YOY = {
  sek: 1.to_d,
  usd: 1.to_d,
  btc: 3.2.to_d, # https://www.reddit.com/r/Bitcoin/comments/76bctp/bitcoin