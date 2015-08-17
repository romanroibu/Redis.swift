//
//  Commands.swift
//
//  Copyright © 2015 Roman Roibu. All rights reserved.
//

import Foundation

///
public enum CommandError: ErrorType {
    case UnexpectedReply(DataType)
    case RedisError(String)
    case MissingPassword
}

extension Redis {
    
//MARK: - Cluster
    
    //TODO: Implement cluster commands: http://redis.io/commands#cluster
    
//MARK: - Connection

    ///
    /// See: http://redis.io/commands/auth
    public func auth() throws -> Bool {
        if let password = password {
            try send(command: "AUTH", args: [password])
            let reply = try recv()

            switch reply {
            case .String("OK"):
                return true
            case .Error(let reason):
                throw CommandError.RedisError(reason)
            default:
                throw CommandError.UnexpectedReply(reply)
            }
        } else {
            throw CommandError.MissingPassword
        }
    }

    ///
    /// See: http://redis.io/commands/echo
    public func echo(message: String) throws -> String {
        try send(command: "ECHO", args: [message])
        let reply = try recv()

        switch reply {
        case .Bulk(let echo) where echo == message:
            return echo
        case .Error(let reason):
            throw CommandError.RedisError(reason)
        default:
            throw CommandError.UnexpectedReply(reply)
        }
    }

    ///
    /// See: http://redis.io/commands/ping
    public func ping() throws -> Bool {
        try send(command: "PING", args: [])
        let reply = try recv()

        switch reply {
        case .String("PONG"):
            return true
        case .Error(let reason):
            throw CommandError.RedisError(reason)
        default:
            throw CommandError.UnexpectedReply(reply)
        }
    }

    ///
    /// See: http://redis.io/commands/quit
    public func quit() throws -> Bool {
        try send(command: "QUIT", args: [])
        let reply = try recv()

        switch reply {
        case .String("OK"):
            return true
        case .Error(let reason):
            throw CommandError.RedisError(reason)
        default:
            throw CommandError.UnexpectedReply(reply)
        }
    }

    ///
    /// See: http://redis.io/commands/select
    public func select(db index: UInt) throws -> String {
        try send(command: "SELECT", args: [String(index)])
        let reply = try recv()

        switch reply {
        case .String(let message):
            return message
        case .Error(let reason):
            throw CommandError.RedisError(reason)
        default:
            throw CommandError.UnexpectedReply(reply)
        }
    }

    //MARK: - Geo

    //TODO: Implement geo commands: http://redis.io/commands#geo

    //MARK: - Hash

    //TODO: Implement hash commands: http://redis.io/commands#hash

    ///
    /// See: http://redis.io/commands/hdel
    public func hDel(key: String, fields: String...) throws -> Int {
        try send(command: "HDEL", args: [key] + fields)
        let reply = try recv()

        switch reply {
        case .Integer(let int):
            return int
        case .Error(let reason):
            throw CommandError.RedisError(reason)
        default:
            throw CommandError.UnexpectedReply(reply)
        }
    }

    ///
    /// See: http://redis.io/commands/hexists
    public func hExists(key: String, field: String) throws -> Bool {
        try send(command: "HEXISTS", args: [key, field])
        let reply = try recv()

        switch reply {
        case .Integer(let int):
            return int == 1
        case .Error(let reason):
            throw CommandError.RedisError(reason)
        default:
            throw CommandError.UnexpectedReply(reply)
        }
    }

    ///
    /// See: http://redis.io/commands/hget
    public func hGet(key: String, field: String) throws -> String? {
        try send(command: "HGET", args: [key, field])
        let reply = try recv()

        switch reply {
        case .Bulk(let value):
            return value
        case .Null:
            return nil
        case .Error(let reason):
            throw CommandError.RedisError(reason)
        default:
            throw CommandError.UnexpectedReply(reply)
        }
    }

    ///
    /// See: http://redis.io/commands/hgetall
    public func hGetAll(key: String) throws -> [String] {
        try send(command: "HGETALL", args: [key])
        let reply = try recv()

        switch reply {
        case .Array(let values):
            let block: ((DataType) throws -> String) = {
                switch $0 {
                case .Bulk(let value):
                    return value
                case .Error(let reason):
                    throw CommandError.RedisError(reason)
                default:
                    throw CommandError.UnexpectedReply(reply)
                }
            }
            return try values.throwingMap(block)
        case .Error(let reason):
            throw CommandError.RedisError(reason)
        default:
            throw CommandError.UnexpectedReply(reply)
        }
    }

    ///
    /// See: http://redis.io/commands/hincrby
    public func hIncr(key: String, field: String, by increment: Int) throws -> Int {
        try send(command: "HINCRBY", args: [key, field, String(increment)])
        let reply = try recv()

        switch reply {
        case .Integer(let value):
            return value
        case .Error(let reason):
            throw CommandError.RedisError(reason)
        default:
            throw CommandError.UnexpectedReply(reply)
        }
    }

    ///
    /// See: http://redis.io/commands/hincrbyfloat
    public func hIncByFloat(key: String, field: String, by increment: Double) throws -> Double {
        try send(command: "HINCRBYFLOAT", args: [key, field, String(increment)])
        let reply = try recv()
        
        switch reply {
        case .Bulk(let value):
            if let double = Double(value) {
                return double
            } else {
                throw CommandError.UnexpectedReply(reply)
            }
        case .Error(let reason):
            throw CommandError.RedisError(reason)
        default:
            throw CommandError.UnexpectedReply(reply)
        }
    }

    ///
    /// See: http://redis.io/commands/hkeys
    public func hKeys(key: String) throws -> [String] {
        try send(command: "HKEYS", args: [key])
        let reply = try recv()

        switch reply {
        case .Array(let values):
            let block: ((DataType) throws -> String) = {
                switch $0 {
                case .Bulk(let value):
                    return value
                case .Error(let reason):
                    throw CommandError.RedisError(reason)
                default:
                    throw CommandError.UnexpectedReply(reply)
                }
            }
            return try values.throwingMap(block)
        case .Error(let reason):
            throw CommandError.RedisError(reason)
        default:
            throw CommandError.UnexpectedReply(reply)
        }
    }

    ///
    /// See: http://redis.io/commands/hlen
    public func hLen(key: String) throws -> Int {
        try send(command: "HLEN", args: [key])
        let reply = try recv()

        switch reply {
        case .Integer(let value):
            return value
        case .Error(let reason):
            throw CommandError.RedisError(reason)
        default:
            throw CommandError.UnexpectedReply(reply)
        }
    }

    ///
    /// See: http://redis.io/commands/hmget
    public func hmGet() {} //FIXME

    ///
    /// See: http://redis.io/commands/hmset
    public func hmSet() {} //FIXME

    ///
    /// See: http://redis.io/commands/hset
    public func hSet() {} //FIXME

    ///
    /// See: http://redis.io/commands/hsetnx
    public func hSetNX() {} //FIXME

    ///
    /// See: http://redis.io/commands/hstrlen
    public func hStrLen() {} //FIXME

    ///
    /// See: http://redis.io/commands/hvals
    public func hVals() {} //FIXME

    ///
    /// See: http://redis.io/commands/hscan
    public func hScan() {} //FIXME

    //MARK: - HyperLogLog

    //TODO: Implement hyperloglog commands: http://redis.io/commands#hyperloglog
    
    //MARK: - Generic

    //TODO: Implement generic commands: http://redis.io/commands#generic

    //MARK: - List
    
    //TODO: Implement list commands: http://redis.io/commands#list

    //MARK: - Pub/Sub
    
    //TODO: Implement pubsub commands: http://redis.io/commands#pubsub

    //MARK: - Scripting
    
    //TODO: Implement scripting commands: http://redis.io/commands#scripting

    //MARK: - Server
    
    //TODO: Implement server commands: http://redis.io/commands#server

    //MARK: - Set
    
    //TODO: Implement set commands: http://redis.io/commands#set

    //MARK: - Sorted Set

    //TODO: Implement sorted set commands: http://redis.io/commands#sorted_set

    //MARK: - String
    
    //TODO: Implement string commands: http://redis.io/commands#string
    
    //MARK: - Transactions
    
    //TODO: Implement transactions commands: http://redis.io/commands#transactions
    
}
