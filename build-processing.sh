#!/bin/bash -e

bytestring_lib=$HOT_SWAMP_BYTESTRING_LIB

if command -v stack; then
    GHC="stack ghc -- "
elif command -v ghc; then
    GHC="ghc"
else
    echo "No GHC found"
    return 1
fi

# -c : skip linking step (would be bypassed anyway)
# -o : we redirect the output
$GHC -c -outputdir tmp -o Processing-unlinked.o src/Processing.hs

# Linking step
# -o Processing.o : we redirect the output to our final object file
ld -r -o Processing.o Processing-unlinked.o $bytestring_lib

mv Processing-unlinked.o tmp
