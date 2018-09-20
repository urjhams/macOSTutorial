//
//  ViewController.swift
//  BabyScript
//
//  Created by Quân Đinh on 20.09.18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.toggleRuler(nil)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

