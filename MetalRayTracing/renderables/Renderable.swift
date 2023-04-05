//
//  Renderable.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-03.
//

import Metal

protocol Renderable {
	func getVertices() -> [SIMD3<Float>]
	func getTriangles() -> [Triangle]
	func apply(_ operation: Operation) -> Self
}

enum Operation {
	case scale(SIMD3<Float>)
	case translate(SIMD3<Float>)
	case rotate(Float, Axis)
	case color(Color)
	case emit(Float)
	case reverseNormals
	case reflectiveness(Float)
}

enum Axis {
	case xAxis, yAxis, zAxis
}

struct Color {
	var vector: SIMD3<Float>
	
	static let black = 		Color(   0,    0,    0)
	static let grey = 		Color( 0.5,  0.5,  0.5)
	static let white = 		Color(   1,    1,    1)
	static let red =		Color(0.85, 0.31, 0.25)
	static let orange =		Color(0.93, 0.46, 0.18)
	static let yellow =		Color(0.95, 0.75, 0.26)
	static let green =		Color(0.35, 0.65, 0.36)
	static let teal =		Color(0.41, 0.73, 0.77)
	static let blue =		Color(0.33, 0.51, 0.93)
	static let magenta =	Color(   1,    0,    1)
	
	init(_ red: Float, _ green: Float, _ blue: Float) {
		vector = SIMD3(red, green, blue)
	}
}

extension Renderable {
	// MARK: - scale
	func scale(by scale: SIMD3<Float>) -> Self {
		apply(.scale(scale))
	}
	
	func scale(by factor: Float) -> Self {
		scale(by: SIMD3(repeating: factor))
	}
	
	func scale(by factor: Float, on axis: Axis) -> Self {
		switch axis {
			case .xAxis:
				return scale(by: SIMD3(factor, 1, 1))
			case .yAxis:
				return scale(by: SIMD3(1, factor, 1))
			case .zAxis:
				return scale(by: SIMD3(1, 1, factor))
		}
	}
	
	// MARK: - translate
	func translate(by displacement: SIMD3<Float>) -> Self {
		apply(.translate(displacement))
	}
	
	func translate(by displacement: Float, on axis: Axis) -> Self {
		switch axis {
			case .xAxis:
				return translate(by: SIMD3(displacement, 0, 0))
			case .yAxis:
				return translate(by: SIMD3(0, displacement, 0))
			case .zAxis:
				return translate(by: SIMD3(0, 0, displacement))
		}
	}
	
	// MARK: - rotate
	func rotate(by theta: Float, aroundThe axis: Axis) -> Self {
		apply(.rotate(theta, axis))
	}
	
	// MARK: - color
	func color(_ color: Color) -> Self {
		apply(.color(color))
	}
	
	// MARK: - emit
	func emit(strength: Float = 1) -> Self {
		apply(.emit(strength))
	}
	
	// MARK: - reverse normals
	func reverseNormals() -> Self {
		apply(.reverseNormals)
	}
	
	// MARK: - reflectiveness
	func reflectiveness(_ reflectiveness: Float) -> Self {
		apply(.reflectiveness(reflectiveness))
	}
}
