//
//  MemoryIndicator.swift
//
// Author: Alexandre Brehmer
// @alexnesnes

import Cocoa
import CoreGraphics

/// Implementation of a MenuBarItem that represents the RAM memory usage
/// Including a graph representation of the previous values
/// Including a Swift-><-ObjectiveC-><-C++ call to get the RAM informations
class MemoryIndictator : MenuBarItem {
    
    /// The length of the data historic, re-initialized in init() function
    var historicLength: Int = 0
    
    /// The array that contains the data historic ``` [ [0,0], [0,0], ... ] ``` , with [[freeRamAmount,usedRamAmount]] in MBytes
    var historic = [[CGFloat]]()
    
    /// Set of color variables used to display the informations
    var memoryUsedGraphColor = NSColor()
    var memoryFreeGraphColor = NSColor()
    var memoryFreeTextColor = NSColor()
    var memoryLowUsedPercentTextColor = NSColor()
    var memoryHighUsedPercentTextColor = NSColor()
    
    /**
        Constructor of the MemoryIndicator
         - Call the MenuBarItem constructor
         - Set the historic length to the width of the icon image
    */
    override init() {
        super.init()
        historicLength = Int(self.width)
    }
    
    /**
        Read the values stored in the settings to display a custumized indicator
    */
    func readSettings(){
        memoryUsedGraphColor = SettingsManager.getColorValue("memoryUsedGraphColor")
        memoryFreeGraphColor = SettingsManager.getColorValue("memoryFreeGraphColor")
        memoryFreeTextColor = SettingsManager.getColorValue("memoryFreeTextColor")
        memoryLowUsedPercentTextColor = SettingsManager.getColorValue("memoryLowUsedPercentTextColor")
        memoryHighUsedPercentTextColor = SettingsManager.getColorValue("memoryHighUsedPercentTextColor")
    }
    
    /**
        Update method periodically called by the parent thread to update the MemoryIndictator icon image
         - Clean the image
         - Read the settings of the indicator
         - Get/draw the informations on the image
         - Update the statusIcon with the new image
    */
    override func update(){
        cleanImage()
        readSettings()
        draw(image, x: 0, y: 0, width: width, height: height)
        self.statusIcon.image = image
    }

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
        var returnTab: [Float] = [0,0]
        cppFunctionsBridge.getRam(&returnTab)           //Call to a C++ function by passing by the Objectiv-C wrapper/bridge
        var total: CGFloat = CGFloat(returnTab[0])
        var used: CGFloat = CGFloat(returnTab[1])
        var free: CGFloat = total - used
        updateHistoric(free,used: used)
        //Begin drawing
        image.lockFocus()
        
        var index: CGFloat = 0
        for values:[CGFloat] in historic {
            free = values[0]
            used = values[1]
            //Draw used memory
            var foregroundColor: NSColor = memoryUsedGraphColor
            foregroundColor.setFill()
            NSRectFill(NSMakeRect(index, 0, 1,height/total*used))
        
            //Draw free memory
            foregroundColor = memoryFreeGraphColor
            foregroundColor.setFill()
            NSRectFill(NSMakeRect(index, height/total*used+0.2, 1, height/total*free))
            index++
        }
        
        let txt: String = String(Int(free))+String("M")
        drawText(txt, 10.0, memoryFreeTextColor, 2, 2, width, height)
        
        var percents: Int = Int(round(100.0/total*used))
        var percentColor = memoryHighUsedPercentTextColor
        if(percents < 50){
            percentColor = memoryLowUsedPercentTextColor
        }
        let txtTotal = String(percents)+"%"
        drawText(txtTotal, 13.0, percentColor, 2, -height/3+2, width, height)
        
        image.unlockFocus()
    }
    
    /**
        Function that updates the historic with the given values
        :param: free    free amount of memory to add to the historic
        :param: used    used amount of memory to add to the historic
        :note: This method also controls the size of the historic by removing the old datas
    */
    func updateHistoric(free: CGFloat, used: CGFloat) {
        historic.append([free,used])
        if(historic.count > historicLength){
            historic.removeAtIndex(0)
        }
    }

}
