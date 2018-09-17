//
//  Extensions.swift
//  Panagam
//
//  Created by Quân Đinh on 9/17/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Foundation

extension String {
    
    /// detect an anagram (đảo chữ cái):
    /// 1. Ignore capitalization (Ký tự hoa) & whitespace.
    /// 2. Check both strings cotain the same charaters in the same number of times appearing.
    /// - parameter secondString: The string to compare with.
    func isAnagramOf(_ secondString: String) -> Bool {
        
        // remove capitalization and whitespace
        let currentLowerString = self.lowercased().replacingOccurrences(of: " ", with: "")
        let secondLowerString = secondString.lowercased().replacingOccurrences(of: " ", with: "")
        
        // sort & compare
        return currentLowerString.sorted() == secondLowerString.sorted()
    }
    
    /// detect palindromes: the words or sentences that read the same from backwards & fowards.
    /// 1. Ignore capitalization (Ký tự hoa) & whitespace.
    /// 2. Reverse the string and compare
    func isPalidrome() -> Bool {
        
        // remove capitalization & white space & reversed
        let currentLowerString = self.lowercased().replacingOccurrences(of: " ", with: "")
        let reverseString = String(currentLowerString.reversed())
        
        return currentLowerString == reverseString
    }
}
