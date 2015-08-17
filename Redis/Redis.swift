//
//  Redis.swift
//
//  Copyright © 2015 Roman Roibu. All rights reserved.
//

import Foundation

///
public class Redis<Socket where Socket: SocketType> {
    ///
    private let socket: Socket

    ///
    internal let password: String?

    ///
    internal let database: UInt

    ///
    public init(_ info: ConnectInfo) throws {
        self.socket = Socket(info: info)
        self.password = info.password
        self.database = info.database
        try self.socket.connect()
    }

    ///
    internal func send(command name: String, var args: [String]) throws {
        args.insert(name, atIndex: 0)
        let array = DataType.Array( args.map{ .Bulk($0) } )
        let string = array.toString()

        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            try self.socket.send(data)
        } else {
            throw RedisError.InvalidCommand(name, args: args)
        }
    }

    ///
    internal func recv() throws -> DataType {
        let data = try self.socket.recv()
        let string = NSString(data: data, encoding: NSUTF8StringEncoding) as! String

        if let dataType = self.parseResponse(string) {
            return dataType
        } else {
            throw RedisError.InvalidSeverReply(string, message: "Couldn't parse the reply")
        }
    }

    ///
    private func parseResponse(response: String) -> DataType? {
        let r = response as NSString
        switch r.substringToIndex(1) {
        case "+":
            let string = r.substringFromIndex(1).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            return .String(string)
        default:
            return nil //FIXME
        }
    }
}

///
public enum RedisError: ErrorType {
    case InvalidCommand(String, args: [String])
    case InvalidSeverReply(String?, message: String)
}

///
public protocol RedisType {
    init?(string: String)
    func toString() -> String
}

///
public enum DataType {
    case String(Swift.String)
    case Error(Swift.String)
    case Integer(Swift.Int)
    case Bulk(Swift.String)
    indirect case Array([DataType])
    case Null
    case NullArray
}

///
extension DataType: RedisType {
    public init?(string: Swift.String) {
        return nil //FIXME
    }

    /// In RESP, the type of some data depends on the first byte:
    /// For Simple Strings the first byte of the reply is "+"
    /// For Errors the first byte of the reply is "-"
    /// For Integers the first byte of the reply is ":"
    /// For Bulk Strings the first byte of the reply is "$"
    /// For Arrays the first byte of the reply is "*"
    public func toString() -> Swift.String {
        switch self {
        case .Integer(let x):
            return ":\(x)\r\n"
        case .String(let s):
            return "+\(s)\r\n"
        case .Error(let e):
            return "-\(e)\r\n"
        case .Null:
            return "$-1\r\n"
        case .Bulk(let b):
            return "$\(b.utf8.count)\r\n\(b)\r\n"
        case .NullArray:
            return "*-1\r\n"
        case .Array(let a):
            return a.map{ $0.toString() }.reduce("*\(a.count)\r\n", combine: +)
        }
    }
}
