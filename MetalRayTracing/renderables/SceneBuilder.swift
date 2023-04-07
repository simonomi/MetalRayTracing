//
//  SceneBuilder.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-06.
//

@resultBuilder
struct SceneBuilder {
	static func buildBlock(_ components: Renderable...) -> Renderable {
		Group(components)
	}
	
	static func buildArray(_ components: [Renderable]) -> Renderable {
		Group(components)
	}
}
