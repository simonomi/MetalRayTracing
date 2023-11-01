//
//  DegreeOperator.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-05.
//

postfix operator °

extension BinaryInteger {
	/// Converts degrees to radians
	static postfix func ° (degrees: Self) -> Float {
		Float(degrees) * .pi / 180
	}
}
