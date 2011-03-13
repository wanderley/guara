scripts_dir=$(cd $(dirname $0); pwd)


echo "Generating inputs"
echo "========================================================================"
echo

rm -rf tests/[1-9]
for generator in $(find generator | egrep "(.c|.cpp|.rb|.py)$"); do
   printf "%72s\n" $generator
   echo "------------------------------------------------------------------------"
   $(cd tests ; sh $scripts_dir/execute.sh ../$generator)
done

#rm -rf tests/0
#mkdir -p tests/0
#cp tests_sample/* tests/0/
