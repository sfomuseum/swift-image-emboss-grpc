import Logging
import GRPC

// This package exists to account for the fact that the only way to call self.logger[metadataKey...]
// on a plain vanilla Logging.Logger instance is to make it a var which triggers this error:
// Stored property 'logger' of 'Sendable'-conforming class 'ImageEmbosser' has non-sendable type 'GRPCServerLogger'
// So instead we create a bespoke class that is marked as @unchecked Sendable. This is unsatisfying
// in part because I thought that these warning had been addressed in swift-log but I also think I
// don't know what I don't know about Sendable yet so this will have to do for the time being. 
// https://github.com/apple/swift-log/issues/216
// https://github.com/apple/swift-log/pull/218

@available(macOS 10.15, *)
class GRPCServerLogger: @unchecked Sendable {
    internal var logger: Logger
    
    internal init(logger: Logger){
        self.logger = logger
    }
    
    internal func setRemoteAddress(context: GRPC.GRPCAsyncServerCallContext) {
        
        var remote_addr = "unknown"
        
        let headers = context.request.headers
        
        if headers.first(name: "remoteAddress") != nil {
            remote_addr = headers.first(name: "remoteAddress")!
        }
        
        self.logger[metadataKey: "remote-address"] = "\(remote_addr)"
    }
    
    internal func trace(_ message: Logger.Message){
        self.logger.trace(message)
    }
    
    internal func debug(_ message: Logger.Message){
        self.logger.debug(message)
    }

    internal func info(_ message: Logger.Message){
        self.logger.info(message)
    }
    
    internal func notice(_ message: Logger.Message){
        self.logger.notice(message)
    }
    
    internal func warning(_ message: Logger.Message){
        self.logger.warning(message)
    }

    internal func error(_ message: Logger.Message){
        self.logger.error(message)
    }
    
    internal func critical(_ message: Logger.Message){
        self.logger.critical(message)
    }
}
