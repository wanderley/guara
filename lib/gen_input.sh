scripts_dir=$(dirname $0)

echo "Generating inputs"
echo "========================================================================"
echo

for generator in $(find generator | egrep "(.c|.cpp|.rb|.py)$"); do
   printf "%72s\n" $generator
   echo "------------------------------------------------------------------------"
   rm -rf $(find tests/[1-9]*)
   $(cd tests ; sh $scripts_dir/execute.sh ../$generator)
done

#rm -rf tests/0
#mkdir -p tests/0
#cp tests_sample/* tests/0/
