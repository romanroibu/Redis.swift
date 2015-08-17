//
//  Socket.swift
//
//  Copyright © 2015 Roman Roibu. All rights reserved.
//

import Foundation

///
public struct ConnectInfo {
    internal let host: String
    internal let port: UInt
    internal let database: UInt
    internal let password: String?

    public init(host: String="127.0.0.1", port: UInt=6379, database: UInt=0, password:String?=nil) {
        self.host = host
        self.port = port
        self.database = database
        self.password = password
    }
}

///
public protocol SocketType {
    init(info: ConnectInfo)
    func connect() throws
    func send(data: NSData) throws
    func recv() throws -> NSData
    func close() throws
}

