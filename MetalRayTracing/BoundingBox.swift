//
//  BoundingBox.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-05.
//

import Metal

//struct BoundingBox {
//	var min: MTLPackedFloat3
//	var max: MTLPackedFloat3
//}
struct BoundingBox {
	var min: SIMD3<Float>
	var max: SIMD3<Float>
}
