//
//  Scenes.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-04.
//

// an infinite glowing plane with a circle of blue cubes on top
@SceneBuilder func scene1() -> Renderable {
	for i in -10..<10 {
		Cube()
			.scale(by: 0.25)
			.translate(by: 1, on: .zAxis)
			.rotate(by: (18 * i).degreesToRadians, aroundThe: .yAxis)
			.color(.blue)
	}
	Cube() // light
		.scale(by: 50, on: .xAxis)
		.scale(by: 0.1, on: .yAxis)
		.scale(by: 50, on: .zAxis)
		.translate(by: -0.25, on: .yAxis)
		.emit()
}

// a red cube in a white room with a rotated white glowing cube above
@SceneBuilder func scene2() -> Renderable {
	Group {
		Cube() // main boi
			.scale(by: 0.5)
			.rotate(by: 45.degreesToRadians, aroundThe: .yAxis)
			.translate(by: -0.4, on: .yAxis)
			.color(.red)
		Cube() // room
			.reverseNormals()
			.scale(by: 1.25)
		Cube() // light
			.scale(by: 0.25)
			.rotate(by: 45.degreesToRadians, aroundThe: .xAxis)
			.rotate(by: 45.degreesToRadians, aroundThe: .yAxis)
			.rotate(by: 45.degreesToRadians, aroundThe: .zAxis)
			.translate(by: 0.4, on: .yAxis)
			.emit()
	}
	.translate(by: 2, on: .zAxis)
}

// a white cube in a room with a red left wall, blue right wall,
// green floor, grey back, and white top
// with a light behind you
@SceneBuilder func scene3() -> Renderable {
	Group {
		Cube() // light
			.scale(by: 50, on: .xAxis)
			.scale(by: 50, on: .yAxis)
			.scale(by: 0.1, on: .zAxis)
			.translate(by: -2.1, on: .zAxis)
			.emit()
		Cube() // main boi
			.scale(by: 0.5)
			.rotate(by: 45.degreesToRadians, aroundThe: .yAxis)
			.translate(by: -0.4, on: .yAxis)
//		Mesh(.velociraptor)
//			.scale(by: 0.00075)
//			.translate(by: 0.1, on: .zAxis)
//			.rotate(by: 225.degreesToRadians, aroundThe: .yAxis)
//			.translate(by: -0.3, on: .yAxis)
//			.reflectiveness(1)
		Cube() // left wall
			.scale(by: 0.01, on: .xAxis)
			.scale(by: 1.25, on: .yAxis)
			.scale(by: 1.25, on: .zAxis)
			.translate(by: -0.625, on: .xAxis)
			.color(.red)
		Cube() // right wall
			.scale(by: 0.01, on: .xAxis)
			.scale(by: 1.25, on: .yAxis)
			.scale(by: 1.25, on: .zAxis)
			.translate(by: 0.625, on: .xAxis)
			.color(.blue)
		Cube() // floor
			.scale(by: 1.25, on: .xAxis)
			.scale(by: 0.01, on: .yAxis)
			.scale(by: 1.25, on: .zAxis)
			.translate(by: -0.625, on: .yAxis)
			.color(.green)
		Cube() // ceiling
			.scale(by: 1.25, on: .xAxis)
			.scale(by: 0.01, on: .yAxis)
			.scale(by: 1.25, on: .zAxis)
			.translate(by: 0.625, on: .yAxis)
		Cube() // back
			.scale(by: 1.25, on: .xAxis)
			.scale(by: 1.25, on: .yAxis)
			.scale(by: 0.01, on: .zAxis)
			.translate(by: 0.625, on: .zAxis)
			.color(.grey)
	}
	.translate(by: 2, on: .zAxis)
}

// three spheres of varying reflectiveness
// in a room with a red left wall, blue right wall,
// green floor, white back, and white top
// with a white light in the ceiling
@SceneBuilder func scene4() -> Renderable {
	Group {
		Cube() // light
			.scale(by: 0.5, on: .xAxis)
			.scale(by: 0.02, on: .yAxis)
			.scale(by: 0.5, on: .zAxis)
			.translate(by: 0.625, on: .yAxis)
			.emit(strength: 2)
		Cube() // left wall
			.scale(by: 0.01, on: .xAxis)
			.scale(by: 1.25, on: .yAxis)
			.scale(by: 1.25, on: .zAxis)
			.translate(by: -1, on: .xAxis)
			.color(.red)
		Cube() // right wall
			.scale(by: 0.01, on: .xAxis)
			.scale(by: 1.25, on: .yAxis)
			.scale(by: 1.25, on: .zAxis)
			.translate(by: 1, on: .xAxis)
			.color(.blue)
		Cube() // floor
			.scale(by: 2, on: .xAxis)
			.scale(by: 0.01, on: .yAxis)
			.scale(by: 1.25, on: .zAxis)
			.translate(by: -0.625, on: .yAxis)
			.color(.green)
		Cube() // ceiling
			.scale(by: 2, on: .xAxis)
			.scale(by: 0.01, on: .yAxis)
			.scale(by: 1.25, on: .zAxis)
			.translate(by: 0.625, on: .yAxis)
		Cube() // back wall
			.scale(by: 2, on: .xAxis)
			.scale(by: 1.25, on: .yAxis)
			.scale(by: 0.01, on: .zAxis)
			.translate(by: 0.625, on: .zAxis)
		Cube() // front wall
			.scale(by: 2.75)
			.translate(by: -2, on: .zAxis)
		Mesh(.sphere) // left sphere - 50% reflectiveness
			.scale(by: 0.25)
			.translate(by: -0.5, on: .xAxis)
			.reflectiveness(0.5)
		Mesh(.sphere) // middle sphere - 75% reflectiveness
			.scale(by: 0.25)
			.reflectiveness(0.75)
		Mesh(.sphere) // right sphere - 100% reflectiveness
			.scale(by: 0.25)
			.translate(by: 0.5, on: .xAxis)
			.reflectiveness(1)
	}
	.translate(by: 2, on: .zAxis)
}
