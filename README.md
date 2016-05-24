
The inspiration for this came from [this
post](http://purelyfunctional.org/posts/2016-05-20-dynamic-loading-haskell-module.html)
by [cocreature](https://github.com/cocreature)

# Toy example of Haskell hot swap of compiled code

This toy example consists of three parts:

 * client: the client is built with `build-client.sh` and run with `./client`.
   The client communicates with a server over websocket connection.

 * Processing.o: the processing module, built with `build-processing.sh`. This
   module is loaded dynamically by the server.

 * server: the server is build with `build-server.sh` and run with `./server`.

Whenever the client sends a message to the server, the server processes the
string using `Processing.o`, unless the string is `:reload`. When the string is
`:reload`, the server reloads the processing module. The websocket connection
is never closed.

## Usage

``` bash
./build-server.sh
./build-processing.sh
./build-client.sh

./server &
./client
> hi
> You said 'hi'
```

At this point, you can modify `src/Processing.sh`, and call
`./build-processing.sh`. Whenever you send `:reload` to the server (through the
client) the server will reload the processing module while keeping the
connection open.

## Gotchas

The `Processing` module needs to be linked manually. In order to link against
`bytestring`, for instance, you need to find where your bytestring library is
installed (if you are using Stack, try running `stack path --global-pkg-db` and
look around for something called `bytesXXXX.a`). In
[build-processing.sh](build-processing.sh) I load the `bytestring` library from
the environment (I suggest using [direnv](http://direnv.net)).


## Improvements

I'll soon add another example using the
[plugins](https://hackage.haskell.org/package/plugins) package, which also uses
interface files to make sure we are loading consistent code. However, I haven't
figured out how to automatically link against the libraries. Unfortunately,
`cabal` seems to simply use `ghc`, which itself only links if the output
produces an executable (exports a `main` function). Please get in touch if you
have ideas.


