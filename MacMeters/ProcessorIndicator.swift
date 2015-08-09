//
//  ProcessorIndicator.swift
//
// Author: Alexandre Brehmer
// @alexnesnes

import Cocoa
import CoreGraphics

/// Implementation of a MenuBarItem that represents the Processor usage
/// Including a graph representation of the previous values
/// Including a Swift-><-ObjectiveC-><-C++ call to get the Processor informations
class ProcessorIndictator : MenuBarItem {
    
    /// The length of the data historic, re-initialized in init() function
    var historicLength: Int = 0
    
    // The array that contains the data historic ``` [ [0,0], [0,0], ... ] ``` , with [[userCpuPercent,systemCpuPercent]]
    var historic = [[CGFloat]]()
    
    /// Set of color variables used to display the informations
    var processorSystemUsedGraphColor = NSColor()
    var processorUserUsedGraphColor = NSColor()
    var processorLowUsedPercentTextColor = NSColor()
    var processorHighUsedPercentTextColor = NSColor()
    
    /**
        Constructor of the ProcessorIndictator
         - Call the MenuBarItem constructor
         - Set the historic length to the width of the icon image
         - Set the updateTime to 0.5 second
    */
    override init() {
        super.init()
        historicLength = Int(self.width)
        self.updateTime = 0.5
    }
    
    /**
    Read the values stored in the settings to display a custumized indicator
    */
    func readSettings(){
        processorSystemUsedGraphColor = SettingsManager.getColorValue("processorSystemUsedGraphColor")
        processorUserUsedGraphColor = SettingsManager.getColorValue("processorUserUsedGraphColor")
        processorLowUsedPercentTextColor = SettingsManager.getColorValue("processorLowUsedPercentTextColor")
        processorHighUsedPercentTextColor = SettingsManager.getColorValue("processorHighUsedPercentTextColor")
    }
    
    /**
        Update method periodically called by the parent thread to update the ProcessorIndictator icon image
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
        cppFunctionsBridge.getCpu(&returnTab)       //Call to a C++ function by passing by the Objectiv-C wrapper/bridge
                                                    //The C++ function take 0.5 second to get the datas
        var used: CGFloat = CGFloat(returnTab[0])
        var user: CGFloat = CGFloat(returnTab[0])
        var system: CGFloat = used-user
        updateHistoric(user,system: system)
        //Begin drawing
        image.lockFocus()
        
        var index: CGFloat = 0
        for values:[CGFloat] in historic {
            user = values[0]
            system = values[1]
            if(system>0) {
                //Draw system usage
                let foregroundColor = processorSystemUsedGraphColor
                foregroundColor.setFill()
                NSRectFill(NSMakeRect(index, 0, 1,height/100*system))
            }
            
            if(user>0){
                //Draw user usage
                let foregroundColor = processorUserUsedGraphColor
                foregroundColor.setFill()
                NSRectFill(NSMakeRect(index, height/100*system+0.5, 1, height/100*user))
            }
            index++
        }
        
        /*let txt: String = String(Int(round(system))) + "+" + String(Int(round(user)))
        drawText(txt, size: 10.0, color: NSColor.blueColor(), x: 0, y: -height/2, w: width, h: height)*/
        
        var textColor: NSColor = processorLowUsedPercentTextColor
        var y: CGFloat = 2
        if(used > 50) {
            textColor = processorHighUsedPercentTextColor
            y = -height/4-2
        }
        let txtTotal = String(Int(round(used)))+"%"
        drawText(txtTotal, 12.0, textColor, 2, y, width, height)
        
        
        image.unlockFocus()
    }
    
    /**
        Function that updates the historic with the given values
        :param: user    user percent used amount to add to the historic
        :param: system  system percent used amount to add to the historic
        :note: This method also controls the size of the historic by removing the old datas
    */
    func updateHistoric(user: CGFloat, system: CGFloat) {
        historic.append([user,system])
        if(historic.count > historicLength){
            historic.removeAtIndex(0)
        }
    }

}
