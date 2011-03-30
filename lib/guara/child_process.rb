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
      @pid   = nil
      status = nil
      
      run_command = proc do
        @pid = fork do
          Process.setrlimit(Process::RLIMIT_CPU, @timeout) if @timeout

          STDIN.reopen(@stdin)   if @stdin
          STDOUT.reopen(@stdout) if @stdout
          STDERR.reopen(@stderr) if @stderr

          Process.exec(*@command)
        end
        status = Process.wait2(@pid)[1]
      end

      if @timeout
        thread = Thread.new do
          run_command.call()
        end
        real_time = 0.0
        while real_time < 2 * @timeout
          sleep 0.1
          real_time += 0.1
          break unless thread.status
        end
        if status.nil?
          thread.kill
          return @exit_code = Guara::EXIT_TIME_LIMIT_EXCEEDED
        end 
      else
        run_command.call()
      end

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
