scripts_dir=$(cd $(dirname $0); pwd)

sol=$(ls sols/*-100pts.* | egrep "(.c|.cpp|.rb|.py)$" | head -n 1)
sol_cmd=$(sh $scripts_dir/compile.sh $sol)

printf "Generating output%55s\n" $sol
echo   "========================================================================"

for test_in in $(find tests/[1-9]* -type f -name 'in*'); do
  test_out=$(echo $test_in | sed 's:in\(.*\)$:out\1:g')
  printf "  %-15s %-15s " $test_in $test_out
  
  $sol_cmd < $test_in > $test_out
  if [ $? -eq '0' ]; then echo .; else echo F; fi
done
