scripts_dir=$(cd $(dirname $0); pwd)


echo "Generating inputs"
echo "========================================================================"
echo

rm -rf tests/[1-9]*
for generator in $(find generator | egrep "(.c|.c99|.C|.cc|.cpp|.rb|.py|.pl)$"); do
   printf "%72s\n" $generator
   echo "------------------------------------------------------------------------"
   (cd tests ; sh $scripts_dir/execute.sh ../$generator)
done
