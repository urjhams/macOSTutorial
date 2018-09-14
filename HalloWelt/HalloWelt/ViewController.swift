//
//  ViewController.swift
//  HalloWelt
//
//  Created by urjhams on 8/30/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var theTextField: NSTextField!
    @IBOutlet weak var theButton: NSButton!
    @IBOutlet weak var theLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theButton.action = #selector(clickButton(_:))
        theLabel.stringValue = ""
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @objc func clickButton(_ sender: NSButton) {
        theLabel.stringValue = theTextField.stringValue == "" ? "Mussen Sie einen Name schrieben" : "Hallo " + theTextField.stringValue + "!"
    }
}

