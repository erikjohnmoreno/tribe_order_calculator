require 'rspec'
require 'pry' # for breakpointing

class TribeOrderCalculator
  BUNDLE_INFO = {
    'IMG' => [[10, 800], [5, 450]],
    'FLAC' => [[9, 1147.50], [6, 810], [3, 427.50]],
    'VID' => [[5, 900], [3, 570]]
  }

  def self.calculate_order(input)
    result = []
    input.scan(/(\d+) (\w+)/) do |quantity, format|
      quantity = quantity.to_i
      if BUNDLE_INFO.key?(format)
        bundles = BUNDLE_INFO[format]
        total_cost = 0
        bundle_breakdown = []

        while quantity.positive?
          used_bundle = false
          bundles.each do |bundle_quantity, bundle_cost|
            if quantity >= bundle_quantity
              bundles_used = quantity / bundle_quantity
              quantity -= bundles_used * bundle_quantity
              total_cost += bundles_used * bundle_cost
              bundle_breakdown << "#{bundles_used} x #{bundle_quantity}"
              used_bundle = true
            end
          end

          # If no bundles were used, add remaining items as a single item
          if !used_bundle
            total_cost += quantity * bundles.first[1] # Use the cost of the smallest bundle
            bundle_breakdown << "#{quantity} x #{bundles.first[0]}"
            quantity = 0  # Set quantity to 0 since all items have been processed
          end
        end

        result << "#{format} total: #{total_cost}"
        bundle_breakdown.each { |breakdown| result << breakdown }
      else
        result << "Invalid format code: #{format}"
      end
    end
    result
  end
end

# RSpec tests
RSpec.describe TribeOrderCalculator do
  it 'calculates the cost and bundle breakdown for an order' do
    input = '10 IMG 15 FLAC 13 VID'
    output = TribeOrderCalculator.calculate_order(input)
    expected_output = ["IMG total: 800", "1 x 10", "FLAC total: 1957.5", "1 x 9", "1 x 6", "VID total: 2370", "2 x 5", "1 x 3"]
    expect(output).to eq(expected_output)
  end

  it 'calculates the cost and bundle breakdown for an order' do
    input = '15 IMG 15 FLAC 13 VID'
    output = TribeOrderCalculator.calculate_order(input)
    expected_output = ["IMG total: 1250", "1 x 10", "1 x 5", "FLAC total: 1957.5", "1 x 9", "1 x 6", "VID total: 2370", "2 x 5", "1 x 3"]
    expect(output).to eq(expected_output)
  end

  it 'calculates the cost and bundle breakdown for an order' do
    input = '15 IMG 15 FLAC 23 VID'
    output = TribeOrderCalculator.calculate_order(input)
    expected_output = ["IMG total: 1250", "1 x 10", "1 x 5", "FLAC total: 1957.5", "1 x 9", "1 x 6", "VID total: 4170", "4 x 5", "1 x 3"]
    expect(output).to eq(expected_output)
  end

  it 'returns invalid format' do
    input = '15 IMA 15 FLAB 23 VIS'
    output = TribeOrderCalculator.calculate_order(input)
    expected_output = ["Invalid format code: IMA", "Invalid format code: FLAB", "Invalid format code: VIS"]
    expect(output).to eq(expected_output)
  end
end

# Run the tests
RSpec::Core::Runner.run([]) if __FILE__ == $PROGRAM_NAME