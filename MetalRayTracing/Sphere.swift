//
//  Sphere.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-05.
//

import Metal

extension Sphere: Renderable, BoundingBoxPrimative {
	func getTriangles() -> [Triangle] { [] }
	func getBoundingBoxePrimatives() -> [BoundingBoxPrimative] { [self] }
	
	func getBoundingBox() -> BoundingBox {
		BoundingBox(
			min: center - radius,
			max: center + radius
		)
	}
	
	func apply(_ operation: Operation) -> Sphere {
		switch operation {
			case .scale(let scale):
				return self.scale(by: scale)
			case .translate(let displacement):
				return self.translate(by: displacement)
			case .rotate(let theta, let axis):
				return self.rotate(by: theta, aroundThe: axis)
			case .color(let color):
				return self.color(color)
			case .emit:
				return self.emit()
			case .reverseNormals:
				return self.reverseNormals()
			case .reflectiveness(let reflectiveness):
				return self.reflectiveness(reflectiveness)
		}
	}
	
	func scale(by: SIMD3<Float>) -> Sphere {
		Sphere()
	}
}
