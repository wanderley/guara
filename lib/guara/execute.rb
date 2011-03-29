require 'tempfile'

module Guara
  EXIT_SUCCESS             = 0
  EXIT_COMPILE_ERROR       = 1
  EXIT_TIME_LIMIT_EXCEEDED = 2
  EXIT_GAP                 = 1000
  COMPILE_TIME_LIMIT       = 10

  class Execute
    attr_reader :source_file, :source_file_extension, :error_file

    def initialize(source, options={})
      @source_file = source
      @source_file_extension = File.extname(source)
      @tmp_dir       = Dir.mktmpdir
      @error_file    = File.join(@tmp_dir, 'stderr')
      @compiled_file = File.join(@tmp_dir, 'exec')
      @options = options
      ObjectSpace.define_finalizer(self, self.class.finalizer(@tmp_dir))
    end

    def self.finalizer(tmp_dir)
      proc { FileUtils.remove_entry_secure(tmp_dir) }
    end

    def compile!
      p = nil
      case @source_file_extension
      when '.c'
        p = ChildProcess.build("gcc #{@source_file} -o #{@compiled_file}")
        @execute_command = @compiled_file
      when /.c(pp|c)/
        p = ChildProcess.build("g++ #{@source_file} -o #{@compiled_file}")
        @execute_command = @compiled_file
      when /.rb/
        p = ChildProcess.build("ruby -c #{@source_file}")
        @execute_command = "ruby #{@source_file}"
      when /.py/
        p = ChildProcess.build("python -m py_compile #{@source_file}")
        @execute_command = "python #{@source_file}"
      when /.java/
        FileUtils.cp(@source_file, @tmp_dir)
        FileUtils.cd(@tmp_dir) do
          p = ChildProcess.build("javac #{File.basename(@source_file)}")
        end
        @execute_command = 
          "java -cp #{@tmp_dir} #{File.basename(@source_file, '.java')}"
      end
      p.timeout = 10
      p.stderr  = File.new(@error_file, 'w')
      case @source_file_extension
      when /.java/
        FileUtils.cd(@tmp_dir) do
          return p.run! == Guara::EXIT_SUCCESS
        end
      else 
        return p.run! == Guara::EXIT_SUCCESS
      end
    end

    def run!
      return Guara::EXIT_COMPILE_ERROR unless compile!
      p = Guara::ChildProcess.build(@execute_command)
      p.stdout  = nil
      p.stderr  = nil
      p.stdin   = File.new(@options[:input_file], 'r')  if @options[:input_file]
      p.stdout  = File.new(@options[:output_file], 'w') if @options[:output_file]
      p.stderr  = File.new(@options[:error_file], 'w')  if @options[:error_file]
      p.timeout = @options[:time_limit]                 if @options[:time_limit]
      p.run!
    end
  end
end
