//
//  AppDelegate.swift
//
//  With the help of the Lee Brimelow's tutorial named MenuBarApp.
//
// Author: Alexandre Brehmer
// @alexnesnes

import Cocoa
import CoreGraphics

/**
    Main file.
     - Initialize the indicators
     - Handle the interface events
 */
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!
    
    ///Creation of the indicators
    var processorIndicator: MenuBarItem = ProcessorIndictator()
    var memoryIndicator: MenuBarItem = MemoryIndictator()
    var networkIndicator: MenuBarItem = NetworkIndictator()
    var diskIndicator: MenuBarItem = DiskIndictator()

    ///Entry point, adding the menu to the indicators
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        processorIndicator.menu = statusMenu
        memoryIndicator.menu = statusMenu
        networkIndicator.menu = statusMenu
        diskIndicator.menu = statusMenu
    }
    
    ///Handle the quit event, disable all the indicators
    @IBAction func quitClicked(sender: NSMenuItem) {
        processorIndicator.enabled = false
        networkIndicator.enabled = false
        diskIndicator.enabled = false
        memoryIndicator.enabled = false
        exit(EXIT_SUCCESS)
    }
    
    ///Handle the "Processor" list item click, toggle processor the indicator between enabled<->disabled
    @IBAction func toggleProcessor(sender: NSMenuItem) {
        if(sender.state == NSOnState){
            sender.state = NSOffState
            processorIndicator.enabled = false
        } else {
            sender.state = NSOnState
            processorIndicator.enabled = true
        }
    }
    
    ///Handle the "Network" list item click, toggle network the indicator between enabled<->disabled
    @IBAction func toggleNetwork(sender: NSMenuItem) {
        if(sender.state == NSOnState){
            sender.state = NSOffState
            networkIndicator.enabled = false
        } else {
            sender.state = NSOnState
            networkIndicator.enabled = true
        }
    }
    
    ///Handle the "Disk" list item click, toggle disk the indicator between enabled<->disabled
    @IBAction func toggleDisk(sender: NSMenuItem) {
        if(sender.state == NSOnState){
            sender.state = NSOffState
            diskIndicator.enabled = false
        } else {
            sender.state = NSOnState
            diskIndicator.enabled = true
        }
    }
    
    ///Handle the "Memory" list item click, toggle memory the indicator between enabled<->disabled
    @IBAction func toggleMemory(sender: NSMenuItem) {
        if(sender.state == NSOnState){
            sender.state = NSOffState
            memoryIndicator.enabled = false
        } else {
            sender.state = NSOnState
            memoryIndicator.enabled = true
        }
    }
    
}

