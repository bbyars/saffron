# require 'sqlite3'
require 'active_record'

#database_file = File.expand_path(File.dirname(__FILE__) + "/findance2.db")
#ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => database_file)

ActiveRecord::Base.establish_connection(
  :adapter => 'mysql',
  :host => 'localhost',
  :username => 'saffron',
  :password => 'saffron',
  :database => 'saffron'
)

class Transaction < ActiveRecord::Base
end
