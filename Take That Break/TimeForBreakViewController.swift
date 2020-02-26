//
//  TimeForBreakViewController.swift
//  Take That Break
//
//  Created by Dragos Strugar on 25.02.2020.
//  Copyright © 2020 Dragos Strugar. All rights reserved.
//

import Cocoa
import AppKit

class TimeForBreakViewController: NSViewController {
    
    @IBOutlet weak var TitleLabel: NSTextField!
    @IBOutlet weak var FactLabel: NSTextField!
    
    @IBAction func onOK(_ sender: Any) {
        self.view.window?.close()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        FactLabel.stringValue = Constants.getRandomElement(array: Constants.userMessages)
    }
}
