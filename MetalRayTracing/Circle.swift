//
//  Circle.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-02.
//

import simd

struct Circle {
	var position: SIMD2<Float>
	var radius: Float
	
	init(x: Float, y: Float, radius: Float) {
		self.position = SIMD2(x, y)
		self.radius = radius
	}
	
	func getVertices() -> [SIMD2<Float>] {
		(0...360)
			.map { Float($0) * .pi / 180 } // convert to radians
			.map { SIMD2(x: cos($0), y: sin($0)) }
			.map { $0 * radius }
	}
}
