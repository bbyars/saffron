def require_relative(relative_path)
  require File.expand_path(File.dirname(__FILE__) + "/#{relative_path}")
end

require 'rubygems'
require_relative 'db'
require_relative 'vendor_map'
require_relative 'extensions'
require_relative 'parser'
require_relative 'update_script'
require_relative 'vendor_map'

