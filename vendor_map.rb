require 'csv'

Detail = Struct.new(:name, :category)

BANK_DESCRIPTION = 0
NAME = 1
CATEGORY = 2

class VendorMap
  def initialize(mapping_file = File.expand_path(File.dirname(__FILE__) + "/base_mappings.csv"))
    @missing = Detail.new('??', '??')
    @details = {}
    CSV.open(mapping_file, 'r') do |row|
      @details[row[BANK_DESCRIPTION]] = Detail.new(row[NAME], row[CATEGORY]) unless row[CATEGORY].nil?
    end
  end

  def for(transaction)
    return @missing if transaction.raw_with.nil?
    match = @details.keys.detect { |detail| transaction.raw_with.include? detail }
    return @details[match] unless match.nil?
    return special_match(transaction) || @missing
  end

  def special_match(transaction)
    # Override in subclass if needed
    nil
  end
end

