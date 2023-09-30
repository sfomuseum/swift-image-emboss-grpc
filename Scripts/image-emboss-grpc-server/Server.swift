import ArgumentParser
import Logging
import ImageEmbossGRPC

@available(macOS 10.15, *)
@main
struct ImageEmbossServer: AsyncParsableCommand {
    
    @Option(help: "The host name to listen for new connections")
    var host = "localhost"
    
    @Option(help: "The port to listen on for new connections")
    var port = 1234

  func run() async throws {

      let logger = Logger(label: "org.sfomuseum.image-emboss-grpc-server")
      let threads = 1
      
      let s = ImageEmbossGRPC.GRPCServer(logger: logger, threads: threads)
      try await s.Run(host: host, port: port)

  }
}
