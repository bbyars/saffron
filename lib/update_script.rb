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

