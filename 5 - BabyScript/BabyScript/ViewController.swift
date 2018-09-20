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
            
        }
    }
}

extension ViewController {
    @IBAction func showWordCountWindow(_ sender: AnyObject) {
        let storyboard = NSStoryboard(name: "Main", bundle: .main)
        if let wordCountWindowController = storyboard.instantiateController(withIdentifier: "Word Count Window Controller") as? NSWindowController {
            
            if let wordCountWindow = wordCountWindowController.window, let textStorage = textView.textStorage {
                
                if let wordCountViewController = wordCountWindow.contentViewController as? WordCountViewController {
                    
                    wordCountViewController.wordCount = textStorage.words.count
                    wordCountViewController.paragraphCount = textStorage.paragraphs.count
                    
                    let application = NSApplication.shared
                    application.runModal(for: wordCountWindow)
                    
                    // this one just execute when modal state is complete
                    wordCountWindow.close()
                }
            }
        }
    }
}


