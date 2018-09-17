//
//  main.swift
//  Panagam
//
//  Created by urjhams on 9/15/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Foundation

let panagram =  Panagram()

if CommandLine.argc < 2{
    panagram.interactiveMode()
} else {
    panagram.staticMode()
}
