source=$1
tail=$2

t=''
cmd=''
ret_val=1

case $source in
	*.c99)
    d="`mktemp -d /tmp/XXXXXXXXXX`"
		t="`mktemp /tmp/XXXXXXXXXX`"
    cp "$source" "$d/a.c"
		gcc -std=gnu99 -O2 -fomit-frame-pointer -o "$t" "$d/a.c"
    ret_val=$?
		cmd="$t"
    rm -rf "$d"
		;;
	*.c)
		t=`mktemp /tmp/XXXXXXXXXX`
		gcc -O2 -fomit-frame-pointer -o $t $source
    ret_val=$?
    cmd="$t"
    ;;
  *.C|*.cc|*.cpp)
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
