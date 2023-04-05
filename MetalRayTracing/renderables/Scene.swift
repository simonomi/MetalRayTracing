//
//  Scene.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-03.
//

import Metal

struct Scene: Renderable {
	var components = [Renderable]()
	
	init() {}
	
	init(_ components: [Renderable]) {
		self.components = components
	}
	
	func getVertices() -> [SIMD3<Float>] {
		components.flatMap { $0.getVertices() }
	}
	
	func getTriangles() -> [Triangle] {
		components.flatMap { $0.getTriangles() }
	}
	
	mutating func add(_ component: Renderable) {
		components.append(component)
	}
	
	func apply(_ operation: Operation) -> Scene {
		Scene(components.map { $0.apply(operation) })
	}
}
