//
//  ViewController.swift
//  EggTimer
//
//  Created by urjhams on 8/31/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var eggImage: NSImageView!
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var resetButton: NSButton!
    
    var eggTimer = EggTimer()
    var prefs = Preferences()
    var soundPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eggTimer.delegate = self
        self.setupPrefs()
    }
}

// - MARK: Actions

extension ViewController {

    @IBAction func clickToStart(_ sender: Any) {
        if eggTimer.isPaused {
            eggTimer.resumeTimer()
        } else {
            eggTimer.duration = prefs.selectedTime
            eggTimer.startTimer()
        }
        configureButtonsAndMenus()
        prepareSound()
    }
    
    @IBAction func clickToStop(_ sender: Any) {
        eggTimer.stopTimer()
        configureButtonsAndMenus()
    }
    
    @IBAction func clickToReset(_ sender: Any) {
        eggTimer.resetTimer()
        updateDisplay(for: prefs.selectedTime)
        configureButtonsAndMenus()
    }
    
    @IBAction func startTimerMenuItemSelected(_ sender: Any) {
        self.clickToStart(sender)
    }
    
    @IBAction func stopTimerMenuItemSelected(_ sender: Any) {
        self.clickToStop(sender)
    }
    
    @IBAction func resetTimerMenuItemSelected(_ sender: Any) {
        self.clickToReset(sender)
    }
}

// - MARK: Delegate pattern

extension ViewController: EggTimerDelegate {
    func timeRemainingOnTimer(_ timer: EggTimer, timeRemaining: TimeInterval) {
        self.updateDisplay(for: timeRemaining)
    }
    
    func timerHasFinished(_ timer: EggTimer) {
        self.updateDisplay(for: 0)
        self.playSound()
    }
}

// - MARK: Data handle: show data and UI changed

extension ViewController {
    
    /// Update the display for the counter and image
    /// - parameter timeRemaining: time left in second
    func updateDisplay(for timeRemeaining: TimeInterval) {
        timeLabel.stringValue = textToDisplay(for: timeRemeaining)
        eggImage.image = imageToDisplay(for: timeRemeaining)
    }
    
    /// Set the time text display in the counter
    /// - parameter timeRemaining: time left in second
    private func textToDisplay(for timeRemaining: TimeInterval) -> String {
        if timeRemaining == 0 {
            return "Done!"
        }
        
        let minutesRemaining = floor(timeRemaining / 60)
        let secondRemaining = timeRemaining - (minutesRemaining * 60)
        
        let secondsDisplay = String(format: "%02d", Int(secondRemaining))
        let timeRemainingDisplay = "\(Int(minutesRemaining)):\(secondsDisplay)"
        
        return timeRemainingDisplay
    }
    
    /// Set the image of the egg to display depend on time left
    /// - parameter timeRemaining: time left in second
    private func imageToDisplay(for timeRemaining: TimeInterval) -> NSImage? {
        let percentageComplete = 100 - (timeRemaining / prefs.selectedTime * 100)
        
        if eggTimer.isStoped {
            let stoppedImage = timeRemaining == 0 ? #imageLiteral(resourceName: "100") : #imageLiteral(resourceName: "stopped")
            return stoppedImage
        }
        
        let image: NSImage
        switch percentageComplete {
        case 0 ..< 25:
            image = #imageLiteral(resourceName: "0")
        case 25 ..< 50:
            image = #imageLiteral(resourceName: "25")
        case 50 ..< 75:
            image = #imageLiteral(resourceName: "50")
        case 75 ..< 100:
            image = #imageLiteral(resourceName: "75")
        default:
            image = #imageLiteral(resourceName: "100")
        }
        return image
    }
    
    /// Change the enable and disable of buttons and app menus depend on state of time remaining
    func configureButtonsAndMenus() {
        let enableStart: Bool
        let enableStop: Bool
        let enableReset: Bool
        
        if eggTimer.isStoped {
            enableStart = true
            enableStop = false
            enableReset = false
        } else if eggTimer.isPaused {
            enableStart = true
            enableStop = false
            enableReset = true
        } else {
            enableStart = false
            enableStop = true
            enableReset = false
        }
        
        startButton.isEnabled = enableStart
        stopButton.isEnabled = enableStop
        resetButton.isEnabled = enableReset
        
        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
            appDelegate.enableMenus(start: enableStart,stop: enableStop,reset: enableReset)
        }
    }
}

// - MARK: Notification Observation pattern and Preferences data handle

extension ViewController {
    
    /// prepare the Notification observer for the preferences window
    private func setupPrefs() {
        updateDisplay(for: prefs.selectedTime)
        
        let notificationName = Notification.Name(rawValue: "PrefsChanged")
        NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil) { [weak self] (notification) in
            self?.checkForResetAfterPrefsChange()
        }
    }
    
    /// show a dialog to confirm to change the preferences
    private func checkForResetAfterPrefsChange() {
        // if change the preferences when the timer curently running, show the dialog
        if eggTimer.isStoped || eggTimer.isPaused {
            updateFromPrefs()
        } else {
            let alert = NSAlert()
            alert.messageText = "Reset timer with the new setting?"
            alert.informativeText = "This will stop your current timer!"
            alert.alertStyle = .warning
            
            alert.addButton(withTitle: "Reset")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                self.updateFromPrefs()
            }
        }
    }
    
    /// get the new value from prefs, which will call from UserDefault for values
    private func updateFromPrefs() {
        self.eggTimer.duration = self.prefs.selectedTime
        self.clickToReset(self)
    }
}

// MARK: - Sound handle

extension ViewController {
    /// Init the soundPlayer variable with the media file to prepare for playing
    private func prepareSound() {
        
        guard let audioFileUrl = Bundle.main.url(forResource: "ding", withExtension: "mp3") else {
            return
        }
        
        do {
            self.soundPlayer = try AVAudioPlayer(contentsOf: audioFileUrl)
            soundPlayer?.prepareToPlay()
        } catch {
            print("Sound player not available: \(error)")
        }
    }
    
    private func playSound() {
        soundPlayer?.play()
    }
}
