//
//  JSONSerializerTests.swift
//  JSONSerializerTests
//
//  Created by Mikhail Stepkin on 07.04.16.
//  Copyright © 2016 Ramotion. All rights reserved.
//

import XCTest

#if os(OSX)
    @testable import JSONSerializerCocoa
#elseif os(iOS)
    @testable import JSONSerializerTouch
#elseif os(tvOS)
    @testable import JSONSerializerTV
#endif

import Argo

class JSONSerializerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testJSON() {
        self.measureBlock {
            let toTest: [JSON] = [
                JSON.Null,
                JSON.Bool(true),
                JSON.Bool(false),
                JSON.Number(NSNumber(unsignedInt: arc4random())),
                JSON.Array([JSON.Number(NSNumber(unsignedInt: arc4random()))]),
                JSON.Object(["x" : JSON.Number(NSNumber(unsignedInt: arc4random()))])
            ]
            
            toTest.forEach {
                XCTAssertEqual($0, $0.serialize())
            }
        }
    }
    
    func testNull() {
        self.measureBlock {
            let null: Any? = nil
            XCTAssertNil(null)
            
            let serialized = null.serialize()
            XCTAssert(serialized == JSON.Null)
            
            let jsonString = serialized.jsonString
            XCTAssert(jsonString == "null")
            
            let jsonData = serialized.jsonData
            let parsed = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            
            let decoded: Decoded<Int> = decode(parsed)
            XCTAssertNil(decoded.value)
        }
    }
    
    func testNonSerializableOptional() {
        self.measureBlock {
            struct NonSerializableType {}
            
            let opt: NonSerializableType? = NonSerializableType()
            XCTAssertNotNil(opt)
            
            let serialized: JSON = opt.serialize()
            XCTAssertEqual(serialized, JSON.Null)
            
            let jsonString = serialized.jsonString
            XCTAssertEqual(jsonString, "null")
            
            let jsonData = serialized.jsonData
            let parsed = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            
            let decoded: Decoded<Int> = decode(parsed)
            XCTAssertNil(decoded.value)
        }
    }
    
    private struct SerializableType: JSONSerializable, Decodable {
        let int: Int?
        
        private static func decode(json: JSON) -> Decoded<SerializableType> {
            return SerializableType.init
                <^> json <|? "int"
        }
    }
    
    func testSerializableOptional() {
        self.measureBlock {
            let opt: SerializableType = SerializableType(int: Int(arc4random()))
            XCTAssertNotNil(opt)
            
            let serialized: JSON = opt.serialize()
            XCTAssertEqual(serialized, JSON.Object(["int": JSON.Number(opt.int!)]))
            
            let jsonString = serialized.jsonString
            XCTAssertEqual(jsonString, "{\"int\": \(Double(opt.int!))}")
            
            let jsonData = serialized.jsonData
            let parsed = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            
            let decoded: Decoded<SerializableType> = decode(parsed)
            XCTAssertNotNil(decoded.value)
            XCTAssertEqual(decoded.value?.int, opt.int)
        }
    }
    
    func testTrue() {
        self.measureBlock {
            let t = true
            XCTAssertTrue(t)
            
            let serialized = t.serialize()
            XCTAssertEqual(serialized, JSON.Bool(t))
            
            let jsonString = serialized.jsonString
            XCTAssertEqual(jsonString, "true")
            
            let jsonData = serialized.jsonData
            let parsed = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            
            let decoded: Decoded<Bool> = decode(parsed)
            XCTAssertNotNil(decoded.value)
            XCTAssertEqual(decoded.value, t)
        }
    }
    
    func testFalse() {
        self.measureBlock {
            let f = false
            XCTAssertFalse(f)
            
            let serialized = f.serialize()
            XCTAssertEqual(serialized, JSON.Bool(f))
            
            let jsonString = serialized.jsonString
            XCTAssertEqual(jsonString, "false")
            
            let jsonData = serialized.jsonData
            let parsed = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            
            let decoded: Decoded<Bool> = decode(parsed)
            XCTAssertNotNil(decoded.value)
            XCTAssertEqual(decoded.value, f)
        }
    }
    
    func testString() {
        self.measureBlock {
            let string = String(arc4random())
            
            let serialized = string.serialize()
            XCTAssertEqual(serialized, JSON.String(string))
            
            let jsonString = serialized.jsonString
            XCTAssertEqual(jsonString, "\"\(string)\"")
            
            let jsonData = serialized.jsonData
            let parsed = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            
            let decoded: Decoded<String> = decode(parsed)
            XCTAssertNotNil(decoded.value)
            XCTAssertEqual(decoded.value, string)
        }
    }
    
    func testInt() {
        self.measureBlock {
            let int = Int(arc4random())
            
            let serialized = int.serialize()
            XCTAssertEqual(serialized, JSON.Number(int))
            
            let jsonString = serialized.jsonString
            XCTAssertEqual(jsonString, String(Double(int)))
            
            let jsonData = serialized.jsonData
            let parsed = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            
            let decoded: Decoded<Int> = decode(parsed)
            XCTAssertNotNil(decoded.value)
            XCTAssertEqual(decoded.value, int)
        }
    }
    
    func testIntMax() {
        self.measureBlock {
            let int = IntMax(arc4random())
            
            let serialized = int.serialize()
            XCTAssertEqual(serialized, JSON.String(String(int)))
            
            let jsonString = serialized.jsonString
            XCTAssertEqual(jsonString, "\"\(String(int))\"")
            
            let jsonData = serialized.jsonData
            let parsed = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            
            let decoded: Decoded<IntMax> = decode(parsed)
            XCTAssertNotNil(decoded.value)
            XCTAssertEqual(decoded.value, int)
        }
    }
    
    func testUInt() {
        self.measureBlock {
            let uint = UInt(arc4random())
            
            let serialized = uint.serialize()
            XCTAssertEqual(serialized, JSON.Number(uint))
            
            let jsonString = serialized.jsonString
            XCTAssertEqual(jsonString, String(Double(uint)))
            
            let jsonData = serialized.jsonData
            let parsed = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            
            let decoded: Decoded<Int> = decode(parsed)
            XCTAssertNotNil(decoded.value)
            XCTAssertEqual(decoded.value, Int(uint))
        }
    }
    
    func testUIntMax() {
        self.measureBlock {
            let uint = UIntMax(arc4random())
            
            let serialized = uint.serialize()
            XCTAssertEqual(serialized, JSON.String(String(uint)))
            
            let jsonString = serialized.jsonString
            XCTAssertEqual(jsonString, "\"\(String(uint))\"")
            
            let jsonData = serialized.jsonData
            let parsed = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            
            let decoded: Decoded<IntMax> = decode(parsed)
            XCTAssertNotNil(decoded.value)
            XCTAssertEqual(decoded.value, IntMax(uint))
        }
    }
    
    func testFloat() {
        self.measureBlock {
            let float = Float(arc4random())
            
            let serialized = float.serialize()
            XCTAssertEqual(serialized, JSON.Number(float))
            
            let jsonString = serialized.jsonString
            XCTAssertEqual(jsonString, String(Double(float)))
            
            let jsonData = serialized.jsonData
            let parsed = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            
            let decoded: Decoded<Float> = decode(parsed)
            XCTAssertNotNil(decoded.value)
            XCTAssertEqual(decoded.value, float)
        }
    }
    
    func testDouble() {
        self.measureBlock {
            let double = Double(arc4random())
            
            let serialized = double.serialize()
            XCTAssertEqual(serialized, JSON.Number(double))
            
            let jsonString = serialized.jsonString
            XCTAssertEqual(jsonString, String(double))
            
            let jsonData = serialized.jsonData
            let parsed = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            
            let decoded: Decoded<Double> = decode(parsed)
            XCTAssertNotNil(decoded.value)
            XCTAssertEqual(decoded.value, double)
        }
    }
    
    #if arch(x86_64) || arch(i386)
    func testFloat80() {
        self.measureBlock {
            let float = Float80(arc4random())
            
            let serialized = float.serialize()
            XCTAssertEqual(serialized, JSON.Number(Double(float)))
            
            let jsonString = serialized.jsonString
            XCTAssertEqual(jsonString, String(Double(float)))
            
            let jsonData = serialized.jsonData
            let parsed = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            
            let decoded: Decoded<Double> = decode(parsed)
            XCTAssertNotNil(decoded.value)
            XCTAssertEqual(decoded.value, Double(float))
        }
    }
    #endif
    
    func testStruct() {
        struct S: JSONSerializable {
            let a: Int
            let b: Double
            let c: String
        }
        
        self.measureBlock {
            let s = S(
                a: Int(arc4random()),
                b: Double(arc4random()),
                c: String(arc4random())
            )
            
            let serialized = s.serialize()
            XCTAssertEqual(serialized, JSON.Object(["a" : JSON.Number(s.a), "b" : JSON.Number(s.b), "c" : JSON.String(s.c)]))
            
            let jsonData = serialized.jsonData
            let parsed = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments) as? NSDictionary
            XCTAssertNotNil(parsed)
            XCTAssertEqual(parsed, ["a": s.a, "b": s.b, "c": s.c])
        }
    }
    
    func testClass() {
        class A {
            let a: Int
            
            init(a: Int) {
                self.a = a
            }
        }
        
        class B: A, JSONSerializable {
            let b: Double
            
            init(a: Int, b: Double) {
                self.b = b
                super.init(a: a)
            }
        }
        
        class C: B {
            let c: String
            
            init(a: Int, b: Double, c: String) {
                self.c = c
                super.init(a: a, b: b)
            }
        }
        
        self.measureBlock {
            let o = C(
                a: Int(arc4random()),
                b: Double(arc4random()),
                c: String(arc4random())
            )
            
            let serialized = o.serialize()
            XCTAssertEqual(serialized, JSON.Object(["a" : JSON.Number(o.a), "b" : JSON.Number(o.b), "c" : JSON.String(o.c)]))
            
            let jsonData = serialized.jsonData
            let parsed = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments) as? NSDictionary
            XCTAssertNotNil(parsed)
            XCTAssertEqual(parsed, ["a": o.a, "b": o.b, "c": o.c])
        }
    }
    
    func testArray() {
        self.measureBlock {
            let count = arc4random_uniform(4096)
            let array = (0 ..< count).reduce([]) { (acc, _) -> [UInt32] in
                let val = arc4random()
                return acc + [val]
            }
            XCTAssert(array.count == Int(count))
            
            let serialized = array.serialize()
            if case let JSON.Array(numbers) = serialized {
                XCTAssertEqual(numbers.count, Int(count))
                XCTAssertEqual(numbers, array.map({ JSON.Number(NSNumber(unsignedInt: $0)) }))
            } else {
                XCTFail()
            }
            
            let jsonData = serialized.jsonData
            let parsed = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            
            let decoded: Decoded<[Double]> = decode(parsed)
            XCTAssertNotNil(decoded.value)
            guard let value = decoded.value else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(value, array.map({Double($0)}))
        }
    }
    
    func testSet() {
        self.measureBlock {
            let count = arc4random_uniform(4096)
            let array = (0 ..< count).reduce([]) { (acc, _) -> [UInt32] in
                let val = arc4random()
                return acc + [val]
            }
            XCTAssert(array.count == Int(count))
            
            let set = Set(array)
            XCTAssert(set.count <= array.count)
            
            let serialized = set.serialize()
            if case let JSON.Array(numbers) = serialized {
                XCTAssertEqual(numbers.count, Int(count))
                XCTAssertEqual(numbers, set.map({ JSON.Number(NSNumber(unsignedInt: $0)) }))
            } else {
                XCTFail()
            }
            
            let jsonData = serialized.jsonData
            let parsed = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            
            let decoded: Decoded<[Double]> = decode(parsed)
            XCTAssertNotNil(decoded.value)
            guard let value = decoded.value else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(value, set.map({Double($0)}))
        }
    }
    
    func testDictionary() {
        self.measureBlock {
            let k = Int(arc4random())
            let v = Int(arc4random())
            let dict: [Int: Int] = [k: v]
            
            let serialized = dict.serialize()
            XCTAssertEqual(serialized, JSON.Object([String(k) : JSON.Number(v)]))
            
            let jsonData = serialized.jsonData
            let parsed = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
            XCTAssertNotNil(parsed)
            
            let decoded: Decoded<[String: Int]> = decodeObject(serialized)
            XCTAssertNotNil(decoded.value)
            XCTAssertEqual(decoded.value!, [String(k): v])
        }
    }
    
}
