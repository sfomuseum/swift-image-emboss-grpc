# swift-image-emboss-www-grpc

A simple gRPC server wrapping the `sfomuseum/swift-image-emboss` package.

## Important

This package has only minimal error reporting and validation. It has no authentication or authorization hooks.

## Example

Building the server.

```
$> swift build
Building for debugging...
[9/9] Emitting module image_emboss_grpc_server
Build complete! (0.76s)
```

Server start-up options.

```
$> ./.build/debug/image-emboss-grpc-server -h
USAGE: image-emboss-server [--host <host>] [--port <port>] [--threads <threads>] [--log_file <log_file>] [--verbose <verbose>] [--tls_certificate <tls_certificate>] [--tls_key <tls_key>]

OPTIONS:
  --host <host>           The host name to listen for new connections (default: localhost)
  --port <port>           The port to listen on for new connections (default: 1234)
  --threads <threads>     The number of threads to use for the GRPC server (default: 1)
  --log_file <log_file>   Write logs to specific log file (optional)
  --verbose <verbose>     Enable verbose logging (default: false)
  --tls_certificate <tls_certificate>
                          The path to a TLS certificate to use for secure connections (optional)
  --tls_key <tls_key>     The path to a TLS key to use for secure connections (optional)
  -h, --help              Show help information.
```

Running the server.

```
$> ./.build/debug/image-emboss-grpc-server 
2023-09-01T11:48:13-0700 info org.sfomuseum.image-emboss-grpc-server : [image_emboss_grpc_server] server started on port 1234
```

_For example output have a look at [the examples in the sfomuseum/go-image-emboss package](https://github.com/sfomuseum/go-image-emboss#examples)._

## Clients

* https://github.com/sfomuseum/go-image-emboss

## Definitions

### embosser.proto

* [Sources/image-emboss-grpc-server/embosser.proto](Sources/image-emboss-grpc-server/embosser.proto)

## Known-knowns

### Logging

Under the hood this package uses the [Puppy](https://github.com/sushichop/Puppy) library for logging to both the console and a rotating log file. There is an open ticket to (hopefully) address a problem where messages are only dispatched to the first logger. In this instance that means messages are dispatched to an optional log file and then the console meaning if you specify a `--log_file` flag logging message _will not_ be dispatched to the console.

* https://github.com/sushichop/Puppy/issues/89

## See also

* https://github.com/sfomuseum/swift-image-emboss
* https://github.com/sfomuseum/swift-image-emboss-cli
* https://github.com/sfomuseum/go-image-emboss
* https://github.com/sfomuseum/swift-grpc-server
* https://github.com/grpc/grpc-swift
