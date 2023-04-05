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
	
	func getTriangles() -> [Triangle] {
		components.flatMap { $0.getTriangles() }
	}
	
	func getBoundingBoxePrimatives() -> [BoundingBoxPrimative] {
		components.flatMap { $0.getBoundingBoxePrimatives() }
	}
	
	mutating func add(_ component: Renderable) {
		components.append(component)
	}
	
	func apply(_ operation: Operation) -> Scene {
		Scene(components.map { $0.apply(operation) })
	}
}
