//
//  AppDelegate.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-02.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
	
	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}
}

extension Int {
	var degreesToRadians: Float {
		Float(self) * .pi / 180
	}
}

extension Float {
	var degreesToRadians: Float {
		self * .pi / 180
	}
}

extension Double {
	var degreesToRadians: Float {
		Float(self * .pi / 180)
	}
}
