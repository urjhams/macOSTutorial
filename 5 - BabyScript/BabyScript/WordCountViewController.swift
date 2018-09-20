//
//  WordCountViewController.swift
//  BabyScript
//
//  Created by Quân Đinh on 20.09.18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Cocoa

class WordCountViewController: NSViewController {

    @objc dynamic var wordCount = 0
    @objc dynamic var paragraphCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func dissmissWordCountWindow(_ sender: NSButton) {
        let application = NSApplication.shared
        application.stopModal()
    }
    
}
