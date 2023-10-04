//
//  Mesh.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-06.
//

import Foundation
import AppKit

struct Mesh {
	var triangles: [Triangle]
	
	enum Asset: String {
		case imp = "imp.vertices"
		case bigSphere = "big sphere.vertices"
		case sphere = "sphere.vertices"
		case suzanne = "suzanne.vertices"
		case bigMonke = "big monke.vertices"
		case velociraptor = "velociraptor.vertices"
		case dwaneTheCockJohnson = "dwane the cock johnson.vertices"
	}
	
	init(_ asset: Asset) {
		guard let data = NSDataAsset(name: asset.rawValue)?.data else {
			fatalError("missing asset \(asset)")
		}
		
		let vertexData = String(data: data, encoding: .utf8)!
		
		guard let mesh = Mesh(vertexData: vertexData) else {
			fatalError("error creating mesh from \(asset): unexpected number of vertices")
		}
		self = mesh
	}
	
	init(_ filePath: String) {
		let url = URL(filePath: filePath)
		let data = try! Data(contentsOf: url)
		let vertexData = String(data: data, encoding: .utf8)!
		
		guard let mesh = Mesh(vertexData: vertexData) else {
			fatalError("error creating mesh from \"\(filePath)\": unexpected number of vertices")
		}
		self = mesh
	}
	
	private init?(vertexData: String) {
		let triangles = vertexData
			.split(separator: "\n")
			.map(String.init)
			.map(Triangle.init)
		
		guard !triangles.contains(nil) else { return nil }
		self.triangles = triangles.compactMap { $0 }
	}
}

extension Mesh: Renderable {
	private init(_ triangles: [Triangle]) {
		self.triangles = triangles
	}
	
	func getVertices() -> [SIMD3<Float>] {
		triangles.flatMap { $0.getVertices() }
	}
	
	func getTriangles() -> [Triangle] {
		triangles
	}
	
	func apply(_ operation: Operation) -> Mesh {
		Mesh(triangles.map { $0.apply(operation) })
	}
}
