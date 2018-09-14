//
//  QuotesViewController.swift
//  Quotes
//
//  Created by urjhams on 9/14/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Cocoa

class QuotesViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}

extension QuotesViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> QuotesViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: .main)
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "QuotesViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? QuotesViewController else {
            fatalError("cannot find QutesViewController")
        }
        return viewcontroller
    }
}
