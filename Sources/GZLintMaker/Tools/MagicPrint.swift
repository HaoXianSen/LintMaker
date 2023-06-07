//
//  File.swift
//  
//
//  Created by 郝玉鸿 on 2023/5/29.
//

import Foundation

let reset = "\u{001B}[0m"
let redForegroundColor = "\u{001B}[31m"
let grayForegroundColor = "\u{001B}[90m"
let greenForegroundColor = "\u{001B}[32m"

public func mPrint(_ aString: String, textColor: String? = nil) {
    let textColorFlag = textColor ?? ""
    let resetFlag = textColor != nil ? reset : ""
    let printString =  textColorFlag + "\(aString)" + resetFlag
    queuePrint(printString)
}

public func printInfo(_ info: String) {
    let printString = grayForegroundColor + "[info]" + " \(info)" + reset
    queuePrint(printString)
}

public func printError(_ error: String) {
    let printString = redForegroundColor + "[error]" + " \(error)" + reset
    ququePrintError(printString)
}

public func printFatalError(_ error: String) -> Never {
    let printString = redForegroundColor + "[error]" + " \(error)" + reset
    ququePrintFatalError(printString)
}
