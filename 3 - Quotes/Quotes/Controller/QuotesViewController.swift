//
//  QuotesViewController.swift
//  Quotes
//
//  Created by urjhams on 9/14/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Cocoa

class QuotesViewController: NSViewController {

    @IBOutlet weak var textLabel: NSTextField!
    
    let quotes = Quote.all
    
    var currentQuoteIndex: Int = 0 {
        didSet {
            updateQuote()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //currentQuoteIndex = Int(arc4random_uniform(UInt32(quotes.count - 1)))
        currentQuoteIndex = Int.random(in: 0 ..< quotes.count)        // from swift 4.2
    }
}

extension QuotesViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> QuotesViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: .main)
        let identifier = "QuotesViewController"
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? QuotesViewController else {
            fatalError("cannot find QutesViewController")
        }
        return viewcontroller
    }
}

extension QuotesViewController {
    @IBAction private func previousClicked(_ sender: NSButton) {
        currentQuoteIndex = (currentQuoteIndex - 1 + quotes.count) % quotes.count
    }   // this one will cycle around when the index = 0
    
    @IBAction private func nextClicked(_ sender: NSButton) {
        currentQuoteIndex = (currentQuoteIndex + 1) % quotes.count
    }   // this one will cycle around when the index = max
    
    @IBAction private func quitClicked(_ sender: NSButton) {
        NSApplication.shared.terminate(sender)
    }
    
}

extension QuotesViewController {
    private func updateQuote() {
        self.textLabel.stringValue = String(describing: quotes[currentQuoteIndex])
    }
}
