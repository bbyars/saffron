require 'rubygems'
require 'selenium-webdriver'

module Canada
  module HSBC

    class VendorMap < ::VendorMap
      def special_match(transaction)
        is_check = transaction.raw_with.include?('CHEQUE')
        amount = transaction.amount
        date = transaction.occurred_on

        return Detail.new('Jody Cross', 'Rent') if is_check && equal(amount, -1750)
        return Detail.new('Von Kids', 'Child Care') if is_check && equal(amount, -250) && ['07/02/2010', '06/01/2010', '05/03/2010', '04/01/2010', '03/01/2010', '02/01/2010'].include?(date)
        return Detail.new('Fencing Club', 'Sports') if is_check && equal(amount, -205) && date == '01/13/2010'
        return Detail.new('Fencing Club', 'Sports') if is_check && equal(amount, -340) && date == '01/13/2010'
        return Detail.new('Transfer from US', 'Transfer') if equal(amount, 4500) && date == '05/07/2010'
        return Detail.new('Transfer from US', 'Transfer') if equal(amount, 4941.96) && date == '04/21/2010'
      end

      def equal(actual, expected)
        (expected - 0.001) <= actual && actual <= (expected + 0.001)
      end
    end


    class Parser < ::Parser
      DATE = 0
      DETAILS = 1
      DEBIT = 2
      CREDIT = 3

      def initialize(csv_file)
        super(csv_file, Canada::HSBC::VendorMap.new)
      end

      def account_details
        { :account => 'HSBC', :currency => 'CAD' }
      end

      def amount(row)
        amount = row[DEBIT].to_s.empty? ? row[CREDIT].to_s.gsub(',', '').to_f : -1 * row[DEBIT].to_s.gsub(',', '').to_f
      end

      def raw_with(row)
        row[DETAILS]
      end

      def occurred_on(row)
        row[DATE]
      end
    end


    class Downloader
      def self.start
        profile = Selenium::WebDriver::Firefox::Profile.new ENV['FIREFOX_PROFILE']
        driver = Selenium::WebDriver.for :firefox, :profile => profile
        driver.navigate.to 'http://hsbc.ca'
        new(driver)
      end

      def initialize(driver)
        @driver = driver
      end

      def download!
        goto_login_page
        login
        answer_questions
        goto_account
        goto_download
        goto_download_final
        download_file!
        @driver.quit
      end

      def goto_login_page
        @driver.click_and_wait_for :method => :xpath, :expression => '//a/img[contains(@src, "logon")]/..',
          :predicate => lambda { @driver.exists? :name, 'userid' }
      end

      def login
        @driver.find_element(:name, 'userid').value = ENV['CANADA_HSBC_USER']
        @driver.click_and_wait_for :method => :xpath, :expression => '//a/img[@alt="Go"]/..',
          :predicate => lambda { @driver.exists? :name, 'RCCsubmit' }
      end

      def answer_questions
        @driver.find_element(:name, 'memorableAnswer').value = ENV['CANADA_HSBC_ANSWER']
        @driver.find_element(:name, 'RCCfield1').value = password_letters[0]
        @driver.find_element(:name, 'RCCfield2').value = password_letters[1]
        @driver.find_element(:name, 'RCCfield3').value = password_letters[2]
        @driver.click_and_wait_for :method => :name, :expression => 'RCCsubmit',
          :predicate => lambda { @driver.exists? :link_text, ENV['CANADA_HSBC_ACCT_NUMBER'] }
      end

      def goto_account
        @driver.click_and_wait_for :method => :link_text, :expression => ENV['CANADA_HSBC_ACCT_NUMBER'],
          :predicate => lambda { @driver.exists? :link_text, 'Download to Quicken/Money' }
      end

      def goto_download
        @driver.click_and_wait_for :method => :link_text, :expression => 'Download to Quicken/Money',
          :predicate => lambda { @driver.exists? :name, 'software' }
      end

      def goto_download_final
        @driver.find_element(:name, 'software').select_option 'Comma delimited (.csv)'
        @driver.click_and_wait_for :method => :link_text, :expression => 'Download',
          :predicate => lambda { @driver.exists? :link_text, 'Cancel' }
      end

      def download_file!
        @driver.find_element(:link_text, 'Download').click
      end

      def password_letters
        indexes = @driver.find_elements(:xpath, '//font[@color="red"]/b').collect { |tag| tag.text }
        cardinal_map = {'FIRST' => 0, 'SECOND' => 1, 'THIRD' => 2, 'FOURTH' => 3, 'FIFTH' => 4, 'SIXTH' => 5, 'SEVENTH' => 6, 'EIGHTH' => 7}
        letters = indexes.collect do |letter_index|
          index = cardinal_map[letter_index]
          ENV['CANADA_HSBC_PWD'][index..index]
        end
      end
    end

  end
end

