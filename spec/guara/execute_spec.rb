require File.join(File.dirname(__FILE__), "/../spec_helper")
require 'timeout'

module Guara
  TIME_LIMIT = 1

  describe Execute do
    describe 'with C source file' do
      it "should compile" do
        exec = Guara::Execute.new("spec/resources/compile.c")
        exec.compile!.should be_true
      end

      it "should not compile when has errors" do
        exec = Guara::Execute.new("spec/resources/notcompile.c")
        exec.compile!.should be_false
      end

      it "should run" do
        exec = Guara::Execute.new("spec/resources/compile.c")
        exec.run!.should eq(Guara::EXIT_SUCCESS)
      end
      
      it "should run and return nonzero exit status" do
        exec = Guara::Execute.new("spec/resources/nonzero.c")
        exec.run!.should_not eq(Guara::EXIT_SUCCESS)
      end

      it "should not run when has errors" do
        exec = Guara::Execute.new("spec/resources/notcompile.c")
        exec.run!.should eq(Guara::EXIT_COMPILE_ERROR)
      end

      it "should run and kill when exceed time limit" do
        Timeout::timeout(2 * TIME_LIMIT) do
          exec = Guara::Execute.new("spec/resources/timelimit.c",
                                    :time_limit => TIME_LIMIT)
          exec.run!.should eq(Guara::EXIT_TIME_LIMIT_EXCEEDED)
        end
      end

      it "should run and redirect file to input" do
        Timeout::timeout(TIME_LIMIT) do        
          exec = Guara::Execute.new("spec/resources/exit0ifreciveinput.c",
                                    :input_file => "spec/resources/text")
          exec.run!.should eq(Guara::EXIT_SUCCESS)
        end
      end

      it "should run and redirect output to file" do
        stdout = Tempfile.new('stdout')
        exec = Guara::Execute.new("spec/resources/stdout.c",
                                 :output_file => stdout.path)
        exec.run!.should eq(Guara::EXIT_SUCCESS)
        File.zero?(stdout.path).should be_false
        stdout.close!
      end

      it "should run and redirect stderr to file" do
        stderr = Tempfile.new('stderr')
        exec = Guara::Execute.new('spec/resources/stderr.c',
                                  :error_file => stderr.path)
        exec.run!.should eq(Guara::EXIT_SUCCESS)
        File.zero?(stderr.path).should be_false
        stderr.close!
      end
    end
  end
end
