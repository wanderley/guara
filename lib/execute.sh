source=$1

t=''
case $source in
	*.c99)
    d="`mktemp -d /tmp/XXXXXXX`"
		t="`mktemp /tmp/XXXXXXXXX`"
    cp "$source" "$d/a.c"
		gcc -std=gnu99 -O2 -fomit-frame-pointer -o "$t" "$d/a.c"
    ret_val=$?
		cmd="$t"
    rm -rf "$d"
		;;
	*.c)
		t=`mktemp /tmp/XXXXXXXXXX`
		gcc -O2 -fomit-frame-pointer -o $t $source
		cmd="$t"
		;;
	*.C|*.cc|*.cpp)
		t=`mktemp /tmp/XXXXXXXXXX`
		g++ -O2 -fomit-frame-pointer -o $t $source
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
esac

eval "$cmd"

if [ -n "$t" ]; then
	rm "$t"
fi
