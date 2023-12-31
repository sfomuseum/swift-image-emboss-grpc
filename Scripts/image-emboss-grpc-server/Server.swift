import ArgumentParser
import ImageEmbossGRPC
import GRPCServer
import SFOMuseumLogger

@available(macOS 14.0, iOS 17.0, tvOS 17.0, *)
@main
struct ImageEmbossServer: AsyncParsableCommand {
    
    @Option(help: "The host name to listen for new connections")
    var host: String = "localhost"
    
    @Option(help: "The port to listen on for new connections")
    var port: Int = 8080
    
    @Option(help: "The number of threads to use for the GRPC server")
    var threads: Int = 1
    
    @Option(help: "Log events to system log files")
    var logfile: Bool = false
    
    @Option(help: "Enable verbose logging")
    var verbose: Bool = false
    
    @Option(help: "The path to a TLS certificate to use for secure connections (optional)")
    var tls_certificate: String?
    
    @Option(help: "The path to a TLS key to use for secure connections (optional)")
    var tls_key: String?
    
    func run() async throws {
        
        let log_label = "org.sfomuseum.text-emboss-grpc-server"
        
        let logger_opts = SFOMuseumLoggerOptions(
            label: log_label,
            console: true,
            logfile: logfile,
            verbose: verbose
        )
        
        let logger = try NewSFOMuseumLogger(logger_opts)
        
        let embosser = NewImageEmbosser(
            logger: logger
        )
        
        let server_opts = GRPCServerOptions(
            host: host,
            port: port,
            threads: threads,
            logger: logger,
            tls_certificate: tls_certificate,
            tls_key: tls_key,
            verbose: verbose
        )
        
        let server = GRPCServer(server_opts)
        try await server.Run([embosser])
    }
}
