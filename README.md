# swift-image-emboss-www-grpc

A simple gRPC server wrapping the `sfomuseum/swift-image-emboss` package.

## Example

Building the server.

```
$> swift build
...swift stuff happens

[9/9] Emitting module image_emboss_grpc_server
Build complete! (0.76s)

$> ./.build/debug/image-emboss-grpc-server -h
USAGE: image-embosser <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  serve (default)         Starts a image embosser server.
  client                  Post an image to an image embosser server and write the results to disk.

  See 'image-embosser help <subcommand>' for detailed help.
```

### serve(r)

```
$> ./.build/debug/image-emboss-grpc-server serve -h
OVERVIEW: Starts a image embosser server.

USAGE: image-embosser serve [--host <host>] [--port <port>] [--logfile <logfile>] [--verbose <verbose>] [--max_receive_message_length <max_receive_message_length>]

OPTIONS:
  --host <host>           The host name to listen for new connections (default: 127.0.0.1)
  --port <port>           The port to listen on (default: 8080)
  --logfile <logfile>     Log events to system log files (default: false)
  --verbose <verbose>     Enable verbose logging (default: false)
  --max_receive_message_length <max_receive_message_length>
                          Sets the maximum message size in bytes the server may receive. If 0 then the swift-grpc defaults will be used. (default: 0)
  -h, --help              Show help information.
```

_Note: The `--max_receive_message_length` flag is not implemented yet._

Running the server.

```
$> ./.build/debug/image-emboss-grpc-server 
2025-05-06T15:36:58-0700 info org.sfomuseum.image-emboss-grpc-server : [image_emboss_grpc_server] listening for requests on 127.0.0.1:8080
```

_For example output have a look at [the examples in the sfomuseum/go-image-emboss package](https://github.com/sfomuseum/go-image-emboss#examples)._

### client

The `image-emboss-grpc-server` tool has a built-in client command which can be used to for posting messages to the server itself. This command is mostly for debugging and sanity-checking.

```
$> ./.build/debug/image-emboss-grpc-server client -h
OVERVIEW: Post an image to an image embosser server and write the results to disk.

USAGE: image-embosser client [--host <host>] [--port <port>] [--logfile <logfile>] [--verbose <verbose>] --image <image> [--combined <combined>]

OPTIONS:
  --host <host>           The host name to listen for new connections (default: 127.0.0.1)
  --port <port>           The port to listen on (default: 8080)
  --logfile <logfile>     Log events to system log files (default: false)
  --verbose <verbose>     Enable verbose logging (default: false)
  --image <image>         The image file to "emboss"
  --combined <combined>   Return all segements as a single image (default: false)
  -h, --help              Show help information.
```

For example:

```
$> ./.build/debug/image-emboss-grpc-server client --image ./fixtures/1763389317_rdq6ZtWkA93MeI0HeXGL3xzI1svUS6H2_b.jpg 
2025-05-06T15:38:37-0700 info org.sfomuseum.image-emboss-grpc-client : [image_emboss_grpc_server] Emboss image 1763389317_rdq6ZtWkA93MeI0HeXGL3xzI1svUS6H2_b.jpg
2025-05-06T15:38:37-0700 info org.sfomuseum.image-emboss-grpc-client : [image_emboss_grpc_server] Segments for 1763389317_rdq6ZtWkA93MeI0HeXGL3xzI1svUS6H2_b.jpg: 1
2025-05-06T15:38:37-0700 info org.sfomuseum.image-emboss-grpc-client : [image_emboss_grpc_server] Wrote file:/usr/local/sfomuseum/swift-image-emboss-grpc/fixtures/001-1763389317_rdq6ZtWkA93MeI0HeXGL3xzI1svUS6H2_b.jpg
```

## Other clients

* https://github.com/sfomuseum/go-image-emboss

## Definitions

### embosser.proto

* [Sources/image-emboss-grpc-server/embosser.proto](Sources/image-emboss-grpc-server/embosser.proto)

## See also

* https://github.com/sfomuseum/swift-image-emboss
* https://github.com/sfomuseum/swift-image-emboss-cli
* https://github.com/sfomuseum/go-image-emboss
* https://github.com/grpc/grpc-swift
* https://github.com/sfomuseum/swift-sfomuseum-logger
