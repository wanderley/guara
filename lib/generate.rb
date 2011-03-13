if ARGV.size == 0
   puts 'Informe o nome do problema como parâmetro!'
   exit 1
end
problema = ARGV[0]

%x[mkdir -p #{problema}/checkers]
%x[mkdir -p #{problema}/docs]
%x[mkdir -p #{problema}/generators]
%x[mkdir -p #{problema}/sols]
%x[mkdir -p #{problema}/tests]
%x[mkdir -p #{problema}/tests_sample]
%x[touch #{problema}/docs/br.tex]

File.open("#{problema}/config.rb", 'w') do |f|
   f.puts <<EOF
# Configuration file {{{
#
# $name            = Problem name.
# $time_limit      = Time limit per case.
# $memory_limit    = Memory limit per case.
# $points_per_test = Points per case.
# $number_of_tests = Number of tests case.
# $special_judge   = Special judge's file.
# $source          = Info about origin of the problem.
# }}}

$name            = "#{problema}"
$time_limit      = 1
$memory_limit    = 128
$source          = "Olimpíada Brasileira de Informática - 2010 - Seletiva - Dia X"

# tests {{{
$number_of_tests = 0
$tests           = []
test_in  = Dir.glob(File.join('tests/**', 'in*')).sort
test_out = Dir.glob(File.join('tests/**', 'out*')).sort
0.upto test_in.size-1 do |i|
   $tests << [ {:in => test_in[i], :out => test_out[i]} ]
end
$number_of_tests = $tests.size
$points_per_test = 100.0 / $number_of_tests
# }}}
EOF
end
