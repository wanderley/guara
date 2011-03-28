
require File.join(File.dirname(__FILE__), "/../spec_helper")
require 'timeout'

module Guara
  describe ChildProcess do
    it 'should exec a command' do
      process = Guara::ChildProcess.build('ls')
      process.run!
      process.exit_code.should eq(Guara::EXIT_SUCCESS)
    end

    it 'should exec and kill after 1 second' do
      Timeout::timeout(2) do
        process = Guara::ChildProcess.build('while [ true ]; do echo ''; done;')
        process.timeout = 1
        process.run!
        process.exit_code.should eq(Guara::EXIT_TIME_LIMIT_EXCEEDED)
      end
    end

    it 'should exec and redirect output to file' do
      process = Guara::ChildProcess.build("echo 'test'")
      process.run!
      process.stdout.open do |f|
        f.readlines.should eq(['test'])
      end
    end

    it 'should exec and redirect error to file' do
      process = Guara::ChildProcess.build(%Q{ruby -e 'STDERR.printf "test"'})
      process.run!
      process.stderr.open do |f|
        f.readlines.should eq(['test'])
      end
    end

    it 'should exec recieve stdin from a file' do
      stdin = Tempfile.new('stdin').open do |f|
        f.printf 'test'
      end
      process = Guara::ChildProcess.build("cat")
      process.stdin = stdin
      process.run!
      process.stdout.open do |f|
        f.readlines.should eq(['test'])
      end
    end
  end
end
