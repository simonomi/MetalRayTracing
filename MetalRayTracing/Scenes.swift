//
//  Scenes.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-04.
//

// an infinite glowing plane with a circle of blue cubes on top
func scene1() -> Scene {
	var scene = Scene()
	for i in -10..<10 {
		scene.add(
			Cube()
				.scale(by: 0.25)
				.translate(by: 1, on: .zAxis)
				.rotate(by: (18 * i).degreesToRadians, aroundThe: .yAxis)
				.color(.blue)
		)
	}
	scene.add(
		Cube() // light
			.scale(by: 50, on: .xAxis)
			.scale(by: 0.1, on: .yAxis)
			.scale(by: 50, on: .zAxis)
			.translate(by: -0.25, on: .yAxis)
			.color(.white)
			.emit()
	)
	return scene
}

// a red cube in a white room with a rotated white glowing cube above
func scene2() -> Scene {
	var scene = Scene()
	scene.add(
		Cube() // main boi
			.scale(by: 0.5)
			.rotate(by: 45.degreesToRadians, aroundThe: .yAxis)
			.translate(by: -0.4, on: .yAxis)
			.color(.red)
	)
	scene.add(
		Cube() // room
			.reverseNormals()
			.scale(by: 1.25)
			.color(.white)
	)
	scene.add(
		Cube() // light
			.scale(by: 0.25)
			.rotate(by: 45.degreesToRadians, aroundThe: .xAxis)
			.rotate(by: 45.degreesToRadians, aroundThe: .yAxis)
			.rotate(by: 45.degreesToRadians, aroundThe: .zAxis)
			.translate(by: 0.4, on: .yAxis)
			.color(.white)
			.emit()
	)
	scene = scene.translate(by: 2, on: .zAxis)
	return scene
}

// a white cube in a room with a red left wall, blue right wall,
// green floor, grey back, and white top
// with a light behind you
func scene3() -> Scene {
	var scene = Scene()
	scene.add(
		Cube() // light
			.scale(by: 50, on: .xAxis)
			.scale(by: 50, on: .yAxis)
			.scale(by: 0.1, on: .zAxis)
			.translate(by: -2.1, on: .zAxis)
			.color(.white)
			.emit()
	)
	scene.add(
		Cube() // main boi
			.scale(by: 0.5)
			.rotate(by: 45.degreesToRadians, aroundThe: .yAxis)
			.translate(by: -0.4, on: .yAxis)
			.color(.white)
	)
	scene.add(
		Cube() // left wall
			.scale(by: 0.01, on: .xAxis)
			.scale(by: 1.25, on: .yAxis)
			.scale(by: 1.25, on: .zAxis)
			.translate(by: -0.625, on: .xAxis)
			.color(.red)
	)
	scene.add(
		Cube() // right wall
			.scale(by: 0.01, on: .xAxis)
			.scale(by: 1.25, on: .yAxis)
			.scale(by: 1.25, on: .zAxis)
			.translate(by: 0.625, on: .xAxis)
			.color(.blue)
	)
	scene.add(
		Cube() // floor
			.scale(by: 1.25, on: .xAxis)
			.scale(by: 0.01, on: .yAxis)
			.scale(by: 1.25, on: .zAxis)
			.translate(by: -0.625, on: .yAxis)
			.color(.green)
	)
	scene.add(
		Cube() // ceiling
			.scale(by: 1.25, on: .xAxis)
			.scale(by: 0.01, on: .yAxis)
			.scale(by: 1.25, on: .zAxis)
			.translate(by: 0.625, on: .yAxis)
			.color(.white)
	)
	scene.add(
		Cube() // back
			.scale(by: 1.25, on: .xAxis)
			.scale(by: 1.25, on: .yAxis)
			.scale(by: 0.01, on: .zAxis)
			.translate(by: 0.625, on: .zAxis)
			.color(.grey)
	)
	scene = scene.translate(by: 2, on: .zAxis)
	return scene
}

// three cubes of varying reflectiveness
// in a room with a red left wall, blue right wall,
// green floor, white back, and white top
// with a white light in the ceiling
func scene4() -> Scene {
	var scene = Scene()
	scene.add(
		Cube() // light
			.scale(by: 0.5, on: .xAxis)
			.scale(by: 0.02, on: .yAxis)
			.scale(by: 0.5, on: .zAxis)
			.translate(by: 0.625, on: .yAxis)
			.color(.white)
			.emit(strength: 4)
	)
	scene.add(
		Cube() // left wall
			.scale(by: 0.01, on: .xAxis)
			.scale(by: 1.25, on: .yAxis)
			.scale(by: 1.25, on: .zAxis)
			.translate(by: -1, on: .xAxis)
			.color(.red)
	)
	scene.add(
		Cube() // right wall
			.scale(by: 0.01, on: .xAxis)
			.scale(by: 1.25, on: .yAxis)
			.scale(by: 1.25, on: .zAxis)
			.translate(by: 1, on: .xAxis)
			.color(.blue)
	)
	scene.add(
		Cube() // floor
			.scale(by: 2, on: .xAxis)
			.scale(by: 0.01, on: .yAxis)
			.scale(by: 1.25, on: .zAxis)
			.translate(by: -0.625, on: .yAxis)
			.color(.green)
	)
	scene.add(
		Cube() // ceiling
			.scale(by: 2, on: .xAxis)
			.scale(by: 0.01, on: .yAxis)
			.scale(by: 1.25, on: .zAxis)
			.translate(by: 0.625, on: .yAxis)
			.color(.white)
	)
	scene.add(
		Cube() // back wall
			.scale(by: 2, on: .xAxis)
			.scale(by: 1.25, on: .yAxis)
			.scale(by: 0.01, on: .zAxis)
			.translate(by: 0.625, on: .zAxis)
			.color(.white)
	)
	scene.add(
		Cube() // front wall
			.scale(by: 2.75)
			.translate(by: -2, on: .zAxis)
			.color(.white)
	)
	scene.add(
		Cube() // left cube - 50% reflectiveness
			.scale(by: 0.25)
			.rotate(by: 45.degreesToRadians, aroundThe: .yAxis)
			.rotate(by: -45.degreesToRadians, aroundThe: .xAxis)
			.translate(by: -0.5, on: .xAxis)
			.color(.white)
			.reflectiveness(0.5)
	)
	scene.add(
		Cube() // middle cube - 75% reflectiveness
			.scale(by: 0.25)
			.rotate(by: 45.degreesToRadians, aroundThe: .yAxis)
			.rotate(by: -45.degreesToRadians, aroundThe: .xAxis)
			.color(.white)
			.reflectiveness(0.75)
	)
	scene.add(
		Cube() // right cube - 100% reflectiveness
			.scale(by: 0.25)
			.rotate(by: 45.degreesToRadians, aroundThe: .yAxis)
			.rotate(by: -45.degreesToRadians, aroundThe: .xAxis)
			.translate(by: 0.5, on: .xAxis)
			.color(.white)
			.reflectiveness(1)
	)
	scene = scene.translate(by: 2, on: .zAxis)
	return scene
}
