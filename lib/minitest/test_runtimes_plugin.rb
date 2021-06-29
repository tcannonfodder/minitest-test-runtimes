module Minitest
  def self.plugin_test_runtimes_options(opts, options)
    opts.on "--report-test-runtimes", "Report test runtimes as a CSV. Defaults to tmp/test_runtimes.csv" do |file|
      options[:report_test_runtimes] = true
    end

    opts.on "--report-test-runtimes-file FILE", "Set the test runtimes report file location. Defaults to tmp/test_runtimes.csv" do |file|
      options[:report_test_runtimes] = true
      options[:report_test_runtimes_file] = file
    end

    # opts.on "--report-test-runtimes FILE", "Report test runtimes as a CSV. Defaults to tmp/test_runtimes.csv" do |file|
    #   options[:report_test_runtimes] = true
    #   options[:report_test_runtimes_file] = file
    # end
  end

  def self.plugin_test_runtimes_init(options)
    self.reporter << TestRuntimesReporter.new(options) if options[:report_test_runtimes]
  end


  class TestRuntimesReporter < AbstractReporter
    attr_accessor :report_file, :results
    def initialize(options)
      self.results = []
      self.report_file = options[:report_test_runtimes_file] || 'tmp/test_runtimes.csv'
    end

    def record(result)
      self.results << result
    end

    def report
      CSV.open(self.report_file, "wb") do |csv|
        csv << self.class.csv_header
        self.results.each do |result|
          csv << self.class.row_for(result: result)
        end
      end
    end

    def self.csv_header
      return [
        "test_name",
        "runtime (ms)",
        "result",
        "test_class",
        "test_file",
        "source_location",
      ]
    end

    def self.row_for(result:)
      [
        result.name,
        result.time * 1_000,
        test_status(result: result),
        result.klass,
        result.source_location.first,
        result.source_location.join(":")
      ]
    end

    def self.test_status(result:)
      case result.result_code.to_s.downcase
      when "."
        return "pass"
      when "F"
        return "failed"
      when "E"
        return "errored"
      when "S"
        return 'skipped'
      else
        return "unknown"
      end
    end

    
  end
end