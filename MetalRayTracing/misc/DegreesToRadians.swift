//
//  DegreesToRadians.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-05.
//

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
