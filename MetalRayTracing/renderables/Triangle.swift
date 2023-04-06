//
//  Triangle.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-02.
//

extension Triangle: Renderable {
	func getVertices() -> [SIMD3<Float>] {
		[vertices.0, vertices.1, vertices.2]
	}
	
	func getTriangles() -> [Triangle] {
		[self]
	}
	
	func getNormal() -> SIMD3<Float> {
		let e1 = vertices.1 - vertices.0;
		let e2 = vertices.2 - vertices.0;
		
		return normalize(cross(e1, e2));
	}
	
	// MARK: - operations
	func apply(_ operation: Operation) -> Triangle {
		switch operation {
			case .scale(let scale):
				return self.scale(by: scale)
			case .translate(let displacement):
				return self.translate(by: displacement)
			case .rotate(let theta, let axis):
				return self.rotate(by: theta, aroundThe: axis)
			case .color(let color):
				return self.color(color)
			case .emit(let strength):
				return self.emit(strength)
			case .reverseNormals:
				return self.reverseNormals()
			case .reflectiveness(let reflectiveness):
				return self.reflectiveness(reflectiveness)
		}
	}
	
	// MARK: - scale
	func scale(by scale: SIMD3<Float>) -> Triangle {
		Triangle(
			vertices: (
				vertices.0 * scale,
				vertices.1 * scale,
				vertices.2 * scale
			),
			color: color,
			reflectiveness: reflectiveness,
			emission: emission
		)
	}

	// MARK: - translate
	func translate(by displacement: SIMD3<Float>) -> Triangle {
		Triangle(
			vertices: (
				vertices.0 + displacement,
				vertices.1 + displacement,
				vertices.2 + displacement
			),
			color: color,
			reflectiveness: reflectiveness,
			emission: emission
		)
	}
	
	// MARK: - rotate
	/// https://en.wikipedia.org/wiki/Rotation_matrix#In_three_dimensions
	/// - Parameters:
	///   - axis: the axis to rotate around
	///   - theta: the degree to rotate by, in radians
	func rotate(by theta: Float, aroundThe axis: Axis) -> Triangle {
		let rotationMatrix: float3x3
		switch axis {
			case .xAxis:
				rotationMatrix = float3x3(
					SIMD3(1,  0,          0),
					SIMD3(0,  cos(theta), sin(theta)),
					SIMD3(0, -sin(theta), cos(theta))
				)
			case .yAxis:
				rotationMatrix = float3x3(
					SIMD3(cos(theta), 0, -sin(theta)),
					SIMD3(0,          1,  0),
					SIMD3(sin(theta), 0,  cos(theta))
				)
			case .zAxis:
				rotationMatrix = float3x3(
					SIMD3( cos(theta), sin(theta), 0),
					SIMD3(-sin(theta), cos(theta), 0),
					SIMD3( 0,          0,          1)
				)
		}
		
		return Triangle(
			vertices: (
				vertices.0 * rotationMatrix,
				vertices.1 * rotationMatrix,
				vertices.2 * rotationMatrix
			),
			color: color,
			reflectiveness: reflectiveness,
			emission: emission
		)
	}
	
	// MARK: - color
	func color(_ color: Color) -> Triangle {
		Triangle(vertices: vertices, color: color.vector, reflectiveness: reflectiveness, emission: emission)
	}
	
	// MARK: - emit
	func emit(_ strength: Float) -> Triangle {
		Triangle(vertices: vertices, color: color, reflectiveness: reflectiveness, emission: strength)
	}
	
	// MARK: - reverse normals
	func reverseNormals() -> Triangle {
		Triangle(
			vertices: (
				vertices.0,
				vertices.2,
				vertices.1
			),
			color: color,
			reflectiveness: reflectiveness,
			emission: emission
		)
	}
	
	// MARK: - reflectiveness
	func reflectiveness(_ reflectiveness: Float)-> Triangle {
		Triangle(vertices: vertices, color: color, reflectiveness: reflectiveness, emission: emission)
	}
}
