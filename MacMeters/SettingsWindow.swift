//
//  SettingsWindow.swift
//  
//
//  Created by Alexandre Brehmer on 09/08/2015.
//
//

import Cocoa

/// The setting window class control an handle the events from the SettingsWindow
class SettingsWindow: NSWindowController, NSTableViewDataSource, NSTableViewDelegate {
    
    /// Reference to the colorWell object in the window
    @IBOutlet weak var colorWell: NSColorWell!
    
    /// Reference to the tableView object in the window
    @IBOutlet weak var keyTable: NSTableView!
    
    /// Array containing the list of values to display in the TableView
    var objects: NSMutableArray! = NSMutableArray()
    
    /// Equivalent to the init() method, called just before the window is shown
    override func windowDidLoad() {
        super.windowDidLoad()
        var keyList = SettingsManager.getKeyList()  //get the list of the keys stored in the Settings
        for key in keyList{
            self.objects.addObject(key)             //add the key to the tableView
        }
        
        self.keyTable.reloadData()                  //update the tableView
        
    }
    
    /// Called when the user choosed a color in the color picked given by the colorWell
    /// The function convert the choosen color and save it as the value of the selected key
    @IBAction func colorPicked(sender: NSColorWell) {
        if (self.keyTable.numberOfSelectedRows > 0)
        {
            let selectedItem = self.objects.objectAtIndex(self.keyTable.selectedRow) as! String
            let color = colorWell.color
            var colorInt: Int = getIntColorFromFloat(color.redComponent, color.greenComponent, color.blueComponent)
            SettingsManager.setValue(selectedItem, value: colorInt)
        }
    }

    /// Need to be declared to satisfy the inheritance of NSTableViewDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int
    {
        return self.objects.count
    }
    
    /// Need to be declared to satisfy the inheritance of NSTableViewDelegate
    /// Select and initialize the view used as cell in the tableView
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var cellView = tableView.makeViewWithIdentifier("cell", owner: self) as! NSTableCellView
        cellView.textField!.stringValue = self.objects.objectAtIndex(row) as! String
        return cellView
    }
    
    /// Handle the selections in the tableView
    /// Update the colorWell to the stored color of the selected Key
    func tableViewSelectionDidChange(notification: NSNotification)
    {
        if (self.keyTable.numberOfSelectedRows > 0)
        {
            let selectedItem = self.objects.objectAtIndex(self.keyTable.selectedRow) as! String
            var color = SettingsManager.getColorValue(selectedItem)
            colorWell.color = color
        }
        
    }
}
