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
		
		metalKitView = self.view as? MTKView
		metalKitView.device = MTLCreateSystemDefaultDevice()!
		renderer = Renderer(metalKitView: metalKitView)
		metalKitView.delegate = renderer
	}
}
