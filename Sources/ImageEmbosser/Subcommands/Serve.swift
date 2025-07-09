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
    var host: String = "127.0.0.1"
    
    @Option(help: "The port to listen on")
    var port: Int = 8080
    
    @Option(help: "Log events to system log files")
    var logfile: Bool = false
    
    @Option(help: "Enable verbose logging")
    var verbose: Bool = false
        
    @Option(help: "The TLS certificate chain to use for encrypted connections")
    var tls_certificate: String = ""
    
    @Option(help: "The TLS private key to use for encrypted connections")
    var tls_key: String = ""
    
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
               
        var transportSecurity = HTTP2ServerTransport.Posix.TransportSecurity.plaintext
        
        // https://github.com/grpc/grpc-swift/issues/2219
        
        if tls_certificate != "" && tls_key != ""  {
            
            let certSource:  TLSConfig.CertificateSource   = .file(path: tls_certificate, format: .pem)
            let keySource:   TLSConfig.PrivateKeySource    = .file(path: tls_key, format: .pem)
            
            transportSecurity = HTTP2ServerTransport.Posix.TransportSecurity.tls(
                certificateChain: [ certSource ],
                privateKey: keySource,
            )
        }
        
        // Keepalive configs necessary because this:
        // https://github.com/grpc/grpc-swift-2/issues/5#issuecomment-2984421768
        
        // https://github.com/grpc/grpc-swift-nio-transport/blob/15f9bfee04d19c1d720f34c6c6b3e8214bf557db/Sources/GRPCNIOTransportCore/Server/HTTP2ServerTransport.swift#L85
        
        let client_keepalive = HTTP2ServerTransport.Config.ClientKeepaliveBehavior.init(
            // Default is 300 (5 minutes)
            minPingIntervalWithoutCalls: .seconds(1),
            // Default is false
            allowWithoutCalls: true
        )
        
        // https://github.com/grpc/grpc-swift-nio-transport/blob/15f9bfee04d19c1d720f34c6c6b3e8214bf557db/Sources/GRPCNIOTransportCore/Server/HTTP2ServerTransport.swift#L52
        
        var server_keepalive = HTTP2ServerTransport.Config.Keepalive.defaults
        server_keepalive.clientBehavior = client_keepalive
        
        let transport = HTTP2ServerTransport.Posix(
            address: .ipv4(host: self.host, port: self.port),
            transportSecurity: transportSecurity,
            config: .defaults { config in
                if max_receive_message_length > 0 {
                    config.rpc.maxRequestPayloadSize = max_receive_message_length
                }
                config.connection.keepalive = server_keepalive
              }
        )

        
        let service = ImageEmbosserService(logger: logger)
        let server = GRPCServer(transport: transport, services: [service])
                
        try await withThrowingDiscardingTaskGroup { group in
            // Why does this time out?
            // let address = try await transport.listeningAddress
            logger.info("listening for requests on \(self.host):\(self.port)")
            group.addTask { try await server.serve() }
        }
    }
}

struct ImageEmbosserService: OrgSfomuseumImageEmbosser_ImageEmbosser.SimpleServiceProtocol {
    
    var logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    func  embossImage(request: OrgSfomuseumImageEmbosser_EmbossImageRequest, context: GRPCCore.ServerContext) async throws -> OrgSfomuseumImageEmbosser_EmbossImageResponse {
        
        var metadata: Logger.Metadata
        metadata = [ "remote": "\(context.remotePeer)" ]
        
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
                self.logger.error(
                    "Failed to remove temporary file at \(temporaryFileURL), \(error)",
                    metadata: metadata,
                )
            }
        }
        
        var ci_im: CIImage
        
        let im_rsp = CoreImageImage.LoadFromURL(url: temporaryFileURL)
        
        switch im_rsp {
        case .failure(let error):
            self.logger.error(
                "Failed to load image from \(temporaryFileURL), \(error)",
                metadata: metadata
                )
            throw(error)
        case .success(let im):
            ci_im = im
        }
        
        let te = ImageEmboss()
        let rsp = te.ProcessImage(image: ci_im, combined: request.combined)
        
        switch rsp {
        case .failure(let error):
            self.logger.error(
                "Failed to process image from \(temporaryFileURL), \(error)",
                metadata: metadata
            )
            throw(error)
        case .success(let im_rsp):
            
            var data = [Data]()
            
            for im in im_rsp {
                
                let png_rsp = CoreImageImage.AsPNGData(image: im)
                
                switch png_rsp {
                case .failure(let png_err):
                    self.logger.error(
                        "Failed to derive PNG from from \(temporaryFileURL) (processed), \(png_err)",
                        metadata: metadata
                    )
                    throw(png_err)
                case .success(let png_data):
                    data.append(png_data)
                }
            }
                        
            self.logger.info(
                "Successfully processed \(temporaryFileURL) segments \(data.count)",
                metadata: metadata
            )
            
            let rsp = OrgSfomuseumImageEmbosser_EmbossImageResponse.with{
                $0.filename = request.filename
                $0.body = data
                $0.combined = request.combined
            }
            
            return rsp
        }
        
    }
}

