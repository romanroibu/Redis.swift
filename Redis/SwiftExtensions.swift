//
//  SwiftExtensions.swift
//  Redis
//
//  Created by Roman Roibu on 8/17/15.
//  Copyright © 2015 Roman Roibu. All rights reserved.
//

import Foundation

extension CollectionType {
    public func throwingMap<T>(@noescape transform: (Self.Generator.Element) throws -> T) rethrows -> [T] {
        var results = [T]()
        for x in self {
            let y = try transform(x)
            results.append(y)
        }
        return results
    }
}
