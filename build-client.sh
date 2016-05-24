if command -v stack; then
    GHC="stack ghc -- "
elif command -v ghc; then
    GHC="ghc"
else
    echo "No GHC found"
    return 1
fi

$GHC -outputdir tmp -package websockets -o client src/Client.hs
