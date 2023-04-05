//
//  Cube.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-02.
//

import Metal

struct Cube: Renderable {
	var triangles: [Triangle]
	
	private static let vertices: [SIMD3<Float>] = [
		SIMD3(-0.5, -0.5, -0.5),
		SIMD3( 0.5, -0.5, -0.5),
		SIMD3(-0.5,  0.5, -0.5),
		SIMD3( 0.5,  0.5, -0.5),
		SIMD3(-0.5, -0.5,  0.5),
		SIMD3( 0.5, -0.5,  0.5),
		SIMD3(-0.5,  0.5,  0.5),
		SIMD3( 0.5,  0.5,  0.5)
	]
	
	private static let tris = [
		(0, 4, 6),
		(0, 6, 2),
		(1, 3, 7),
		(1, 7, 5),
		(0, 1, 5),
		(0, 5, 4),
		(2, 6, 7),
		(2, 7, 3),
		(0, 2, 3),
		(0, 3, 1),
		(4, 5, 7),
		(4, 7, 6)
	]
	
	init() {
		triangles = Self.tris.map { tri in
			Triangle(
				vertices: (
					Self.vertices[tri.0],
					Self.vertices[tri.1],
					Self.vertices[tri.2]
				),
				color: SIMD3.random(in: 0..<1),
				reflectiveness: 0,
				emits: 0
			)
		}
	}
	
	private init(_ triangles: [Triangle]) {
		self.triangles = triangles
	}
	
	func getVertices() -> [SIMD3<Float>] {
		getTriangles().flatMap { $0.getVertices() }
	}
	
	func getTriangles() -> [Triangle] {
		triangles
	}
	
	func apply(_ operation: Operation) -> Cube {
		Cube(triangles.map { $0.apply(operation) })
	}
}
