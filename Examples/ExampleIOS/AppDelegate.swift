//
//  AppDelegate.swift
//  ExampleIOS
//
//  Created by Matthias Keiser on 26.01.17.
//  Copyright © 2017 Tristan Inc. All rights reserved.
//

import UIKit
import MobileCoreServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

		if UTI.appleScript == UTI(rawValue:kUTTypeAppleScript as UTI.RawValue) {

			NSLog("It worked")
		} else {

			NSLog("Error")
		}

		return true
	}
}

