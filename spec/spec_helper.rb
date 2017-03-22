require 'bundler/setup'
require 'rhcf_etl'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  def fixture_file(basename)
    File.expand_path File.join(fixtures_path, basename)
  end

  def fixtures_path
    File.join(File.dirname(__FILE__), 'fixtures')
  end

  def fixture_file_by_content(content)
    Tempfile.new('fixture').tap { |f| f.write content;f.rewind }
  end
end
