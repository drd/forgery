//
//  Logging.swift
//  mesher
//
//  Created by Eric O'Connell on 1/5/19.
//  Copyright © 2019 Eric O'Connell. All rights reserved.
//

import Foundation
import os

fileprivate var timestamp: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    return formatter
}()

fileprivate func now() -> String {
    return timestamp.string(from: Date())
}

func logger(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    let fileName = file.components(separatedBy: "/").last ?? ""
    #if DEBUG
    print("\(now()) [\(fileName) \(function):\(line)] \(message)")
    #else
    os_log("%{public}@", "\(now()) \(message)")
    #endif
}

