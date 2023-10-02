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
USAGE: image-emboss-server [--port <port>]

OPTIONS:
  --port <port>           The port to listen on for new connections (default: 1234)
  -h, --help              Show help information.
```

Running the server.

```
$> ./.build/debug/image-emboss-grpc-server 
2023-09-01T11:48:13-0700 info org.sfomuseum.image-emboss-grpc-server : [image_emboss_grpc_server] server started on port 1234
```

## Clients

* https://github.com/sfomuseum/go-image-emboss

## Definitions

### embosser.proto

* [Sources/image-emboss-grpc-server/embosser.proto](Sources/image-emboss-grpc-server/embosser.proto)

## See also

* https://github.com/sfomuseum/swift-image-emboss
* https://github.com/sfomuseum/swift-image-emboss-cli
* https://github.com/sfomuseum/go-image-emboss
* https://github.com/grpc/grpc-swift
