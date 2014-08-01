//
//  MiniTray.swift
//  MiniTray
//
//  Created by Austin Taylor on 7/31/14.
//  Copyright (c) 2014 Austin Taylor. All rights reserved.
//

import Foundation
import Cocoa
import IOKit
import AppKit
import CoreLocation

class MiniTray : NSView, CLLocationManagerDelegate {
    let darkSkyKey = "d281ddbbd3d67ec3cae2e6b4e90a04a7"
    let darkSkyIcons = [
        "clear-day" : "☀️",
        "clear-night" : "🌌",
        "partly-cloudy-night" : "🌌",
        "partly-cloudy-day" : "⛅️",
        "cloudy" : "☁️",
        "rain" : "☔️",
        "snow" : "❄️",
        "sleet" : "❄️",
        "hail" : "❄️",
        "wind" : "💨",
        "thunderstorm" : "⚡️",
        "fog" : "🌁"
    ]
    
    var textField: NSTextField
    var formatter: NSDateFormatter
    var batteryInfo: NSString = ""
    var weatherInfo: NSString = ""
    var _window: NSWindow
    var location: CLLocation?
    var locationManager: CLLocationManager
    
    init(frame frameRect: NSRect, window theWindow: NSWindow) {
        textField = NSTextField(frame: frameRect)
        textField.bordered = false
        textField.font = NSFont(name: "Monaco", size: 12.0)
        textField.textColor = NSColor(calibratedRed: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        textField.backgroundColor = NSColor.clearColor()
        textField.editable = false
        
        formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd  hh:mm a";
        
        _window = theWindow
        
        locationManager = CLLocationManager()

        super.init(frame: frameRect)
        
        addSubview(textField)

        self.wantsLayer = true
        self.layer.backgroundColor = NSColor(calibratedRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.6).CGColor
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateText"), userInfo: nil, repeats: true)
        NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: Selector("updateBatteryInfo"), userInfo: nil, repeats: true)
        NSTimer.scheduledTimerWithTimeInterval(10 * 60, target: self, selector: Selector("updateWeatherInfo"), userInfo: nil, repeats: true)
        
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self, selector: Selector("updateVisibility"), name: NSWorkspaceDidActivateApplicationNotification, object: nil)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
        
        updateText()
        updateBatteryInfo()
        updateWeatherInfo()
        updateVisibility()
    }
    
    func updateText() {
        let time = formatter.stringFromDate(NSDate())
        let array:NSArray = [weatherInfo, weatherInfo.length > 0 ? "   " : "", batteryInfo, batteryInfo.length > 0 ? "   " : "", time]
        let string = array.componentsJoinedByString("")
        textField.stringValue = string

        let sideMargin: CGFloat = 10.0
        let topMargin: CGFloat = 4.0
        let textWidth = textField.attributedStringValue.size.width + 4
        self.frame = NSMakeRect(0, 0, textWidth + sideMargin * 2, self.frame.size.height)
        textField.frame = NSMakeRect(sideMargin, -topMargin, textWidth, self.frame.size.height)
        
        let sf = NSScreen.mainScreen().visibleFrame
        let windowFrame = NSMakeRect(sf.size.width - self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)
        _window.setFrame(windowFrame, display: true, animate: false)
    }
    
    func updateWeatherInfo() {
        if let loc = location {
            let url = NSURL(string:"https://api.forecast.io/forecast/\(darkSkyKey)/\(loc.coordinate.latitude),\(loc.coordinate.longitude)")
            let json = NSData.dataWithContentsOfURL(url, options: nil, error: nil)
            let obj = NSJSONSerialization.JSONObjectWithData(json, options: nil, error: nil) as NSDictionary
            let current = obj.valueForKey("currently") as NSDictionary
            let icon = darkSkyIcons[(current.valueForKey("icon")) as NSString]!
            let temp = current.valueForKey("temperature") as NSNumber
            weatherInfo = "\(icon) \(Int(temp))º"
        }
    }
    
    func updateBatteryInfo() {
        let matching = IOServiceMatching("AppleSmartBattery").takeUnretainedValue();
        let entry = IOServiceGetMatchingService(kIOMasterPortDefault, matching);
        var properties: Unmanaged<CFMutableDictionary>?
        IORegistryEntryCreateCFProperties(entry, &properties, nil, 0);
        let unretained = properties?.takeUnretainedValue()
        if let props:NSMutableDictionary = unretained? {
            let pluggedIn: NSInteger = props.valueForKey("ExternalChargeCapable") as NSInteger
            let cur: NSInteger = props.valueForKey("CurrentCapacity") as NSInteger
            let max: NSInteger = props.valueForKey("MaxCapacity") as NSInteger
            let percent = Int(Double(cur) / Double(max) * 100)

            let prefix = pluggedIn == 1 ? "⚡️" : "🔋"
            batteryInfo = "\(prefix) \(percent)%"
        }
        IOObjectRelease(entry);
    }

    func updateVisibility() {
        if let id = NSWorkspace.sharedWorkspace().frontmostApplication.bundleIdentifier {
            if id == "org.gnu.Emacs" {
                _window.orderFront(nil)
            } else {
                _window.orderOut(nil)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        location = locations[locations.endIndex - 1] as? CLLocation
        if weatherInfo.length == 0 {
            updateWeatherInfo()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        location = newLocation
        if weatherInfo.length == 0 {
            updateWeatherInfo()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch (status) {
        case .Authorized:
            locationManager.startUpdatingLocation()
        case .NotDetermined:
            locationManager.startUpdatingLocation()
            locationManager.stopUpdatingLocation()
        default:
            break;
        }
    }
}