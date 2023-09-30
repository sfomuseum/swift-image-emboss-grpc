import GRPC
import NIOCore
import Foundation
import ImageEmboss
import CoreImage
import CoreImageImage

@available(macOS 14.0, iOS 17.0, tvOS 17.0, *)
final class ImageEmbosser: EmbosserAsyncProvider {
  let interceptors: EmbosserServerInterceptorFactoryProtocol? = nil
    
    func embossImage(request: EmbossImageRequest, context: GRPC.GRPCAsyncServerCallContext) async throws -> EmbossImageResponse {
        
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
                // To do: Use swift-log
                print(error)
            }
        }
         
        var ci_im: CIImage

        let im_rsp = CoreImageImage.LoadFromURL(url: temporaryFileURL)
        
        switch im_rsp {
        case .failure(let error):
            throw(error)
        case .success(let im):
            ci_im = im
        }
        
        let te = ImageEmboss()
        let rsp = te.ProcessImage(image: ci_im, combined: request.combined)
         
         switch rsp {
         case .failure(_):
             throw(Errors.processError)
         case .success(let im):
             
             return EmbossImageResponse.with{
                 $0.filename = request.filename
                 // To do: Return a repeatable blob of bytes
                 // $0.body = Data(im)
                 $0.combined = request.combined
             }
             
         }
         
    }
    



}
