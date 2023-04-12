//
//  File.swift
//  
//
//  Created by 郝玉鸿 on 2023/1/30.
//

import Foundation

private var printQueue: DispatchQueue = {
    let dispatchQueue = DispatchQueue(label: "com.youdao.lintmaker.outputQueue",
                                      qos: .userInteractive,
                                      target: .global(qos: .userInteractive)
    )
    
    defer {
        setupExitHandler()
    }
    
    return dispatchQueue
}()

private func setupExitHandler() {
    atexit {
        printQueue.sync(flags: .barrier, execute: {})
    }
}

public func queuePrint<T>(_ object: T) {
    printQueue.async {
        print(object)
    }
}

public func printError(_ aString: String) {
    printQueue.async {
        fflush(stdout)
        fputs(aString + "\n", stderr)
    }
}

public func printFatalError(_ aString: String, file: StaticString = #file, line: Int = #line) -> Never {
    printQueue.sync {
        fflush(stdout)
        var file = "\(file)" as NSString
        file = file.lastPathComponent as NSString
        fputs("\(aString): file \(file), line \(line)\n", stderr)
    }
    
    abort()
}
