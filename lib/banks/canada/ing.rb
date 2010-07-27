require 'rubygems'
require 'selenium-webdriver'
require File.expand_path(File.dirname(__FILE__) + "/extensions")
require File.expand_path(File.dirname(__FILE__) + "/vendor_map")
require File.expand_path(File.dirname(__FILE__) + "/parser")

module ING

  class VendorMap < ::VendorMap
    def for(transaction)
      category = transaction.raw_with.include?('Interest Paid') ? 'Interest' : 'Transfer'
      Detail.new transaction.raw_with, category
    end
  end


  module Canada

    class Parser < ::Parser
      DATE = 0
      TRANSACTION = 1
      NAME = 2
      MEMO = 3
      AMOUNT = 4

      def initialize(csv_file)
        super(csv_file, ING::VendorMap.new)
      end

      def account_details
        { :account => 'ING', :currency => 'CAD' }
      end

      def amount(row)
        amount = row[AMOUNT]
        amount *= -1 unless ['CREDIT', 'INT'].include?(row[TRANSACTION])
      end

      def raw_with(row)
        "#{row[NAME]}, #{row[MEMO]}"
      end

      def occurred_on(row)
        row[DATE]
      end
    end

  end


  module US

    class Parser < ::Parser
      DATE = 7
      AMOUNT = 8
      DESCRIPTION = 10

      def initialize(csv_file)
        super(csv_file, ING::VendorMap.new)
      end

      def is_data(text)
        text =~ /\d+/
      end

      def account_details
        { :account => 'ING', :currency => 'USD' }
      end

      def amount(row)
        row[AMOUNT]
      end

      def raw_with(row)
        row[DESCRIPTION]
      end

      def occurred_on(row)
        row[DATE]
      end
    end

  end
end
