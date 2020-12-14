#!/bin/sh

failed=0
for test_file in ./tests/*.onyx ; do
	filename=$(basename -- "$test_file")
	name="${filename%.*}"

	echo "⏲ Checking $name.onyx"

	if ! ./onyx "$test_file" -o "./tests/$name.wasm" >/dev/null; then
		echo "❌ Failed to compile $name.onyx."
		failed=1
		continue
	fi
	
	if ! node onyxcmd.js "./tests/$name.wasm" > ./tmpoutput; then
		echo "❌ Failed to run $name.onyx."
		failed=1
		continue
	fi

	if ! diff ./tmpoutput "./tests/$name" >/dev/null; then
		echo "❌ Test output did not match."
		diff ./tmpoutput "./tests/$name"
		# failed=0
		continue
	fi

	rm "./tests/$name.wasm"
done
rm ./tmpoutput

([ $failed = 0 ] && echo "✔ All tests passed.") \
				  || echo "❌ Some tests failed."

exit $failed