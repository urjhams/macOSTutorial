//
//  ConsoleIO.swift
//  Panagam
//
//  Created by Quân Đinh on 9/17/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Foundation

enum OutputType {
    case error
    case standard
}

class ConsoleIO {
    
    /// show the message
    /// - parameter message: the message to show
    /// - parameter type: Destination, which defaults to .standard
    func writeMessage(_ message: String, to type: OutputType = .standard) {
        switch type {
        case .standard:
            print("\u{001B}[;m\(message)")              // stdout
        case .error:
            fputs("\u{001B}[0;31m\(message)\n", stderr) // stderr
        }
    }
    
    func printUsage() {
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
        
        writeMessage("usage:")
        writeMessage("\(executableName) - a string1 string2")
        writeMessage("or")
        writeMessage("\(executableName) -p string")
        writeMessage("or")
        writeMessage("\(executableName) -h to show usage information")
        writeMessage("Type \(executableName) without an pption to enter interactive mode.")
    }
    
    func getInput() -> String {
        let keyboard = FileHandle.standardInput
        let inputData = keyboard.availableData
        let stringData = String(data: inputData, encoding: .utf8) ?? ""
        return stringData.trimmingCharacters(in: .newlines)
    }
}
