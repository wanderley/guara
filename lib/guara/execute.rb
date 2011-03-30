require 'tempfile'

module Guara
  EXIT_SUCCESS             = 0
  EXIT_COMPILE_ERROR       = 1
  EXIT_TIME_LIMIT_EXCEEDED = 2
  EXIT_GAP                 = 1000
  COMPILE_TIME_LIMIT       = 10

  class Execute
    attr_reader :source_file, :source_file_extension, :error_file
    attr_accessor :input_file, :output_file, :time_limit, :error_file, :params

    def initialize(source, options={})
      @source_file = source
      @source_file_extension = File.extname(source)
      @tmp_dir       = Dir.mktmpdir
      @compiled_file = File.join(@tmp_dir, 'exec')
      @compiled      = nil

      @options = options
      @input_file  = @options[:input_file]
      @output_file = @options[:output_file]
      @error_file  = @options[:error_file]
      @time_limit  = @options[:time_limit]
      @params      = @options[:params] || ''

      ObjectSpace.define_finalizer(self, self.class.finalizer(@tmp_dir))
    end

    def self.finalizer(tmp_dir)
      proc { FileUtils.remove_entry_secure(tmp_dir) }
    end

    def compile!
      return @compiled unless @compiled.nil?
      p = nil
      case @source_file_extension
      when '.c'
        p = ChildProcess.build("gcc -O2 -fomit-frame-pointer #{@source_file} -o #{@compiled_file}")
        @execute_command = @compiled_file
      when /.c(pp|c)/
        p = ChildProcess.build("g++ -O2 -fomit-frame-pointer #{@source_file} -o #{@compiled_file}")
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
        class_file = File.basename(@source_file, '.java')
        @execute_command = "java -cp #{@tmp_dir} #{class_file}"
      when /.pas/
        FileUtils.cp(@source_file, @tmp_dir)
        FileUtils.cd(@tmp_dir) do
          p = ChildProcess.build("fpc -O2 -o#{@compiled_file} #{@source_file}")
          @execute_command = @compiled_file
        end
      end

      p.timeout = 10
      exit_code = nil

      case @source_file_extension
      when /.java/
        FileUtils.cd(@tmp_dir) do
          exit_code = p.run!
        end
      else 
        exit_code = p.run!
      end

      if exit_code != Guara::EXIT_SUCCESS
        f = (@error_file ? File.new(@error_file, 'w') : STDERR)
        f.puts "Compile error"
        f.puts "------------------------------------------------------------------------"
        f.puts IO.read(p.stderr.path)
        f.flush
      end
      @compiled = (exit_code == Guara::EXIT_SUCCESS)
    end

    def run!
      return Guara::EXIT_COMPILE_ERROR unless compile!
      p = Guara::ChildProcess.build("#{@execute_command} #{@params}")
      p.stdout  = nil
      p.stderr  = nil
      p.stdin   = File.new(@input_file, 'r')  if @input_file
      p.stdout  = File.new(@output_file, 'w') if @output_file
      p.stderr  = File.new(@error_file, 'w')  if @error_file
      p.timeout = @time_limit                 if @time_limit

      exit_code = p.run!

      p.stdin.close  if @input_file
      p.stdout.close if @output_file
      p.stderr.close if @error_file
      exit_code
    end
  end
end
