require 'tempfile'

module Guara
  EXIT_SUCCESS             = 0
  EXIT_COMPILE_ERROR       = 1
  EXIT_TIME_LIMIT_EXCEEDED = 2
  EXIT_GAP                 = 1000

  class Execute
    attr_reader :source_file, :source_file_extension, :error_file

    def initialize(source, options={})
      @source_file = source
      @source_file_extension = File.extname(source)
      @error_file    = Tempfile.new('error_file')
      @compiled_file = Tempfile.new('compiled')
      @options = options
    end

    def compile!
      case @source_file_extension
      when '.c'
        %x[gcc #{@source_file} -o #{@compiled_file.path} 2>> #{@error_file.path}]
      when /.c(pp|c)/
        %x[g++ #{@source_file} -o #{@compiled_file.path} 2>> #{@error_file.path}]
      end
      return ($?.exitstatus == 0)
    end

    def run!
      return Guara::EXIT_COMPILE_ERROR unless compile!
      @pid = fork {
        Process.setrlimit(Process::RLIMIT_CPU,
                          @options[:time_limit]) if @options[:time_limit]

        STDIN.reopen(@options[:input_file])   if @options[:input_file]
        STDOUT.reopen(@options[:output_file]) if @options[:output_file]
        STDERR.reopen(@options[:error_file])  if @options[:error_file]

        exec @compiled_file.path
      }
      status = Process.wait2(@pid)[1]
      if status.exited?
        return EXIT_SUCCESS if status.exitstatus == 0
        return status.exitstatus + Guara::EXIT_GAP
      else
        if RUBY_PLATFORM.include?('linux')
          return Guara::EXIT_TIME_LIMIT_EXCEEDED if status.termsig == 9
        else
          return Guara::EXIT_TIME_LIMIT_EXCEEDED if status.termsig == 24
        end
      end
    end
  end
end
