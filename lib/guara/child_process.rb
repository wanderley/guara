module Guara
  class ChildProcess
    attr_reader   :exit_code
    attr_accessor :timeout, :stdin, :stdout, :stderr

    def self.build(command)
      ChildProcess.new(command)
    end

    def initialize(command)
      @stdin       = nil
      @stdout      = Tempfile.new('stdout')
      @stderr      = Tempfile.new('stderr')
      @pid         = nil
      @timeout     = nil
      @exit_code   = nil
      @command     = command
    end

    def run!
      @pid = fork {
        Process.setrlimit(Process::RLIMIT_CPU, @timeout) if @timeout

        STDIN.reopen(@stdin)   if @stdin
        STDOUT.reopen(@stdout) if @stdout
        STDERR.reopen(@stderr) if @stderr

        exec(*@command)
      }
      status = Process.wait2(@pid)[1]
      if status.exited?
        return @exit_code = Guara::EXIT_SUCCESS if status.exitstatus == 0
        return @exit_code = status.exitstatus + Guara::EXIT_GAP
      else
        if RUBY_PLATFORM.include?('linux')
          return @exit_code = 
            Guara::EXIT_TIME_LIMIT_EXCEEDED if status.termsig == 9
        else
          return @exit_code = 
            Guara::EXIT_TIME_LIMIT_EXCEEDED if status.termsig == 24
        end
      end
    end
  end
end
