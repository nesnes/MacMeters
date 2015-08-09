//
//  HelpfullFunctions.swift
//
// Author: Alexandre Brehmer
// @alexnesnes

import Cocoa
import CoreGraphics

/// This file contains some usefull methods that are not natively accessible with Swift.

/**
    Draw a given text on the previously locked image.
    :param: text    The text to be written
    :param: size    The size of the written text
    :param: color   The color of the written text
    :param: x       The x position of the beginning of the text
    :param: y       The y position of the beginning of the text
    :param: w       The width of the box that contains the text (auto line warpping)
    :param: h       The height of the box that contains the text
    :note: Actually the font is Helvetica by default
*/
func drawText(text: String, size: CGFloat, color: NSColor,x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
    autoreleasepool {
        let font = NSFont(name: "Helvetica", size: size)
        let textFontAttributes = [
            NSFontAttributeName : font!,
            NSForegroundColorAttributeName: color
        ]
        let txt: NSString = text
        txt.drawInRect(NSMakeRect(x, y, w, h),withAttributes: textFontAttributes)
    }
}

/**
    Execute the given regex on the given text and return the matches
    :param: regex   The regex to be executed
    :param: text    The text where the regex will be applied
    :returns: The String array containing the matches ``` var output: [String] ```
*/
func matchesForRegexInText(regex: String!, text: String!) -> [String] {
    var output: [String] = [""]
    autoreleasepool{
    var regex = NSRegularExpression(pattern: regex,
        options: nil, error: nil)!
    var nsString = text as NSString
    var results = regex.matchesInString(text,
        options: nil, range: NSMakeRange(0, nsString.length))
        as! [NSTextCheckingResult]
    output = map(results) { nsString.substringWithRange($0.range)}
    }
    return output
}

/**
    Create a NSColor object with the given rgb color values
    :r: r   The red amount between (0-255)
    :g: g   The green amount between (0-255)
    :b: b   The blue amount between (0-255)
    :returns: The NSColor object representing the color ``` var output: NSColor ```
*/
func getNSColor(r: Int, g: Int, b: Int) -> NSColor {
    return NSColor(calibratedRed: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha:CGFloat(1))
}

func getNSColorFromHex(hexValue : Int) -> NSColor {
    return getNSColor((hexValue >> 16) & 0xff, (hexValue >> 8) & 0xff, hexValue & 0xff)
}
