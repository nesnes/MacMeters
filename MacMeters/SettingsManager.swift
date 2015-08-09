//
//  SettingsManager.swift
//  MacMeters
//
// Author: Alexandre Brehmer
// @alexnesnes

import Cocoa

/// The SettingsManager is a plist reader. It convert a key into a value and save it in a persistant file.
/// This class is a swift implementation of a singleton
class SettingsManager {
    
    /// The name of the.plis file used
    let settingsFileName = "Settings"
    
    /// The internal object used as a singleton
    private static let settings = SettingsManager()
    
    /// The constant that store the file path, initialied in init()
    let path : String
    
    /// The dictionary object representing the plist file
    private let settingsDict : NSDictionary
    
    /**
         SettingsManager Constructor
          - Get the path of the plist file
          - Initialize the dictionary representing the file
     */
    private init(){
        path = NSBundle.mainBundle().pathForResource(settingsFileName, ofType: "plist")!
        settingsDict = NSDictionary(contentsOfFile: path)!
    }
    
    /**
        Get the String value corresponding to a key in the dictionary representing the plist file
    */
    class func getStringValue(key : String) -> String{
        return self.settings.settingsDict.objectForKey(key)! as! String
    }
    
    /**
        Get the String value corresponding to a key in the dictionary representing the plist file
    */
    class func getColorValue(key : String) -> NSColor{
        var value = self.settings.settingsDict.objectForKey(key)! as! Int
        return getNSColorFromHex(value)
    }
    
    /**
        Store the given key-value in the plist file
    */
    class func setValue(key : String, value : NSObject){
        self.settings.settingsDict.setValue(value, forKey: key as String)
        self.settings.settingsDict.writeToFile(settings.path, atomically: false)
    }
    
    /**
        Return the keys stored in the plist file
    */
    class func getKeyList() -> [String]{
        return self.settings.settingsDict.allKeys as! [String]
    }
}