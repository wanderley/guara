Feature: exec source_file [options]

  Use exec exec to compile and execute a source file.

  Scenario: run "Hello, world!" in C
    Given a file named "helloworld.c" with:
          """
          #include <stdio.h>
          int main () {
            printf ("Hello, world!\n");
            return 0;
          }
          """
    When I run `guara exec helloworld.c`
    Then the output should contain "Hello, world!"
     And the exit status should be 0

  Scenario: run C code that doesn't return 0
    Given a file named "nonzero.c" with:
          """
          int main () { return 1; }
          """
     When I run `guara exec nonzero.c`
     Then the exit status should not be 0

  Scenario: run C code with time limit
    Given a file named "timelimit.c" with:
          """
          int main () { while (1); return 0; }
          """
     When I run `guara exec timelimit.c --time-limit=1`
     Then the exit status should be 2

  Scenario: run with input file redirect to stdin and output file redirect to stdout
    Given a file named "cat.c" with:
          """
          #include <stdio.h>
          int main () {
            int c;
            while ((c = getchar ()) != EOF)
              putchar (c);
            return 0;
          }
          """
      And a file named "text.txt" with:
          """
          text text text
          """
      And an empty file named "text.out"
     When I run `guara exec cat.c --input-file text.txt --output-file text.out`
     Then the file "text.out" should contain "text text text"

  Scenario: run and redirect stderr to file
    Given a file named "tostderr.c" with:
          """
          #include <stdio.h>
          int main () {
            fprintf (stderr, "stderr");
            return 0;
          }
          """
      And an empty file named "stderr.txt"
     When I run `guara exec tostderr.c --error-file stderr.txt`
     Then the file "stderr.txt" should contain "stderr"

  @wip
  Scenario: run and kill when compiling take a long time
    Given a file named "compile-timeout.c" with:
          """
          #include "/dev/random"
          int main () {
            return 0;
          }
          """
          When I run `guara exec compile-timeout.c --error-file=stderr.txt`
     Then the file "stderr.txt" should contain "Compilation exceeded time limit!"
