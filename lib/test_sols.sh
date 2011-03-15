scripts_dir=$(cd $(dirname $0); pwd)
log_path=$(mktemp "/tmp/XXXXXXXXXXX")

time_limit=$(ruby -r 'yaml' -e "puts YAML::load(File.read('config.yml'))['time_limit'] || ''")
special_judge=$(ruby -r 'yaml' -e "puts YAML::load(File.read('config.yml'))['special_judge'] || ''")
if [ -n "$special_judge" ]; then
  special_judge_cmd=$(sh $scripts_dir/compile.sh $special_judge)
fi

ulimit -t $time_limit

echo "Testing solutions"
echo "========================================================================"
echo

for sol in $(ls sols/ | egrep "\-[0-9]+pts..{2,3}$" | egrep "(.c|.cpp|.rb|.py|.pl)"); do
  printf "%72s\n" $sol
  echo   "------------------------------------------------------------------------"

  sol_cmd=$(sh $scripts_dir/compile.sh sols/$sol)
  for test_dir in $(ls tests); do
    passed=true
    printf "%-10s" "tests/$test_dir"
    for input_file in $(ls tests/$test_dir/in*); do
      output_file=$(echo $input_file | sed 's:in\(.*\)$:out\1:g')
      user_output_file=$(mktemp /tmp/XXXXXXXXXXX)
      $sol_cmd < $input_file > $user_output_file
      if [ -n "$special_judge" ]; then
        $special_judge_cmd $input_file $output_file $user_output_file sols/$sol > /dev/null
      else
        diff $output_file $user_output_file > /dev/null
      fi
      if [ $? -eq '0' ]; then printf '.'; else printf 'F'; fi
      rm $user_output_file
    done ; echo
  done ; echo
done

exit 0
