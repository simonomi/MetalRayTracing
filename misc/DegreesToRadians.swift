//
//  DegreesToRadians.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-05.
//

extension BinaryInteger {
	var degreesToRadians: Float {
		Float(self) * .pi / 180
	}
}

extension BinaryFloatingPoint {
	var degreesToRadians: Float {
		Float(self) * .pi / 180
	}
}
