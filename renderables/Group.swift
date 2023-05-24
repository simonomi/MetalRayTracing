//
//  Group.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-03.
//

struct Group {
	var components = [Renderable]()
	
	init(_ components: [Renderable]) {
		self.components = components
	}
	
	init(@SceneBuilder components: () -> Renderable) {
		self.components = [components()]
	}
	
	mutating func add(_ component: Renderable) {
		components.append(component)
	}
}

extension Group: Renderable {
	func getVertices() -> [SIMD3<Float>] {
		components.flatMap { $0.getVertices() }
	}
	
	func getTriangles() -> [Triangle] {
		components.flatMap { $0.getTriangles() }
	}
	
	func apply(_ operation: Operation) -> Group {
		Group(components.map { $0.apply(operation) })
	}
}
