require File.join(File.dirname(__FILE__), "/../spec_helper")
require 'timeout'

module Guara
  TIME_LIMIT = 10

  shared_examples_for "supported language" do |ext|
    it "should compile" do
      exec = Guara::Execute.new("spec/resources/compile.#{ext}")
      exec.compile!.should be_true
    end

    it "should not compile when has errors" do
      exec = Guara::Execute.new("spec/resources/notcompile.#{ext}")
      exec.compile!.should be_false
    end

    it "should run" do
      exec = Guara::Execute.new("spec/resources/compile.#{ext}")
      exec.run!.should eq(Guara::EXIT_SUCCESS)
    end

    it "should run and return nonzero exit status" do
      exec = Guara::Execute.new("spec/resources/nonzero.#{ext}")
      exec.run!.should_not eq(Guara::EXIT_SUCCESS)
    end

    it "should not run when has errors" do
      exec = Guara::Execute.new("spec/resources/notcompile.#{ext}")
      exec.run!.should eq(Guara::EXIT_COMPILE_ERROR)
    end

    it "should run and kill when exceed time limit" do
      Timeout::timeout(TIME_LIMIT) do
        exec = Guara::Execute.new("spec/resources/timelimit.#{ext}",
                                  :time_limit => 2)
        exec.run!.should eq(Guara::EXIT_TIME_LIMIT_EXCEEDED)
      end
    end

    it "should run and redirect file to input" do
      Timeout::timeout(TIME_LIMIT) do        
        exec = Guara::Execute.new("spec/resources/exit0ifreceiveinput.#{ext}",
                                  :input_file => "spec/resources/text")
        exec.run!.should eq(Guara::EXIT_SUCCESS)
      end
    end

    it "should run and redirect output to file" do
      stdout = Tempfile.new('stdout')
      exec = Guara::Execute.new("spec/resources/stdout.#{ext}",
                                :output_file => stdout.path)
      exec.run!.should eq(Guara::EXIT_SUCCESS)
      File.zero?(stdout.path).should be_false
      stdout.close!
    end

    it "should run and redirect stderr to file" do
      stderr = Tempfile.new('stderr')
      exec = Guara::Execute.new("spec/resources/stderr.#{ext}",
                                :error_file => stderr.path)
      exec.run!.should eq(Guara::EXIT_SUCCESS)
      File.zero?(stderr.path).should be_false
      stderr.close!
    end

    it "should output compilation error" do
      stderr = Tempfile.new('stderr')
      exec = Guara::Execute.new("spec/resources/notcompile.#{ext}",
                                :error_file => stderr.path)
      exec.run!.should eq(Guara::EXIT_COMPILE_ERROR)
      IO.read(stderr.path).should include('Compile error')
    end

    it "should run with parameters" do
      stdout = Tempfile.new('stdout')
      exec = Guara::Execute.new("spec/resources/printargs.#{ext}",
                                :output_file => stdout.path,
                                :error_file  => '/dev/null',
                                :params      => 'param')
      exec.run!.should eq(Guara::EXIT_SUCCESS)
      IO.read(stdout.path).should include('param')
    end
  end

  describe Execute do
    describe 'Source file in C' do
      it_should_behave_like 'supported language', 'c'
    end

    describe 'Source file in C++' do
      it_should_behave_like 'supported language', 'cpp'
      it_should_behave_like 'supported language', 'cc'
    end

    describe 'Source file in Ruby' do
      it_should_behave_like 'supported language', 'rb'
    end

    describe 'Source file in Python' do
      it_should_behave_like 'supported language', 'py'
    end

    describe 'Source file in Java' do
      it_should_behave_like 'supported language', 'java'
    end

    describe 'Source file in Pascal' do
      it_should_behave_like 'supported language', 'pas'
    end
  end
end
