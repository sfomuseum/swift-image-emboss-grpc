import ArgumentParser
import Foundation
import Logging
import GRPCCore
import GRPCNIOTransportHTTP2
import GRPCProtobuf
import Synchronization

import ImageEmboss
import CoreImage
import CoreImageImage
import SFOMuseumLogger

struct Serve: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Starts a image embosser server.")
    
    @Option(help: "The host name to listen for new connections")
    var host: String = "localhost"
    
    @Option(help: "The port to listen on")
    var port: Int = 8080
    
    @Option(help: "Log events to system log files")
    var logfile: Bool = false
    
    @Option(help: "Enable verbose logging")
    var verbose: Bool = false
    
    @Option(help: "Sets the maximum message size in bytes the server may receive. If 0 then the swift-grpc defaults will be used.")
    var max_receive_message_length = 0
    
    func run() async throws {
        
        let log_label = "org.sfomuseum.image-emboss-grpc-server"
        
        let logger_opts = SFOMuseumLoggerOptions(
            label: log_label,
            console: true,
            logfile: logfile,
            verbose: verbose
        )
        
        let logger = try NewSFOMuseumLogger(logger_opts)
        
        let service = ImageEmbosserService(logger: logger)
        
        let transport = HTTP2ServerTransport.Posix(
            address: .ipv4(host: self.host, port: self.port),
            transportSecurity: .plaintext
        )
        
        
        let server = GRPCServer(transport: transport, services: [service])
        
        try await withThrowingDiscardingTaskGroup { group in
            group.addTask { try await server.serve() }
            let address = try await transport.listeningAddress
            print("server listening on \(address)")
        }
    }
}

struct ImageEmbosserService: ImageEmbosser_ImageEmbosser.SimpleServiceProtocol {
    
    let logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    func embossImage(request: ImageEmbosser_EmbossImageRequest, context: GRPCCore.ServerContext) async throws -> ImageEmbosser_EmbossImageResponse {
        
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                                        isDirectory: true)
        
        let temporaryFilename = ProcessInfo().globallyUniqueString
        
        let temporaryFileURL =
        temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
        
        try request.body.write(to: temporaryFileURL,
                               options: .atomic)
        
        defer {
            do {
                try FileManager.default.removeItem(at: temporaryFileURL)
            } catch {
                // self.logger.error("Failed to remove temporary file at \(temporaryFileURL), \(error)")
            }
            
        }
        
        var ci_im: CIImage
        
        let im_rsp = CoreImageImage.LoadFromURL(url: temporaryFileURL)
        
        switch im_rsp {
        case .failure(let error):
            // self.logger.error("Failed to load image from \(temporaryFileURL), \(error)")
            throw(error)
        case .success(let im):
            ci_im = im
        }
        
        let te = ImageEmboss()
        let rsp = te.ProcessImage(image: ci_im, combined: request.combined)
        
        switch rsp {
        case .failure(let error):
            // self.logger.error("Failed to process image from \(temporaryFileURL), \(error)")
            throw(error)
        case .success(let im_rsp):
            
            var data = [Data]()
            
            for im in im_rsp {
                
                let png_rsp = CoreImageImage.AsPNGData(image: im)
                
                switch png_rsp {
                case .failure(let png_err):
                    // self.logger.error("Failed to derive PNG from from \(temporaryFileURL) (processed), \(png_err)")
                    throw(png_err)
                case .success(let png_data):
                    data.append(png_data)
                }
            }
            
            // self.logger.info("Successfully processed \(temporaryFileURL)")
            
            return ImageEmbosser_EmbossImageResponse.with{
                $0.filename = request.filename
                $0.body = data
                $0.combined = request.combined
            }
            
        }
        
    }
}

