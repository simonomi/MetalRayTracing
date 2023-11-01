//
//  DegreesOperator.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-05.
//

postfix operator °

extension BinaryInteger {
	static postfix func ° (lhs: Self) -> Float {
		Float(lhs) * .pi / 180
	}
}
