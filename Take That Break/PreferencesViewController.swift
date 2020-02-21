//
//  PreferencesViewController.swift
//  Take That Break
//
//  Created by Dragos Strugar on 21.02.2020.
//  Copyright © 2020 Dragos Strugar. All rights reserved.
//

import Cocoa
import AppKit

func shell(_ command: String) -> String {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

    return output
}

func infoForKey(_ key: String) -> String? {
        return (Bundle.main.infoDictionary?[key] as? String)?
            .replacingOccurrences(of: "\\", with: "")
 }

class PreferencesViewController: NSViewController {
    
    @IBOutlet weak var startAppOnMacStart: NSButton!
    @IBOutlet weak var timeSlider: NSSlider!
    @IBOutlet weak var feedbackField: NSTextField!
    
    let defaults = UserDefaults.standard
    
    let appDelegate: AppDelegate? = NSApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable Start App on Mac Start
        startAppOnMacStart.isEnabled = false
        
        // Set timer's value to the one provided in the UserDefaults
        resetTimerToGivenValue()
    }
    
    // Set slider to its value set in UserDefaults
    func resetTimerToGivenValue() {
        timeSlider.doubleValue = Double(defaults.integer(forKey: "timeSessionDuration"))
    }
    
    @IBAction func saveSettingsChanges(_ sender: Any) {
        let result: Bool = dialogOK(question: "Are you sure?", text: "Setting a new value for the timer will reset your current session. Continue?")
        
        // User has agreed to reset timer
        if result {
            appDelegate?.setTimeSessionDefaults(newSessionDuration: timeSlider.integerValue)
        } else {
            resetTimerToGivenValue()
        }
    }
    
    @IBAction func submitFeedback(_ sender: Any) {
        sendMailGunEmail(feedbackText: feedbackField.stringValue)
    }
    
    func sendMailGunEmail(feedbackText: String) {
        
        let shellCommand = """
            curl -s --user 'api:\(infoForKey("API_KEY")!)' \
            https://api.mailgun.net/v3/\(infoForKey("MAILGUN_URL")!).mailgun.org/messages \
            -F from='\(infoForKey("FROM_EMAIL")!)' \
            -F to='\(infoForKey("TO_EMAIL")!)' \
            -F subject='Feedback for Take That Break!' \
            -F text='\(feedbackText)'
        """
        
        print(shellCommand)
        
        let curlResult = shell(shellCommand)
        
        if curlResult.contains("Queued") {
            dialogOK(question: "Success", text: "Feedback has been successfully received. Thanks so much!", hasCancel: false)
        } else {
            dialogOK(question: "Error :(", text: "There has been an error in sending the feedback. Please try again later.", hasCancel: false)
        }
    }
    
    func dialogOK(question: String, text: String, hasCancel: Bool = true) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        
        if (hasCancel) { alert.addButton(withTitle: "Cancel") }
        
        return alert.runModal() == .alertFirstButtonReturn
    }
}
