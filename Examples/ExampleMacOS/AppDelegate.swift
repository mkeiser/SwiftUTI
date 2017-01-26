//
//  AppDelegate.swift
//  ExampleMacOS
//
//  Created by Matthias Keiser on 24.01.17.
//  Copyright © 2017 Tristan Inc. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!


	func applicationDidFinishLaunching(_ aNotification: Notification) {

		if UTI.AppleScript == UTI(rawValue:kUTTypeAppleScript as UTI.RawValue) {

			NSLog("It worked")
		} else {

			NSLog("Error")
		}
	}
}

