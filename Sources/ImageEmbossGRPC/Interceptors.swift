import Foundation
import GRPC

// This is used in conjunction with GRPCServerLogger to append the remote address
// associated with the request to metadata in log messages.

final class ImageEmbosserServerInterceptorFactory: EmbosserServerInterceptorFactoryProtocol {
    
    func makeEmbossImageInterceptors() -> [GRPC.ServerInterceptor<EmbossImageRequest, EmbossImageResponse>] {
        return [ImageEmbosserServerInterceptor()]
    }
}

final class ImageEmbosserServerInterceptor: ServerInterceptor<EmbossImageRequest, EmbossImageResponse> {
    
    override func receive(
      _ part: GRPCServerRequestPart<EmbossImageRequest>,
      context: ServerInterceptorContext<EmbossImageRequest, EmbossImageResponse>
    ) {
        
        switch part {
        case .metadata(var m):
            if context.remoteAddress != nil {
                m.add(name: "remoteAddress", value: context.remoteAddress!.description)
            }
            context.receive(.metadata(m))
        default:
            context.receive(part)
        }
    }
}
