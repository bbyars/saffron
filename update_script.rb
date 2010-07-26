def relative_path(filename)
  File.expand_path(File.dirname(__FILE__) + "/#{filename}")
end

class UpdateScript
  def initialize(downloader, parser)
    @downloader, @parser = downloader, parser
  end

  def update!
    @downloader.download!
    transactions = @parser.parse
    transactions.each { |txn| txn.save }
  end
end

