//
//  MenuBarItem.swift
//
// Author: Alexandre Brehmer
// @alexnesnes

import Cocoa

/// The MenuBarItem represents an object/indicator that display some informations in the Mac status bar.
/// These informations are drawn on an image and the image is added as an icon in the status bar
/// The class is the abstract representation of an indicator
/// A MenuBarItem implements a thread that makes it independent of the other indicators calcul time
class MenuBarItem : NSObject {
    
    /// The system object that creates an blank icon in the status bar.
    /// -1 means that the icon size is variable depending of the image displayed
    let statusIcon = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    /// Define if the MenuBarItem is enabled or not and eventualy hide the status icon by giving it a size of 0
    var enabled: Bool {
        get{ return self.statusIcon.length == -1}
        set(activated){
            if(activated){
                self.statusIcon.length = -1                 //make the icon size dynamic
                if(self.thread.finished) {
                    launchThread()                          //restart the thread
                }
            } else {
                self.statusIcon.length = 0                  //fold the icon
            }
        }
    }
    
    /// The width of the icon image
    var width: CGFloat = 35
    
    /// The height of the icon image, by default the height of the status bar
    var height: CGFloat = NSStatusBar.systemStatusBar().thickness
    
    /// Time between two updates of the icon image displaying the informations, by default 1 second
    var updateTime: CGFloat = 1
    
    /// The image of the icon
    var image: NSImage = NSImage()
    
    /// The menu that appears when cliking on the icon in the status bar
    var menu: NSMenu {
        get{ return statusIcon.menu!}
        set(newMenu){statusIcon.menu=newMenu}
    }
    
    /// The thread object used to update the MenuBarItem independently
    var thread: NSThread = NSThread()
    
    /**
        Constructor of the MenuBarItem
         - Enable the MenuBarItem
         - Launch the thread
    */
    override init(){
        super.init()
        enabled = true
        launchThread()
    }
    
    /**
        Launch the thread controlling the updates an the updateTime
    */
    func launchThread(){
        self.thread = NSThread(target:self, selector: Selector("run"), object: nil)
        thread.start()
    }
    
    /**
        Function ran by the thread
         - Create the image that will contain the informations at the desired size
         - Disable the image cache to avoid memory usage
         - Control that the MenuBarItem is enabled
         - Launch the update method of the MenuBarItem
         - Wait for the updateTime
    */
    func run() {
        self.image = NSImage(size: NSSize(width: self.width, height: self.height)) //Create the image object used for the icon
        image.cacheMode = NSImageCacheMode.Never                                   //Don't cache the image to save memory
        while(self.enabled){                                                       //check if the indicator is enabled
            autoreleasepool {                                                      //required to save memory usage
                update()                                                           //update the indicator
                usleep(uint(updateTime*1000000))                                   //wait the updateTime
            }
        }
    }
    
    /**
        The function called periodically by the thread.
        This method have to:
            - Get the datas to display
            - Print the datas on the icon image
            - Update the icon image by calling ``` self.statusIcon.image = image ```
        :note: The method is made abstract by an assert that is launched if the method is not overridden.
    */
    func update() {
        assert(false, "This method must be overriden by the subclass")
    }
    
    /**
        Clean the whole icon image by drawing a rectangle on all the image
        with the ``` NSColor.clearColor() ``` color.
    */
    func cleanImage()
    {
        autoreleasepool{                                        //Needed to figth against NSImage that consume a lot of memory
            image.lockFocus()
            var clearColor: NSColor = NSColor.clearColor()
            clearColor.setFill()
            NSRectFill(NSMakeRect(0, 0, width, height))
            image.unlockFocus()
        }
    }
    
    /// Set of custom color used to unify the aspect of the MenuBarItems
    let customGreen: NSColor = getNSColor(46, 204, 113)
    let customRed: NSColor = getNSColor(157, 47, 34)
    let customLightGray: NSColor = getNSColor(149, 165, 166)
    let customDarkGray: NSColor = getNSColor(127, 140, 141)
    let customLightBlack: NSColor = getNSColor(69, 69, 69)

}
