//
//  WindowController.swift
//  BabyScript
//
//  Created by Quân Đinh on 20.09.18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        shouldCascadeWindows = true
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        if let window = window, let screen = window.screen {
            let offsetFromLeft: CGFloat = 100
            let offsetFromTop: CGFloat = 100
            let screenFrame = screen.visibleFrame
            let newOriginY = screenFrame.maxY - window.frame.height - offsetFromTop
            window.setFrameOrigin(NSPoint(x: offsetFromLeft, y: newOriginY))
        }
    }

}
