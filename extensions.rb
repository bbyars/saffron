module Selenium
  module WebDriver

    class Driver
      def click_and_wait_for(options)
        find_element(options[:method], options[:expression]).click
        wait_for 30, options[:predicate]
      end

      def wait_for(seconds, predicate)
        now = Time.now
        sleep 0.2 while (Time.now - now) <= seconds and !predicate.call
        puts "Waited #{Time.now - now} seconds for #{predicate.call} find"
      end

      def exists?(method, expression)
        find_elements(method, expression).length > 0
      end
    end

    class Element
      def value=(text)
        clear
        send_keys text
      end

      def select_option(text)
        option = find_elements(:tag_name, 'option').detect { |opt| opt.text == text }
        option.select
      end

      def select
        bridge.setElementSelected @id
      end
    end

  end
end

