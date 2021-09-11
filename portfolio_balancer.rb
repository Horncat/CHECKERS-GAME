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
  btc: 3.2.to_d, # https://www.reddit.com/r/Bitcoin/comments/76bctp/bitcoin_price_history_growing_by_a_factor_of_32/
  goog: 1.05.to_d
}.freeze

def find_proportions(amounts: INITIAL_AMOUNTS, rates: INITIAL_RATES_SEK)
  sek_values = KEYS.map { |key| [key, amounts[key] * rates[key]] }
  total = sek_values.sum { |(_key, value)| value }

  sek_values.each_with_object({}) do |(key, value), acc|
    acc[key] = value / total
  end
end

PROPORTIONS = find_proportions.freeze

puts "Proportions: #{PROPORTIONS}"

def random(lower_bound, upper_bound)
  rand(lower_bound.to_f.next_float...upper_bound)
end

def display_hash(amounts)
  amounts.merge(amounts) { |_k, v1, _v2| display_decimal(v1) }
end

def display_decimal(value)
  if value > 0 && value < 0.01 || value < 0 && value > -0.01
    format('%.5f', value.truncate(5))
  else
    format('%.2f', value.truncate(2))
  end
end

# State machine that triggers shock at random time
class ShockGenerator
  def initialize(interval_mean:, interval_std_dev:)
    @rng = Distribution::Normal.rng(interval_mean, interval_std_dev)
    @days_until_next = @rng.call
    @state = :normal
  end

  # advance state by one day
  def advance
    if @days_until_next <= 0
      @state = :shock
      @days_until_next = @rng.call
    else
      @state = :normal
      @days_until_next -= 1
    end
  end

  def shock?
    @state == :shoc