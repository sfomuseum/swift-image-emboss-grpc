import ArgumentParser
import Logging
import ImageEmbossGRPC
import GRPCServer
import Puppy
import Foundation

struct LogFormatter: LogFormattable {
    private let dateFormat = DateFormatter()

    init() {
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    }

    func formatMessage(_ level: LogLevel, message: String, tag: String, function: String,
                       file: String, line: UInt, swiftLogInfo: [String : String],
                       label: String, date: Date, threadID: UInt64) -> String {
        let date = dateFormatter(date, withFormatter: dateFormat)
        let fileName = fileName(file)
        let moduleName = moduleName(file)
        return "\(date) \(threadID) [\(level)] \(swiftLogInfo) \(moduleName)/\(fileName)#L.\(line) \(function) \(message)"
    }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, *)
@main
struct ImageEmbossServer: AsyncParsableCommand {
    
    @Option(help: "The host name to listen for new connections")
    var host = "localhost"
    
    @Option(help: "The port to listen on for new connections")
    var port = 1234

    @Option(help: "The number of threads to use for the GRPC server")
    var threads = 1

    @Option(help: "Write logs to specific log file (optional)")
    var log_file: String?
    
    @Option(help: "Enable verbose logging")
    var verbose = false
    
    @Option(help: "The path to a TLS certificate to use for secure connections (optional)")
    var tls_certificate: String?
    
    @Option(help: "The path to a TLS key to use for secure connections (optional)")
    var tls_key: String?
    
  func run() async throws {

    let log_label = "org.sfomuseum.image-emboss-grpc-server"
    let log_format = LogFormatter()
      
      // This does not work (yet) as advertised. Specifically only
      // the first handler added to puppy ever gets invoked. Dunno...
      
      var puppy = Puppy()

      if log_file != nil {
          
          let log_url = URL(fileURLWithPath: log_file!).absoluteURL
          
          let rotationConfig = RotationConfig(suffixExtension: .numbering,
                                              maxFileSize: 30 * 1024 * 1024,
                                              maxArchivedFilesCount: 5)
          
          let fileRotation = try FileRotationLogger(log_label,
                                                    logFormat: log_format,
                                                    fileURL: log_url,
                                                    rotationConfig: rotationConfig
          )
          
          puppy.add(fileRotation)
      }
      
      // See notes above
      
      let console = ConsoleLogger(log_label, logFormat: log_format)
      puppy.add(console)
      
      LoggingSystem.bootstrap {
          
          var handler = PuppyLogHandler(label: $0, puppy: puppy)
          handler.logLevel = .info
          
          if verbose {
              handler.logLevel = .trace
          }
          
          return handler
      }
      
      let logger = Logger(label: log_label)
      
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
