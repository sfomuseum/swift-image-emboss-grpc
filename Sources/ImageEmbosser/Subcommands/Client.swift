import ArgumentParser
import Foundation
import Logging
import GRPCCore
import GRPCNIOTransportHTTP2
import SFOMuseumLogger

struct Client: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Post an image to an image embosser server and write the results to disk.")
    
    @Option(help: "The host name to listen for new connections")
    var host: String = "127.0.0.1"
    
    @Option(help: "The port to listen on")
    var port: Int = 8080
    
    @Option(help: "Log events to system log files")
    var logfile: Bool = false
    
    @Option(help: "Enable verbose logging")
    var verbose: Bool = false
    
    @Option(help: "The image file to \"emboss\"")
    var image: String
    
    @Option(help: "Return all segements as a single image")
    var combined: Bool = false
    
    func run() async throws {
        
        let log_label = "org.sfomuseum.image-emboss-grpc-client"
        
        let logger_opts = SFOMuseumLoggerOptions(
            label: log_label,
            console: true,
            logfile: logfile,
            verbose: verbose
        )
        
        let logger = try NewSFOMuseumLogger(logger_opts)
        
        try await withGRPCClient(
            
            transport: .http2NIOPosix(
                target: .ipv4(host: self.host, port: self.port),
                transportSecurity: .plaintext
            )
            
        ) { client in
            
            let image_url = URL(filePath: image)
            let image_basename = image_url.lastPathComponent
            let body = try Data(contentsOf: image_url)
                        
            logger.info("Emboss image \(image_basename)")
            
            let embosser = ImageEmbosser_ImageEmbosser.Client(wrapping: client)
            
            var req = ImageEmbosser_EmbossImageRequest()
            req.filename = image_basename
            req.body = body
            req.combined = combined
            
            let rsp = try await embosser.embossImage(req)
            
            logger.info("Segments for \(rsp.filename): \(rsp.body.count)")
            
            var i = 0
            
            let root = image_url.absoluteString.replacingOccurrences(of: image_basename, with: "")
            
            for data in rsp.body {
                
                i += 1
                
                let fname = String(format:"%03d-%@", i, rsp.filename)
                let root_url = URL(filePath: root)
                let abs_path = root_url.appendingPathComponent(fname)
                                
                try data.write(to: abs_path)
                logger.info("Wrote \(abs_path.absoluteString)")
            }
        }
        
    }
    
}
