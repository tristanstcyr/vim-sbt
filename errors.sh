cat ./target/streams/compile/compileIncremental/\$global/streams/out | sed $'s,\x1b\\[[0-9;]*[a-zA-Z],,g' > ./target/errors.err  2> ./target/errors.txt
