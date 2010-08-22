require 'rubygems'
require 'selenium-webdriver'

module US
  module HSBC

    class VendorMap < ::VendorMap
      def for(transaction)
        category = transaction.raw_with.include?('Interest Paid') ? 'Interest' : 'Transfer'
        Detail.new transaction.raw_with, category
      end
    end

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

