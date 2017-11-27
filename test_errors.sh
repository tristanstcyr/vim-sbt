cat target/streams/test/compileIncremental/\$global/streams/out | sed $'s,\x1b\\[[0-9;]*[a-zA-Z],,g' > ./target/errors.err
