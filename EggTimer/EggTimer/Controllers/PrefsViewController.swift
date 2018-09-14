//
//  PrefsViewController.swift
//  EggTimer
//
//  Created by urjhams on 9/12/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Cocoa

class PrefsViewController: NSViewController {

    @IBOutlet weak var presetsPopup: NSPopUpButton!
    @IBOutlet weak var customSlider: NSSlider!
    @IBOutlet weak var customTimeTextField: NSTextField!
    
    var prefs = Preferences()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showExistingPrefs()
    }
}

// MARK: - Actions

extension PrefsViewController {
    
    @IBAction func popUpValueChanged(_ sender: NSPopUpButton) {
        if sender.selectedItem?.title == "Custom" {
            customSlider.isEnabled = true
            return
        }
        let newTimeDuration = sender.selectedTag()
        customSlider.integerValue = newTimeDuration
        showSliderValueAsText()
        customSlider.isEnabled = false
    }
    
    @IBAction func sliderValueChanged(_ sender: NSSlider) {
        showSliderValueAsText()
    }
    
    @IBAction func clickCancel(_ sender: Any) {
        self.view.window?.close()
    }
    
    @IBAction func okClicked(_ sender: Any) {
        self.saveNewPrefs()
        self.view.window?.close()
    }
}

// MARK: - Data handle: show and save

extension PrefsViewController {
    /// show the current values of the pop up and slider, which load from user default
    private func showExistingPrefs() {
        let selectedTimeInMinutes = Int(prefs.selectedTime) / 60
        
        presetsPopup.selectItem(withTitle: "Custom")
        customSlider.isEnabled = true
        
        for item in presetsPopup.itemArray {
            if item.tag == selectedTimeInMinutes {
                presetsPopup.select(item)
                break
            }
        }
        
        customSlider.integerValue = selectedTimeInMinutes
        showSliderValueAsText()
    }
    
    /// Show the text field from the value of the slider
    private func showSliderValueAsText() {
        let newTimerDuration = customSlider.integerValue
        let minutesDescription = newTimerDuration == 1 ? "minute" : "minutes"
        customTimeTextField.stringValue = "\(newTimerDuration) \(minutesDescription)"
    }
    
    /// Save the value to prefs.selectedTime, which save in UserDefualt and post a Notification
    private func saveNewPrefs() {
        prefs.selectedTime = customSlider.doubleValue * 60
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PrefsChanged"), object: nil)
    }
}
