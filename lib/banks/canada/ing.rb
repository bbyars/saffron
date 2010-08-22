require 'rubygems'
require 'selenium-webdriver'

module Canada
  module ING

    class VendorMap < ::VendorMap
      def for(transaction)
        category = transaction.raw_with.include?('Interest Paid') ? 'Interest' : 'Transfer'
        Detail.new transaction.raw_with, category
      end
    end

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

    class Downloader
      attr_accessor :driver

      def self.start
        profile = Selenium::WebDriver::Firefox::Profile.new ENV['FIREFOX_PROFILE']
        driver = Selenium::WebDriver.for :firefox, :profile => profile
        driver.navigate.to 'http://ingdirect.ca'
        new(driver)
      end

      def initialize(driver)
        @driver = driver
      end

      def download!
        goto_login_page
        login
        enter_pin
        goto_download_page
        download_csvs
      end

      def goto_login_page
        @driver.click_and_wait_for :method => :id, :expression => 'iamclient', #'//img[id="iamclient"]/..',
          :predicate => lambda { @driver.exists? :name, 'ACN' }
      end

      def login
        @driver.find_element(:name, 'ACN').value = ENV['CANADA_ING_USER']
        @driver.click_and_wait_for :method => :name, :expression => "Go",
          :predicate => lambda { @driver.exists? :name, 'PIN' }
      end

      def enter_pin
        @driver.find_element(:name, 'PIN').value = ENV['CANADA_ING_PIN']
        @driver.click_and_wait_for :method => :name, :expression => 'Go',
          :predicate => lambda { @driver.exists? :id, 'SignOff' }
      end

      def goto_download_page
        @driver.click_and_wait_for :method => :name, :expression => 'Print',
          :predicate => lambda { @driver.exists? :name, 'ACCT' }
      end

      def download_csvs
        options = @driver.find_element(:name, 'ACCT').find_elements(:tag_name, 'option')
        (1..(options.length-1)).each do |account_index|
          account = @driver.find_element(:name, 'ACCT').find_elements(:tag_name, 'option')[account_index]
          account.select
          @driver.find_element(:name, 'DOWNLOADTYPE').select_option 'Excel/Other Software'
          @driver.click_and_wait_for :method => :name, :expression => 'YES, I WANT TO CONTINUE.',
            :predicate => lambda { @driver.exists? :xpath, '//img[alt="Download"]' }
          @driver.find_element(:xpath, '//img[alt="Download"]').click
          sleep 5
          @driver.click_and_wait_for :method => :xpath, :expression => '//input[alt="CHANGE THIS"]',
            :predicate => lambda { @driver.exists? :name, 'ACCT' }
        end
      end
    end

  end
end
