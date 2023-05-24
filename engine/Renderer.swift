//
//  Renderer.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-02.
//

import Metal
import MetalKit

let framesToRender = 1000

class Renderer: NSObject, MTKViewDelegate {
	let device: MTLDevice
	let commandQueue: MTLCommandQueue
	
	let rayTracingPipeline: MTLComputePipelineState
	let copyPipeline: MTLRenderPipelineState
	
	var accelerationStructure: MTLAccelerationStructure!
	
	let gpuLock = DispatchSemaphore(value: 1)
	
	let uniformsBuffer: MTLBuffer
	let trianglesBuffer: MTLBuffer
	var accumulationTargets = [MTLTexture]()
	
	var scene: Renderable
	
	init(metalKitView: MTKView) {
		device = metalKitView.device!
		commandQueue = device.makeCommandQueue()!
		
		rayTracingPipeline = Self.buildRayTracingPipeline(device)
		copyPipeline = Self.buildCopyPipeline(device, metalKitView)
		
		var initialUniforms = Uniforms(
			width: UInt32(metalKitView.drawableSize.width),
			height: UInt32(metalKitView.drawableSize.height),
			frameNumber: 1,
			camera: Camera()
		)
		uniformsBuffer = device.makeBuffer(
			bytes: &initialUniforms,
			length: MemoryLayout<Uniforms>.size
		)!
		
		scene = scene3()
		
		let triangles = scene.getTriangles()
		trianglesBuffer = device.makeBuffer(
			bytes: triangles,
			length: triangles.count * MemoryLayout<Triangle>.stride
		)!
		
		super.init()
		
		mtkView(metalKitView, drawableSizeWillChange: metalKitView.drawableSize)
		
		let vertices = scene.getVertices()
		let vertexBuffer = device.makeBuffer(
			bytes: vertices,
			length: vertices.count * MemoryLayout<SIMD3<Float>>.stride
		)!
		
		createAccelerationStructure(vertexBuffer, triangleCount: triangles.count)
	}
	
	static func buildRayTracingPipeline(_ device: MTLDevice) -> MTLComputePipelineState {
		let library = device.makeDefaultLibrary()!
		
		let computeFunction = library.makeFunction(name: "rayTracingKernel")!
		
		return try! device.makeComputePipelineState(function: computeFunction)
	}
	
	static func buildCopyPipeline(_ device: MTLDevice, _ metalKitView: MTKView) -> MTLRenderPipelineState {
		let library = device.makeDefaultLibrary()!
		
		let pipelineDescriptor = MTLRenderPipelineDescriptor()
		pipelineDescriptor.vertexFunction = library.makeFunction(name: "copyVertex")
		pipelineDescriptor.fragmentFunction = library.makeFunction(name: "copyFragment")
		pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
		
		return try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
	}
	
	func createAccelerationStructure(_ vertexBuffer: MTLBuffer, triangleCount: Int) {
		let accelerationStructureDescriptor = MTLPrimitiveAccelerationStructureDescriptor()
		
		let geometryDescriptor = MTLAccelerationStructureTriangleGeometryDescriptor()
		
		geometryDescriptor.vertexBuffer = vertexBuffer
		geometryDescriptor.vertexStride = MemoryLayout<SIMD3<Float>>.stride
		
		geometryDescriptor.primitiveDataBuffer = trianglesBuffer
		geometryDescriptor.primitiveDataStride = MemoryLayout<Triangle>.stride
		geometryDescriptor.primitiveDataElementSize = MemoryLayout<Triangle>.size
		
		geometryDescriptor.triangleCount = triangleCount
		
		accelerationStructureDescriptor.geometryDescriptors = [geometryDescriptor]
		
		let sizes = device.accelerationStructureSizes(descriptor: accelerationStructureDescriptor)
		accelerationStructure = device.makeAccelerationStructure(size: sizes.accelerationStructureSize)!
		let scratchBuffer = device.makeBuffer(length: sizes.buildScratchBufferSize, options: .storageModePrivate)!
		
		let commandBuffer = commandQueue.makeCommandBuffer()!
		let commandEncoder = commandBuffer.makeAccelerationStructureCommandEncoder()!
		
		commandEncoder.build(
			accelerationStructure: accelerationStructure,
			descriptor: accelerationStructureDescriptor,
			scratchBuffer: scratchBuffer,
			scratchBufferOffset: 0
		)
		
		commandEncoder.endEncoding()
		commandBuffer.commit()
	}
	
	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
		let (width, height) = (Int(size.width), Int(size.height))
		
		let textureDescriptor = MTLTextureDescriptor()
		textureDescriptor.pixelFormat = view.colorPixelFormat
		textureDescriptor.textureType = .type2D
		textureDescriptor.width = width
		textureDescriptor.height = height
		
		textureDescriptor.storageMode = .private
		textureDescriptor.usage = [.shaderRead, .shaderWrite]
		
		accumulationTargets = (0..<2).map { _ in device.makeTexture(descriptor: textureDescriptor)! }
		
		updateUniforms(size: size)
		view.isPaused = false
	}
	
	func updateUniforms(size: CGSize) {
		let uniformsPointer = uniformsBuffer.contents().bindMemory(to: Uniforms.self, capacity: 1)
		
		uniformsPointer.pointee.width = UInt32(size.width)
		uniformsPointer.pointee.height = UInt32(size.height)
		
		let fieldOfView = 45.degreesToRadians
		
		// TODO: improve cleanliness?
		let aspectRatio = Float(size.width / size.height)
		let imagePlaneWidth: Float, imagePlaneHeight: Float
		if size.width < size.height {
			imagePlaneWidth = tan(fieldOfView) / 2
			imagePlaneHeight = imagePlaneWidth / aspectRatio
		} else {
			imagePlaneHeight = tan(fieldOfView) / 2
			imagePlaneWidth = aspectRatio * imagePlaneHeight
		}
		
		uniformsPointer.pointee.camera.position = SIMD3(0, 0, 0)
		uniformsPointer.pointee.camera.frustrum = SIMD3(imagePlaneWidth, imagePlaneHeight, 1)
		
		uniformsPointer.pointee.frameNumber = 1
	}
	
	func draw(in view: MTKView) {
		gpuLock.wait()
		
		let uniformsPointer = uniformsBuffer.contents().bindMemory(to: Uniforms.self, capacity: 1)
		uniformsPointer.pointee.frameNumber += 1
		print(uniformsPointer.pointee.frameNumber)
		
		if uniformsPointer.pointee.frameNumber == framesToRender {
			view.isPaused = true
			print("render complete")
			gpuLock.signal()
			return
		}
		
		let commandBuffer = commandQueue.makeCommandBuffer()!
		let computeEncoder = commandBuffer.makeComputeCommandEncoder()!
		
		computeEncoder.setBuffer(uniformsBuffer, offset: 0, index: 0)
		computeEncoder.setTexture(accumulationTargets[0], index: 0)
		computeEncoder.setTexture(accumulationTargets[1], index: 1)
		computeEncoder.setAccelerationStructure(accelerationStructure, bufferIndex: 1)
		
		computeEncoder.setComputePipelineState(rayTracingPipeline)
		
		let (width, height) = (Int(view.drawableSize.width), Int(view.drawableSize.height))
		let threadsPerThreadgroup = MTLSize(width: 8, height: 8, depth: 1)
		let threadGridSize = MTLSize(
			width: width / threadsPerThreadgroup.width + 1,
			height: height / threadsPerThreadgroup.height + 1,
			depth: 1
		)
		computeEncoder.dispatchThreadgroups(threadGridSize, threadsPerThreadgroup: threadsPerThreadgroup)
		
		computeEncoder.endEncoding()
		
		accumulationTargets.swapAt(0, 1)
		
		let renderPassDescriptor = view.currentRenderPassDescriptor!
		let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
		
		renderEncoder.setRenderPipelineState(copyPipeline)
		renderEncoder.setFragmentTexture(accumulationTargets[0], index: 0)
		renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
		
		renderEncoder.endEncoding()
		
		commandBuffer.present(view.currentDrawable!)
		commandBuffer.addCompletedHandler { _ in
			self.gpuLock.signal()
		}
		commandBuffer.commit()
	}
}
