import ArgumentParser
import Foundation
import GRPCCore
import GRPCNIOTransportHTTP2
import GRPCProtobuf
import Synchronization

import ImageEmboss
import CoreImage
import CoreImageImage

struct Serve: AsyncParsableCommand {
  static let configuration = CommandConfiguration(abstract: "Starts a route-guide server.")

  @Option(help: "The port to listen on")
  var port: Int = 8080

  func run() async throws {
    let transport = HTTP2ServerTransport.Posix(
      address: .ipv4(host: "127.0.0.1", port: self.port),
      transportSecurity: .plaintext
    )

    let server = GRPCServer(transport: transport, services: [ImageEmbosserService()])
      
    try await withThrowingDiscardingTaskGroup { group in
      group.addTask { try await server.serve() }
      let address = try await transport.listeningAddress
      print("server listening on \(address)")
    }
  }
}

struct ImageEmbosserService: ImageEmbosser_ImageEmbosser.SimpleServiceProtocol {
    
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

