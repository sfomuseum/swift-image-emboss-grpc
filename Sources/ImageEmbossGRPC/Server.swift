import Logging
import GRPC
import NIOCore
import NIOPosix
import Logging

@available(macOS 14.0, iOS 17.0, tvOS 17.0, *)
public class GRPCServer {
    
    public var logger: Logger
    public var threads: Int = 1   
    
    var host: String = "localhost"
    var port: Int = 1234
    
    public init(logger: Logger, threads: Int) {
        self.threads = threads
        self.logger = logger
    }
    
    public func Run(host: String, port: Int) async throws {
        
        self.host = host
        self.port = port
        
      let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
      defer {
        try! group.syncShutdownGracefully()
      }

        let embosser = ImageEmbosser(logger: self.logger)
        
      // Start the server and print its address once it has started.
        
        // To do: Enable support for TLS certificates
        // https://github.com/sfomuseum/swift-text-emboss-grpc/issues/1
        
        
      let server = try await Server.insecure(group: group)
            .withServiceProviders([embosser])
            .bind(host: self.host, port: self.port)
        .get()

        self.logger.info("server started on port \(server.channel.localAddress!.port!)")

      // Wait on the server's `onClose` future to stop the program from exiting.
      try await server.onClose.get()
    }
}
