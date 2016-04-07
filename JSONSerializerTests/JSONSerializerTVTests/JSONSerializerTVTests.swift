//
//  JSONSerializerTVTests.swift
//  JSONSerializerTVTests
//
//  Created by Mikhail Stepkin on 07.04.16.
//  Copyright © 2016 Ramotion. All rights reserved.
//

import XCTest
@testable import JSONSerializerTV

import Argo

class JSONSerializerTVTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testJSON() {
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
    
    func testNull() throws {
        let null: Any? = nil
        XCTAssertNil(null)
        
        let serialized = null.serialize()
        XCTAssert(serialized == JSON.Null)
        
        let jsonString = serialized.jsonString
        XCTAssert(jsonString == "null")
        
        let jsonData = serialized.jsonData
        let parsed = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
        
        let decoded: Decoded<Int> = decode(parsed)
        XCTAssertNil(decoded.value)
    }
    
    func testNonSerializableOptional() throws {
        struct NonSerializableType {}
        
        let opt: NonSerializableType? = NonSerializableType()
        XCTAssertNotNil(opt)
        
        let serialized: JSON = opt.serialize()
        XCTAssertEqual(serialized, JSON.Null)
        
        let jsonString = serialized.jsonString
        XCTAssertEqual(jsonString, "null")
        
        let jsonData = serialized.jsonData
        let parsed = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
        
        let decoded: Decoded<Int> = decode(parsed)
        XCTAssertNil(decoded.value)
    }
    
    struct SerializableType: JSONSerializable, Decodable {
        let int: Int?
        
        internal static func decode(json: JSON) -> Decoded<SerializableType> {
            return SerializableType.init
                <^> json <|? "int"
        }
    }
    
    func testSerializableOptional() throws {
        let opt: SerializableType = SerializableType(int: Int(arc4random()))
        XCTAssertNotNil(opt)
        
        let serialized: JSON = opt.serialize()
        XCTAssertEqual(serialized, JSON.Object(["int": JSON.Number(opt.int!)]))
        
        let jsonString = serialized.jsonString
        XCTAssertEqual(jsonString, "{\"int\": \(Double(opt.int!))}")
        
        let jsonData = serialized.jsonData
        let parsed = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
        
        let decoded: Decoded<SerializableType> = decode(parsed)
        XCTAssertNotNil(decoded.value)
        XCTAssertEqual(decoded.value?.int, opt.int)
    }
    
    func testTrue() throws {
        let t = true
        XCTAssertTrue(t)
        
        let serialized = t.serialize()
        XCTAssertEqual(serialized, JSON.Bool(t))
        
        let jsonString = serialized.jsonString
        XCTAssertEqual(jsonString, "true")
        
        let jsonData = serialized.jsonData
        let parsed = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
        
        let decoded: Decoded<Bool> = decode(parsed)
        XCTAssertNotNil(decoded.value)
        XCTAssertEqual(decoded.value, t)
    }
    
    func testFalse() throws {
        let f = false
        XCTAssertFalse(f)
        
        let serialized = f.serialize()
        XCTAssertEqual(serialized, JSON.Bool(f))
        
        let jsonString = serialized.jsonString
        XCTAssertEqual(jsonString, "false")
        
        let jsonData = serialized.jsonData
        let parsed = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
        
        let decoded: Decoded<Bool> = decode(parsed)
        XCTAssertNotNil(decoded.value)
        XCTAssertEqual(decoded.value, f)
    }
    
    func testString() throws {
        let string = String(arc4random())
        
        let serialized = string.serialize()
        XCTAssertEqual(serialized, JSON.String(string))
        
        let jsonString = serialized.jsonString
        XCTAssertEqual(jsonString, "\"\(string)\"")
        
        let jsonData = serialized.jsonData
        let parsed = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
        
        let decoded: Decoded<String> = decode(parsed)
        XCTAssertNotNil(decoded.value)
        XCTAssertEqual(decoded.value, string)
    }
    
    func testInt() throws {
        let int = Int(arc4random())
        
        let serialized = int.serialize()
        XCTAssertEqual(serialized, JSON.Number(int))
        
        let jsonString = serialized.jsonString
        XCTAssertEqual(jsonString, String(Double(int)))
        
        let jsonData = serialized.jsonData
        let parsed = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
        
        let decoded: Decoded<Int> = decode(parsed)
        XCTAssertNotNil(decoded.value)
        XCTAssertEqual(decoded.value, int)
    }
    
    func testIntMax() throws {
        let int = IntMax(arc4random())
        
        let serialized = int.serialize()
        XCTAssertEqual(serialized, JSON.String(String(int)))
        
        let jsonString = serialized.jsonString
        XCTAssertEqual(jsonString, "\"\(String(int))\"")
        
        let jsonData = serialized.jsonData
        let parsed = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
        
        let decoded: Decoded<IntMax> = decode(parsed)
        XCTAssertNotNil(decoded.value)
        XCTAssertEqual(decoded.value, int)
    }
    
    func testUInt() throws {
        let uint = UInt(arc4random())
        
        let serialized = uint.serialize()
        XCTAssertEqual(serialized, JSON.Number(uint))
        
        let jsonString = serialized.jsonString
        XCTAssertEqual(jsonString, String(Double(uint)))
        
        let jsonData = serialized.jsonData
        let parsed = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
        
        let decoded: Decoded<Int> = decode(parsed)
        XCTAssertNotNil(decoded.value)
        XCTAssertEqual(decoded.value, Int(uint))
    }
    
    func testUIntMax() throws {
        let uint = UIntMax(arc4random())
        
        let serialized = uint.serialize()
        XCTAssertEqual(serialized, JSON.String(String(uint)))
        
        let jsonString = serialized.jsonString
        XCTAssertEqual(jsonString, "\"\(String(uint))\"")
        
        let jsonData = serialized.jsonData
        let parsed = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
        
        let decoded: Decoded<IntMax> = decode(parsed)
        XCTAssertNotNil(decoded.value)
        XCTAssertEqual(decoded.value, IntMax(uint))
    }
    
    func testFloat() throws {
        let float = Float(arc4random())
        
        let serialized = float.serialize()
        XCTAssertEqual(serialized, JSON.Number(float))
        
        let jsonString = serialized.jsonString
        XCTAssertEqual(jsonString, String(Double(float)))
        
        let jsonData = serialized.jsonData
        let parsed = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
        
        let decoded: Decoded<Float> = decode(parsed)
        XCTAssertNotNil(decoded.value)
        XCTAssertEqual(decoded.value, float)
    }
    
    func testDouble() throws {
        let double = Double(arc4random())
        
        let serialized = double.serialize()
        XCTAssertEqual(serialized, JSON.Number(double))
        
        let jsonString = serialized.jsonString
        XCTAssertEqual(jsonString, String(double))
        
        let jsonData = serialized.jsonData
        let parsed = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
        
        let decoded: Decoded<Double> = decode(parsed)
        XCTAssertNotNil(decoded.value)
        XCTAssertEqual(decoded.value, double)
    }
    
    func testArray() throws {
        let count = arc4random_uniform(128)
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
        let parsed = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
        
        let decoded: Decoded<[Double]> = decode(parsed)
        XCTAssertNotNil(decoded.value)
        guard let value = decoded.value else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(value, array.map({Double($0)}))
    }
    
    func testDictionary() throws {
        let k = Int(arc4random())
        let v = Int(arc4random())
        let dict: [Int: Int] = [k: v]
        
        let serialized = dict.serialize()
        XCTAssertEqual(serialized, JSON.Object([String(k) : JSON.Number(v)]))
        
        let jsonData = serialized.jsonData
        let parsed = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
        XCTAssertNotNil(parsed)
        
        let decoded: Decoded<[String: Int]> = decodeObject(serialized)
        XCTAssertNotNil(decoded.value)
        XCTAssertEqual(decoded.value!, [String(k): v])
    }
    
}
