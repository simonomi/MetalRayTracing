//
//  ViewController.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-02.
//

import Cocoa
import Metal
import MetalKit

class ViewController: NSViewController {
	var metalKitView: MTKView!
	var renderer: Renderer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let metalKitView = self.view as? MTKView else {
			print("View attached to ViewController is not an MTKView!")
			return
		}
		self.metalKitView = metalKitView
		
		guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
			print("Metal is not supported on this device")
			return
		}
		metalKitView.device = defaultDevice
		
		guard let renderer = Renderer(metalKitView: metalKitView) else {
			print("Renderer failed to initialize")
			return
		}
		self.renderer = renderer
		
		metalKitView.delegate = renderer
	}
}
