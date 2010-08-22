require 'rubygems'
require 'selenium-webdriver'

module US
  module AMEX

    class Parser < ::Parser
      DATE = 0
      AMOUNT = 2
      WITH = 3
      DETAILS = 4

      def account_details
        { :account => 'AMEX', :currency => 'USD' }
      end

      def amount(row)
        row[AMOUNT]
      end

      def raw_with(row)
        "#{row[WITH]}, #{row[DETAILS]}"
      end

      def occurred_on(row)
        row[DATE]
      end
    end


    class Downloader
      attr_reader :driver

      def self.start
        profile = Selenium::WebDriver::Firefox::Profile.new ENV['FIREFOX_PROFILE']
        driver = Selenium::WebDriver.for :firefox, :profile => profile
        driver.navigate.to 'https://home.americanexpress.com/home/mt_personal.shtml'
        new(driver)
      end

      def initialize(driver)
        @driver = driver
      end

      def download!
        login
        view_online_statement
        goto_download_page
        goto_download_csv
        download_file!
        @driver.quit
      end

      def login
        @driver.find_element(:id, 'Userid').value = ENV['US_AMEX_USER']
        @driver.find_element(:id, 'password').value = ENV['US_AMEX_PWD']
        @driver.click_and_wait_for :method => :xpath, :expression => '//img[@alt="Click to log in"]',
          :predicate => lambda { @driver.exists? :link_text, 'Online Statement' }
      end

      def view_online_statement
        @driver.click_and_wait_for :method => :link_text, :expression => 'Online Statement',
          :predicate => lambda { @driver.exists? :id, 'topLinkDownload' }
      end

      def goto_download_page
        @driver.click_and_wait_for :method => :id, :expression => 'topLinkDownload',
          :predicate => lambda { @driver.exists? :id, 'downloadDialogContent' }
      end

      def goto_download_csv
        @driver.find_element(:id, 'dwnloadofx').click
        @driver.click_and_wait_for :method => :xpath, :expression => '//div[@id="downloadDialogContent"]/div/button[span/span="CONTINUE"]',
          :predicate => lambda { @driver.exists? :id, 'downloadFormButton' }
        @driver.find_element(:id, 'nav_6').click # select CSV
        sleep 1
      end

      def download_file!
        @driver.find_element(:id, 'bpindex00').click
        @driver.find_element(:id, 'downloadFormButton').click
      end
    end

  end
end

