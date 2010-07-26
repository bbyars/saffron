def relative_path(filename)
  File.expand_path(File.dirname(__FILE__) + "/#{filename}")
end

require relative_path('db.rb')
require relative_path('vendor_map.rb')

class Parser
  def initialize(csv_file, map=VendorMap.new)
    @csv_file, @map = csv_file, map
  end

  def parse
    results = []
    CSV.open(@csv_file, 'r') do |row|
      next unless is_data(row[0])
      results << parse_transaction(row)
    end

    results
  end

  def is_data(text)
    # Assume the first field is a date, but let subclasses override
    is_date(text)
  end

  def is_date(text)
    text =~ %r{\d{1,2}/\d{1,2}/\d{4}}
  end

  def parse_transaction(row)
    base_details = account_details.merge :occurred_on => occurred_on(row), :raw_with => raw_with(row), :amount => amount(row)
    transaction = Transaction.find(:first, :conditions => base_details) || Transaction.create(base_details)

    detail = @map.for(transaction)
    puts "CHOKING ON #{transaction.raw_with}" if detail.nil?
    transaction.with = detail.name
    transaction.category = detail.category
    transaction
  end

  # Implement these in your subclass
  def amount(row); end;
  def raw_with(row); end;
  def occurred_on(row); end;
  def account_details; end;
end

