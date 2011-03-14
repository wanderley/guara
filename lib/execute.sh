source=$1

t=''
case $source in
	*.c)
		t=`mktemp /tmp/XXXXXXXXXX`
		gcc -O2 -fomit-frame-pointer -o $t $source
		cmd="$t"
		;;
	*.cpp)
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
