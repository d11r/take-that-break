//
//  AppDelegate.swift
//  Take That Break
//
//  Created by Dragos Strugar on 20.02.2020.
//  Copyright © 2020 Dragos Strugar. All rights reserved.
//

import Cocoa
import SwiftUI
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // Global Fields
    private var statusBarItem: NSStatusItem!
    private var statusBarMenu: NSMenu!
    private var statusBar = NSStatusBar.system
    
    // State Variables
    private var timeRemaining: Int = 20
    private var isFocused: Bool = false
    
    private var windowViewController: NSWindowController?
    private var timer: Timer?
    
    private let defaults = UserDefaults.standard
    private var preferencesController: NSWindowController?
    private var timeForBreakController: NSWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.loadInitialDefaultValues()
        
        timeRemaining = defaults.integer(forKey: "timeSessionDuration")
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set Status Bar Content
        statusBarItem.button?.image = NSImage(named: "running")
        statusBarItem.button?.imagePosition = NSControl.ImagePosition.imageLeft
        
        // Create Menu on Click
        statusBarMenu = NSMenu(title: "Take That Break! Menu")
        statusBarItem.menu = statusBarMenu
        
        self.addStatusBarMenuOptions(menu: statusBarMenu)

        self.startCountdown()
        
        stateReducer()
    }
    
    func loadInitialDefaultValues() {
        if defaults.object(forKey: "timeSessionDuration") == nil {
            defaults.set(20, forKey: "timeSessionDuration")
        }
    }
    
    func setTimeSessionDefaults(newSessionDuration: Int) {
        defaults.set(newSessionDuration, forKey: "timeSessionDuration")
        self.resetCountdown()
    }
    
    func addStatusBarMenuOptions(menu: NSMenu) {
        menu.addItem(withTitle: "Start/Resume", action: #selector(AppDelegate.startCountdown), keyEquivalent: "s")
        menu.addItem(withTitle: "Pause",        action: #selector(AppDelegate.stopCountdown), keyEquivalent: "p")
        menu.addItem(withTitle: "Reset",        action: #selector(AppDelegate.resetCountdown), keyEquivalent: "r")
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(withTitle: "In the Flow! (turn off notifications)", action: #selector(AppDelegate.focus), keyEquivalent: "f")
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(withTitle: "Preferences", action: #selector(AppDelegate.openPreferences), keyEquivalent: ",")
        menu.addItem(withTitle: "Check for updates", action: #selector(checkForUpdates), keyEquivalent: "")
        menu.addItem(withTitle: "Share the app!", action: #selector(AppDelegate.share), keyEquivalent: "")
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(withTitle: "Quit", action: #selector(AppDelegate.quit), keyEquivalent: "")
    }
    
    @objc func startCountdown() {
        isFocused = false
        self.timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(decreaseMinutes), userInfo: nil, repeats: true)
        statusBarItem.button?.image = NSImage(named: "running")
        if (self.timeRemaining == 0) {
            self.timeRemaining = defaults.integer(forKey: "timeSessionDuration")
        }
        stateReducer()
    }
    
    @IBAction func checkForUpdates(_ sender: Any) {
        let updater = SUUpdater.shared()
        updater?.feedURL = URL(string: "")
        updater?.checkForUpdates(self)
    }
    
    @objc func stopCountdown() {
        timer?.invalidate()
        timer = nil
        stateReducer()
    }
    
    @objc func focus() {
        isFocused = true
        timer?.invalidate()
        timer = nil
        stateReducer()
        statusBarItem.button?.image = NSImage(named: "focus")
    }
    
    @objc func resetCountdown() {
        isFocused = false
        timer?.invalidate()
        timer = nil
        self.timeRemaining = defaults.integer(forKey: "timeSessionDuration")
        stateReducer()
    }
    
    @objc func openTimeForBreak() {
        let mainStoryboard = NSStoryboard.init(name: NSStoryboard.Name("Main"), bundle: nil)
        
        if timeForBreakController == nil {
            timeForBreakController = mainStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("TimeForBreakViewController")) as? NSWindowController
        }
        timeForBreakController!.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func openPreferences() {
        let mainStoryboard = NSStoryboard.init(name: NSStoryboard.Name("Main"), bundle: nil)
        
        if preferencesController == nil {
            preferencesController = mainStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("PreferencesWindowController")) as? NSWindowController
        }
        preferencesController!.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    // TODO: implement sharing functionality
    @objc func share() {
        print("Share clicked!")
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
    
    @objc func decreaseMinutes() {
        timeRemaining -= 1
        stateReducer()
    }
    
    public func stateReducer() {
        if ((self.timer) != nil) {
            if (self.timeRemaining == 0) {
                if (!isFocused) {
                    openTimeForBreak()
                }
                
                statusBarItem.button?.image = NSImage(named: "time-out")
                stopCountdown()
            } else {
                statusBarItem.button?.title = "\(self.timeRemaining) min"
            }
        } else {
            if (self.timeRemaining == 0) {
                statusBarItem.button?.image = NSImage(named: "time-out")
                statusBarItem.button?.title = "Take That Break!"
            } else {
                statusBarItem.button?.image = NSImage(named: "no-time")
                statusBarItem.button?.title = ""
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Take_That_Break")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }
}

