# swift-image-emboss-www-grpc

A simple gRPC server wrapping the `sfomuseum/swift-image-emboss` package.

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
  --logfile <bool>        Log events to system log files (default: false)
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

## See also

* https://github.com/sfomuseum/swift-image-emboss
* https://github.com/sfomuseum/swift-image-emboss-cli
* https://github.com/sfomuseum/go-image-emboss
* https://github.com/sfomuseum/swift-grpc-server
* https://github.com/grpc/grpc-swift
* https://github.com/sfomuseum/swift-sfomuseum-logger
