import GRPCCore

import Foundation
import ImageEmboss
import CoreImage
import CoreImageImage

@available(macOS 15.0, *)
struct ImageEmbosserServer: ImageEmbosser.SimpleServiceProtocol {
    
    func embossImage(
        
        request: EmbossImageRequest,
        context: ServerContext
        
    ) async throws -> EmbossImageResponse {
        
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
            
            return EmbossImageResponse.with{
                $0.filename = request.filename
                $0.body = data
                $0.combined = request.combined
            }
            
        }
        
    }
}
