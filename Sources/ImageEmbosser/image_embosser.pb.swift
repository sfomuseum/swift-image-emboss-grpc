// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: image_embosser/image_embosser.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

public struct OrgSfomuseumImageEmbosser_EmbossImageRequest: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var filename: String = String()

  public var body: Data = Data()

  public var combined: Bool = false

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct OrgSfomuseumImageEmbosser_EmbossImageResponse: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var filename: String = String()

  public var body: [Data] = []

  public var combined: Bool = false

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "org_sfomuseum_image_embosser"

extension OrgSfomuseumImageEmbosser_EmbossImageRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".EmbossImageRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "Filename"),
    2: .same(proto: "Body"),
    3: .same(proto: "Combined"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.filename) }()
      case 2: try { try decoder.decodeSingularBytesField(value: &self.body) }()
      case 3: try { try decoder.decodeSingularBoolField(value: &self.combined) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.filename.isEmpty {
      try visitor.visitSingularStringField(value: self.filename, fieldNumber: 1)
    }
    if !self.body.isEmpty {
      try visitor.visitSingularBytesField(value: self.body, fieldNumber: 2)
    }
    if self.combined != false {
      try visitor.visitSingularBoolField(value: self.combined, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: OrgSfomuseumImageEmbosser_EmbossImageRequest, rhs: OrgSfomuseumImageEmbosser_EmbossImageRequest) -> Bool {
    if lhs.filename != rhs.filename {return false}
    if lhs.body != rhs.body {return false}
    if lhs.combined != rhs.combined {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension OrgSfomuseumImageEmbosser_EmbossImageResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".EmbossImageResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "Filename"),
    2: .same(proto: "Body"),
    3: .same(proto: "Combined"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.filename) }()
      case 2: try { try decoder.decodeRepeatedBytesField(value: &self.body) }()
      case 3: try { try decoder.decodeSingularBoolField(value: &self.combined) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.filename.isEmpty {
      try visitor.visitSingularStringField(value: self.filename, fieldNumber: 1)
    }
    if !self.body.isEmpty {
      try visitor.visitRepeatedBytesField(value: self.body, fieldNumber: 2)
    }
    if self.combined != false {
      try visitor.visitSingularBoolField(value: self.combined, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: OrgSfomuseumImageEmbosser_EmbossImageResponse, rhs: OrgSfomuseumImageEmbosser_EmbossImageResponse) -> Bool {
    if lhs.filename != rhs.filename {return false}
    if lhs.body != rhs.body {return false}
    if lhs.combined != rhs.combined {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
