//
//  DataTypeTests.swift
//
//  Copyright © 2015 Roman Roibu. All rights reserved.
//

import XCTest
@testable import Redis

class DataTypeTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInteger() {
        XCTAssertEqual(DataType.Integer(0).toString(), ":0\r\n")
        XCTAssertEqual(DataType.Integer(1000).toString(), ":1000\r\n")
    }
    
    func testString() {
        XCTAssertEqual(DataType.String("").toString(), "+\r\n")
        XCTAssertEqual(DataType.String("OK").toString(), "+OK\r\n")
    }

    func testError() {
        XCTAssertEqual(DataType.Error("ERR unknown command 'foobar'").toString(), "-ERR unknown command 'foobar'\r\n")
        XCTAssertEqual(DataType.Error("WRONGTYPE Operation against a key holding the wrong kind of value").toString(), "-WRONGTYPE Operation against a key holding the wrong kind of value\r\n")
    }

    func testNull() {
        XCTAssertEqual(DataType.Null.toString(), "$-1\r\n")
    }

    func testBulk() {
        XCTAssertEqual(DataType.Bulk("").toString(), "$0\r\n\r\n")
        XCTAssertEqual(DataType.Bulk("foobar").toString(), "$6\r\nfoobar\r\n")
    }
    
    func testNullArray() {
        XCTAssertEqual(DataType.NullArray.toString(), "*-1\r\n")
    }

    func testArray() {
        XCTAssertEqual(DataType.Array([]).toString(), "*0\r\n")
        XCTAssertEqual(DataType.Array([.Bulk("foo"), .Bulk("bar")]).toString(), "*2\r\n$3\r\nfoo\r\n$3\r\nbar\r\n")

        let nestedArray: [DataType] = [
            .Array([
                .Integer(1),
                .Integer(2),
                .Integer(3),
            ]),
            .Array([
                .String("Foo"),
                .Error("ERR Bar")
            ])
        ]
        let string =    "*2\r\n" +
                            "*3\r\n" +
                                ":1\r\n" +
                                ":2\r\n" +
                                ":3\r\n" +
                            "*2\r\n" +
                                "+Foo\r\n" +
                                "-ERR Bar\r\n"

        XCTAssertEqual(DataType.Array(nestedArray).toString(), string)
    }
}
