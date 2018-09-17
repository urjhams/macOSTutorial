//
//  Panagram.swift
//  Panagam
//
//  Created by Quân Đinh on 9/17/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Foundation

enum OptionType: String {
    case palidrome = "p"
    case anagram = "a"
    case help = "h"
    case quit = "q"
    case unknown
    
    init(value: String) {
        switch value {
        case "a":
            self = .anagram
        case "p":
            self = .palidrome
        case "h":
            self = .help
        case "q":
            self = .quit
        default:
            self = .unknown
        }
    }
}

class Panagram {
    
    let consoleIO = ConsoleIO()
    
    func interactiveMode() {
        consoleIO.writeMessage("Welcome to Panagram. This program check if an input string is an anagram or palindrome.")
        
        /// In the while loop, after a case, if it not turn true, turn to next loop.
        /// When it's turn true, the loop end, also the end of this function and the program too.
        var shouldQuit = false
        
        while !shouldQuit {
            consoleIO.writeMessage("Type 'a' to check for anagrams or 'p' for palindromes type, 'q' to quit")
            let (option, value) = getOption(consoleIO.getInput())
            switch option {
            case.anagram:
                consoleIO.writeMessage("Type the first string:")
                let first = consoleIO.getInput()
                consoleIO.writeMessage("OK now type the second string:")
                let second = consoleIO.getInput()
                
                consoleIO.writeMessage(first.isAnagramOf(second) ?
                    "\(second) is anagram of \(first)" :
                    "\(second) is not anagram of \(first)")
            case .palidrome:
                consoleIO.writeMessage("Type a word or sentence:")
                let input = consoleIO.getInput()
                consoleIO.writeMessage(input.isPalidrome() ?
                    "\"\(input)\" is a palidrome" :
                    "\"\(input)\" is not a palidrome")
            case .quit:
                shouldQuit = true
            default:
                consoleIO.writeMessage("Unknow option \(value)", to: .error)
            }
        }
    }
    
    /// Need the argument at input by choose Panagam -> Edit scheme -> add argument in Arguments tab
    func staticMode() {
        /// argument count: the number of arguments passed to the program
        let argCount = CommandLine.argc
        
        let argument = CommandLine.arguments[1]
        
        /// Skip the first character in argument constant, which is '-'
        /// - -command argument1 arguemnt2
        let (option, value) =
            getOption(String(argument[argument.index(after: argument.startIndex)...]))
            //getOption(argument.substring(from: argument.index(argument.startIndex, offsetBy: 1)))
        
        switch option {
        case .anagram:
            if argCount != 4 {
                consoleIO.writeMessage(argCount > 4 ?
                    "Too many arguments for option \(option.rawValue)" :
                    "Too few arguments for option \(option.rawValue)",
                    to: .error)
                consoleIO.printUsage()
            } else {
                let firstArg = CommandLine.arguments[2]
                let secondArg = CommandLine.arguments[3]
                
                consoleIO.writeMessage(firstArg.isAnagramOf(secondArg) ?
                    "\(secondArg) is an anagram of \(firstArg)" :
                    "\(secondArg) is not an anagram of \(firstArg)")
            }
        case .palidrome:
            if argCount != 3 {
                consoleIO.writeMessage(argCount > 3 ?
                    "Too many arguments for option \(option.rawValue)" :
                    "Too few arguments for option \(option.rawValue)",
                    to: .error)
                consoleIO.printUsage()
            } else {
                let input = CommandLine.arguments[2]
                consoleIO.writeMessage("\"\(input)\" is \(input.isPalidrome() ? "" : "not ")a palindrome")
            }
        case .help:
            consoleIO.printUsage()
        case .unknown, .quit:
            consoleIO.writeMessage("Unknow option \(value)")
            consoleIO.printUsage()
        }
    }
    
    /// return the option type based on the option name
    func getOption(_ option: String) -> (option: OptionType, value: String) {
        return (OptionType(value: option), option)
    }
}
