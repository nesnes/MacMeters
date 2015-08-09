//
//  NetworkIndicator.swift
//
// Author: Alexandre Brehmer
// @alexnesnes

import Cocoa
import CoreGraphics

/// Implementation of a MenuBarItem that represents the network usage
/// Including a Swift-><-ObjectiveC-><-C++ call to get the network informations
class NetworkIndictator : MenuBarItem {
    
    /// Set of color variables used to display the informations
    var networkDownloadTextColor = NSColor()
    var networkUploadTextColor = NSColor()
    
    /**
        Constructor of the NetworkIndictator
        - Call the MenuBarItem constructor
        - Set the width of the icon image
        - Set the updateTime to 0.5 second
    */
    override init() {
        super.init()
        self.width = 50
        self.updateTime = 0.5
    }
    
    /**
    Read the values stored in the settings to display a custumized indicator
    */
    func readSettings(){
        networkDownloadTextColor = SettingsManager.getColorValue("networkDownloadTextColor")
        networkUploadTextColor = SettingsManager.getColorValue("networkUploadTextColor")
    }
    
    /**
        Update method periodically called by the parent thread to update the NetworkIndictator icon image
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
        cppFunctionsBridge.getNetwork(&returnTab)           //Call to a C++ function by passing by the Objectiv-C wrapper/bridge
                                                            //The C++ function take 0.5 second to get the datas
        var incoming: CGFloat = CGFloat(returnTab[0])/8/1024
        var outgoing: CGFloat = CGFloat(returnTab[1])/8/1024
        //Begin drawing
        image.lockFocus()
        let barWidth: CGFloat = 0
        let barHeight: CGFloat = height/2
        
        var unit: String = "Ko/s"
        var format = "%.0f"
        if(incoming>=1000){
            incoming /= 1024
            unit = "Mo/s"
            format = "%.1f"
        }
        var txt: String = "⇣"+String(format: format, incoming)+unit
        drawText(txt, 11.0, networkDownloadTextColor, barWidth, 2, width, height)
        
        unit = "Ko/s"
        format = "%.0f"
        if(outgoing>=1000){
            outgoing /= 1024
            unit = "Mo/s"
            format = "%.1f"
        }
        txt = "⇡"+String(format: format, outgoing)+unit
        drawText(txt, 11.0, networkUploadTextColor, barWidth, -barHeight+2, width, height)
        
        image.unlockFocus()
    }
}
