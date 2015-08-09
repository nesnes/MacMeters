//
//  DiskIndicator.swift
//
// Author: Alexandre Brehmer
// @alexnesnes

import Cocoa
import CoreGraphics

/// Implementation of a MenuBarItem that represents the Disk I/O usage
/// Including a call to 'grep-ed' 'top' command to get the I/O informations
class DiskIndictator : MenuBarItem {
    
    /**
        Constructor of the DiskIndictator
         - Call the MenuBarItem constructor
         - Set the width of the icon image
    */
    override init(){
        super.init()
        self.updateTime = 0.5
        self.width = 40
    }
    
    /**
        Update method periodically called by the parent thread to update the NetworkIndictator icon image
         - clean the image
         - get/draw the informations on the image
         - update the statusIcon with the new image
    */
    override func update(){
        cleanImage()
        draw(image, x: 0, y: 0, width: width, height: height)
        self.statusIcon.image = image
    }
    
    /// The last amount of data read on the disk
    lazy var previousReadDisk: Int = 0
    
    /// The last amount of data wrote on the disk
    lazy var previousWriteDisk: Int = 0
    
    /**
        Get and draw the informations on the image
        :param: image   image to draw on
        :param: x       x start position to draw in
        :param: y       y start position to draw in
        :param: width   width of the rectangle to draw in
        :param: height  height of the rectangle to draw in
    */
    func draw(image: NSImage, x: Double,y: Double, width: CGFloat, height: CGFloat) {
        //getting informations
      //  var topResult: String = getTopCommandResult()
      //  let read: Int = getReadDisk(topResult)
      //  let write: Int = getWriteDisk(topResult)
        //Begin drawing
        image.lockFocus()
        let barHeight = height/4
        let barWidth = barHeight
        
        //Draw read
        var foregroundColor = NSColor.grayColor()
      /*  if(read>previousReadDisk){
            foregroundColor = customGreen
        }
        foregroundColor.setFill()
        NSRectFill(NSMakeRect(1, height/4+barHeight*1.5, barWidth, barHeight))
        
        //Draw write
        foregroundColor = NSColor.grayColor()
        if(write>previousWriteDisk) {
            foregroundColor = customRed
        }
        foregroundColor.setFill()
        NSRectFill(NSMakeRect(1, height/4-barHeight/2.5, barWidth,barHeight))
      */
        //Draw disk space
        var space: [CGFloat] = getDiskSpace()
        var free = space[0]
        var total = space[1]
        
        //Draw total
        var unit = "Go"
        var format = "%.0f"
        if(total>1000){
            unit = "To"
            format = "%.1f"
            total /= 1000
        }
        var txt: String = String(format: format, total)+unit
        drawText(txt, 10.1, customGreen, barWidth+2, 1, width, height)
        
        //Draw free
        unit = "Go"
        format = "%.0f"
        if(total>1000){
            unit = "To"
            format = "%.1f"
            total /= 1000
        }
        txt = String(format: format, free)+unit
        drawText(txt, 10.1, customGreen, barWidth+2, -height/2+2, width, height)
        
        //history
    //    previousReadDisk = read
    //    previousWriteDisk = write
        image.unlockFocus()
    }
    
    /**
        Get the read amount of data by parsing the 'top' command result
        :param: topResult   String containing the result of the 'top' command
        :returns: The read amount of data on the disk
        :note: need to be securized
    */
    func getReadDisk(topResult: String) -> Int {
        let pattern: String = "Disks: \\w+\\b"
        let matches:String = matchesForRegexInText(pattern,topResult)[0]
        let tab = split(matches){$0==" "}
        return tab[1].toInt()!
    }
    
    /**
        Get the written amount of data by parsing the 'top' command result
        :param: topResult   String containing the result of the 'top' command
        :returns: The written amount of data on the disk
        :note: need to be securized
    */
    func getWriteDisk(topResult: String) -> Int {
        let pattern: String = "read, \\w+\\b"
        let matches:String = matchesForRegexInText(pattern,topResult)[0]
        let tab = split(matches){$0==" "}
        return tab[1].toInt()!
    }
    
    /**
        Get the free and total space available on main disk
        :returns: ac CGFloat array containing the space informations [0]=freeSpace [1]=TotalSpace
    */
    func getDiskSpace() -> [CGFloat] {
        var output: [CGFloat] = [0,0]
        autoreleasepool{
            var documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            if let systemAttributes = NSFileManager.defaultManager().attributesOfFileSystemForPath(documentDirectoryPath.last as! String, error: nil) {
                var freeSize: CGFloat = systemAttributes[NSFileSystemFreeSize] as! CGFloat
                var totalSize: CGFloat = systemAttributes[NSFileSystemSize] as! CGFloat
                freeSize = freeSize / 1000/1000/1000;    //Convert to GBytes
                totalSize = totalSize / 1000/1000/1000;   //Convert to GBytes
                output[0]=freeSize
                output[1]=totalSize
            }
        }
        // something failed
        return output
    }
    
    /**
        Execute the command ``` top -l1 | grep Disks: ``` to get the disk I/O informations
        :returns: The String returned by the standard output of the command 
        :note: It doesn't seem to be the best solution
    */
    func getTopCommandResult() -> String{
        var output: String = ""
        autoreleasepool{
            var task: NSTask = NSTask()
            task.launchPath = "/usr/bin/top"
            task.arguments = ["-l1"]
        
            var greptask: NSTask = NSTask()
            greptask.launchPath = "/usr/bin/grep"
            greptask.arguments = ["Disks:"]
        
            var pipeBetween: NSPipe = NSPipe()
            task.standardOutput = pipeBetween
            greptask.standardInput = pipeBetween
        
            var pipe: NSPipe = NSPipe()
            greptask.standardOutput = pipe
            task.launch()
            usleep(uint(0.5*1000000))       //wait for the top command
            greptask.launch()
            
            output = NSString(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding) as! String
            
            task.terminate()
            greptask.terminate()
        }
        return output
    }

}
