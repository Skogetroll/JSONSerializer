import Foundation
import Argo

public protocol Serializable {
    @warn_unused_result
    func serialize() -> [String: Any]
}

public extension Serializable {
    func serialize() -> [String: Any] {
        let mirror = Mirror(reflecting: self)
        return mirror.reflectAll().reduce([:], combine: { (acc, elem) in
            var acc = acc
            let (label, value) = elem
            if
                let label = label,
                let value = value as? Serializable
            {
                acc[label] = value
            }
            return acc
        })
    }
}

// MARK: -

// MARK: - Protocol itself
public protocol JSONSerializable: Serializable {
    @warn_unused_result
    func serialize() -> JSON
}

// MARK: JSON extension
public extension JSON {
    var jsonString: Swift.String {
        switch self {
        case .Null:
            return "null"
        case .String(let string):
            return "\"\(string.shieldCharacters())\""
        case .Bool(let bool):
            return Swift.Bool.jsonValuesMap[bool]!
        case .Number(let number):
            return "\(number.doubleValue)"
        case .Array(let array):
            let string = array.map({ $0.jsonString }).joinWithSeparator(", ")
            return "[\(string)]"
        case .Object(let object):
            let string = object.reduce([], combine: { (acc , elem) -> [Swift.String] in
                let (label, value) = elem
                return acc + ["\"\(label.shieldCharacters())\": \(value.jsonString)"]
            }).joinWithSeparator(", ")
            return "{\(string)}"
        }
    }
    
    var jsonData: NSData {
        return self.jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
    }
}

private extension String {
    func shieldCharacters(characters: [Character] = ["\""]) -> String {
        return (["\\"] + characters).reduce(self) { (string, character) -> String in
            let charString = String(character)
            return string.stringByReplacingOccurrencesOfString(charString, withString: "\\\(charString)")
        }
    }
}

// MARK: - Trivial types

extension JSON: JSONSerializable {
    public func serialize() -> JSON {
        return self
    }
}

// MARK: String
extension String: JSONSerializable {
    public func serialize() -> JSON {
        return JSON.String(self)
    }
}

// MARK: Boolean
extension Bool: JSONSerializable {
    // In case if bool standard description will change to YES/NO or something like that
    private static var jsonValuesMap: [Bool: String] {
        return [
            true: "true",
            false: "false"
        ]
    }
    
    public func serialize() -> JSON {
        return JSON.Bool(self)
    }
}

// MARK: - More complex types
// MARK: FloatingTypes
public protocol DoubleCastable: JSONSerializable {
    func toDouble() -> Double
}

extension Float32: DoubleCastable {
    public func toDouble() -> Double {
        return Double(self)
    }
}

extension Float64: DoubleCastable {
    public func toDouble() -> Double {
        return Double(self)
    }
}

#if arch(x86_64) || arch(i386)
    extension Float80: DoubleCastable {
        public func toDouble() -> Double {
            return Double(self)
        }
    }
#endif

extension Double {
    init(_ castable: DoubleCastable) {
        self = castable.toDouble()
    }
}

extension JSONSerializable where Self: DoubleCastable {
    public func serialize() -> JSON {
        let number = NSNumber(double: Double(self))
        return JSON.Number(number)
    }
}

// MARK: Integer types
extension Int  : JSONSerializable {}
extension Int8 : JSONSerializable {}
extension Int16: JSONSerializable {}
extension Int32: JSONSerializable {}
extension Int64: JSONSerializable {
    public func serialize() -> JSON {
        return JSON.String(String(self))
    }
}

extension UInt  : JSONSerializable {}
extension UInt8 : JSONSerializable {}
extension UInt16: JSONSerializable {}
extension UInt32: JSONSerializable {}
extension UInt64: JSONSerializable {
    public func serialize() -> JSON {
        return JSON.String(String(self))
    }
}

extension JSONSerializable where Self: IntegerType {
    public func serialize() -> JSON {
        // JSON numbers are doubles
        let number = NSNumber(double: Double(self.toIntMax()))
        return JSON.Number(number)
    }
}

// MARK: - Containers
// MARK: Optional serializable
extension Optional where Wrapped: JSONSerializable {
    func serialize() -> JSON {
        switch self {
        case .None:
            return JSON.Null
        case .Some(let serializable):
            return serializable.serialize()
        }
    }
}

extension Optional: JSONSerializable {
    public func serialize() -> JSON {
        switch self {
        case .None:
            return JSON.Null
        case .Some(let wrapped):
            if let serializable = wrapped as? JSONSerializable {
                return serializable.serialize()
            }
            else {
                return JSON.Null
            }
        }
    }
}

// MARK: Sequence or serializables
extension SequenceType where Generator.Element: JSONSerializable {
    func serialize() -> JSON {
        let mapped = self.map({ $0.serialize() })
        return JSON.Array(mapped)
    }
}

extension Array: JSONSerializable {
    public func serialize() -> JSON {
        let mapped = self.map({ ($0 as? JSONSerializable).serialize() })
        return JSON.Array(mapped)
    }
}

extension Set: JSONSerializable {
    public func serialize() -> JSON {
        return Array(self).serialize()
    }
}

extension Dictionary: JSONSerializable {
    public func serialize() -> JSON {
        let reduced: [String: JSON] = self.reduce([:], combine: { (acc, elem) in
            var acc = acc
            let (label, value) = elem
            if let serialisable = value as? JSONSerializable {
                acc["\(label)"] = serialisable.serialize()
            }
            return acc
        })
        return JSON.Object(reduced)
    }
}

// MARK: - Generic struct serialization
private extension Mirror {
    func reflectAll() -> [Mirror.Child] {
        if let supermirror = self.superclassMirror() {
            return supermirror.reflectAll().map({$0}) + self.children.map({$0})
        }
        else {
            return self.children.map({$0})
        }
    }
}

public extension JSONSerializable {
    func serialize() -> JSON {
        let mirror = Mirror(reflecting: self)
        let fields: [String: JSON] = mirror.reflectAll().reduce([:]) { (acc, elem) in
            var acc = acc
            let (label, value) = elem
            if let label = label {
                if let value = value as? JSONSerializable {
                    acc[label] = value.serialize()
                }
                else {
                    #if ShadowSerializationEnabled
                        if let shadow = shadowSerialization(value) {
                            acc[label] = shadow
                        }
                    #endif
                }
            }
            return acc
        }
        
        return JSON.Object(fields)
    }
}

#if ShadowSerializationEnabled
    private func shadowSerialization(object: Any) -> JSON? {
        let mirror = Mirror(reflecting: object)
        if let displayStyle = mirror.displayStyle {
            switch displayStyle {
            case .Dictionary, .Class, .Struct:
                let reduced = mirror.reflectAll().reduce([:], combine: { (acc, elem) -> [String: Any] in
                    var acc = acc
                    let (label, value) = elem
                    if let label = label {
                        acc[label] = value
                    }
                    return acc
                })
                let serialized = reduced.serialize()
                return serialized
            case .Tuple, .Collection, .Set:
                let array = mirror.reflectAll().map({ $1 })
                let serialized = array.serialize()
                return serialized
            case .Enum:
                let reduced = mirror.reflectAll().reduce([:], combine: { (acc, elem) -> [String: Any] in
                    var acc = acc
                    let (label, value) = elem
                    if let label = label
                    {
                        if let value = value as? JSONSerializable {
                            acc[label] = value.serialize()
                        }
                        else if let shadow = shadowSerialization(value) {
                            acc[label] = shadow
                        }
                    }
                    return acc
                })
                if reduced.isEmpty {
                    return String(object).serialize()
                }
                else {
                    let serialized = reduced.serialize()
                    return serialized
                }
            case .Optional:
                return (object as? JSONSerializable).serialize() ?? JSON.Null
            }
        }
        return nil
    }
#endif