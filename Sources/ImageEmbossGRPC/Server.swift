import Logging
import GRPC
import NIOCore
import NIOPosix
import NIOSSL
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
    
    public func Run(host: String, port: Int, tls_certificate: String?, tls_key: String?) async throws {
        
        self.host = host
        self.port = port
        
      let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
      defer {
        try! group.syncShutdownGracefully()
      }

        let embosser = ImageEmbosser(logger: self.logger, interceptors: ImageEmbosserServerInterceptorFactory())
        
        // To do: Enable support for TLS certificates
        // https://github.com/sfomuseum/swift-text-emboss-grpc/issues/1
      
        var builder: Server.Builder
        
        if tls_certificate != nil && tls_key != nil {
            
            let cert = try NIOSSLCertificate(file: tls_certificate!, format: .pem)
            let key = try NIOSSLPrivateKey(file: tls_key!, format: .pem)
            
            // 'secure(group:certificateChain:privateKey:)' is deprecated: Use one of 'usingTLSBackedByNIOSSL(on:certificateChain:privateKey:)', 'usingTLSBackedByNetworkFramework(on:with:)' or 'usingTLS(with:on:)'
            
            builder = Server.secure(group: group, certificateChain:[cert], privateKey: key)
        } else {
            
            builder = Server.insecure(group: group)
        }
        
      let server = try await builder
            .withServiceProviders([embosser])
            .withLogger(logger)
            .bind(host: self.host, port: self.port)
        .get()

        self.logger.info("server started on port \(server.channel.localAddress!.port!)")

      // Wait on the server's `onClose` future to stop the program from exiting.
      try await server.onClose.get()
    }
}
