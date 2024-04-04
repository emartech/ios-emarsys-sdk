//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

@SdkActor
enum Json: Codable, Equatable {
    
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String: Json])
    case array([Json])
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode([String: Json].self) {
            self = .object(value)
        } else if let value = try? container.decode([Json].self) {
            self = .array(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode Json value")
        }
    }
    
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .int(let value): try container.encode(value)
        case .double(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .object(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        }
    }
}
