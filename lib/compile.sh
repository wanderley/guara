source=$1
tail=$2

t=''
cmd=''
ret_val=1

case $source in
  *.c)
    t=`mktemp /tmp/XXXXXXXXXX`
    gcc -O2 -fomit-frame-pointer -o $t $source
    ret_val=$?
    cmd="$t"
    ;;
  *.c99)
    t=`mktemp /tmp/XXXXXXXXXX`
    gcc -std=gnu99 -O2 -fomit-frame-pointer -o $t $source
    ret_val=$?
    cmd="$t"
    ;;
  *.cpp)
    t=`mktemp /tmp/XXXXXXXXXX`
    g++ -O2 -fomit-frame-pointer -o $t $source
    ret_val=$?
    cmd="$t"
    ;;
  *.py)
    cmd="python $source"
    ;;
  *.rb)
    cmd="ruby $source"
    ;;
  *.pl)
    cmd="perl $source"
    ;;
  *.pas)
    t=`mktemp /tmp/XXXXXXXXXX`
    fpc -O2 -o$t $source
    ret_val=$?
    cmd="$t"
    ;;
esac

echo $cmd
exit $ret_val
