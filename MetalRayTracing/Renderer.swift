//
//  Renderer.swift
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-02.
//

import Metal
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
	let device: MTLDevice
	let commandQueue: MTLCommandQueue
	
	let rayTracingPipeline: MTLComputePipelineState
	let intersectionFunctionTable: MTLIntersectionFunctionTable
	let copyPipeline: MTLRenderPipelineState
	
	var accelerationStructure: MTLAccelerationStructure!
	
	let gpuLock = DispatchSemaphore(value: 1)
	
	let uniformsBuffer: MTLBuffer
	var accumulationTargets = [MTLTexture]()
	
	var scene: Scene
	
	init?(metalKitView: MTKView) {
		device = metalKitView.device!
		commandQueue = device.makeCommandQueue()!
		
		do {
			rayTracingPipeline = try Self.buildRayTracingPipeline(device)
			intersectionFunctionTable = try Self.buildIntersectionFunctionTable(rayTracingPipeline, device)
			copyPipeline = try Self.buildCopyPipeline(device, metalKitView)
		} catch {
			print("Unable to compile pipeline states: \(error)")
			return nil
		}
		
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
		
		scene = scene4()
		
		super.init()
		
		mtkView(metalKitView, drawableSizeWillChange: metalKitView.drawableSize)
		
		createAccelerationStructure(for: scene)
	}
	
	static func buildRayTracingPipeline(_ device: MTLDevice) throws -> MTLComputePipelineState {
		let library = device.makeDefaultLibrary()!
		
		let pipelineDescriptor = MTLComputePipelineDescriptor()
		
		let computeFunction = library.makeFunction(name: "rayTracingKernel")!
		pipelineDescriptor.computeFunction = computeFunction
		
		let linkedFunctions = MTLLinkedFunctions()
		let sphereIntersectionFunction = library.makeFunction(name: "sphereIntersectionFunction")!
		linkedFunctions.functions = [sphereIntersectionFunction]
		pipelineDescriptor.linkedFunctions = linkedFunctions
		
		return try device.makeComputePipelineState(function: computeFunction)
	}
	
	static func buildIntersectionFunctionTable(_ rayTracingPipeline: MTLComputePipelineState, _ device: MTLDevice) -> MTLIntersectionFunctionTable {
		let intersectionFunctionTableDescriptor = MTLIntersectionFunctionTableDescriptor()
		intersectionFunctionTableDescriptor.functionCount = 2
		
		let intersectionFunctionTable = rayTracingPipeline.makeIntersectionFunctionTable(descriptor: intersectionFunctionTableDescriptor)!
		
		let library = device.makeDefaultLibrary()!
		let sphereIntersectionFunction = library.makeFunction(name: "sphereIntersectionFunction")!
		let sphereIntersectionFunctionHandle = rayTracingPipeline.functionHandle(function: sphereIntersectionFunction)
		intersectionFunctionTable.setFunction(sphereIntersectionFunctionHandle, index: 0)
		
		return intersectionFunctionTable
	}
	
	static func buildCopyPipeline(_ device: MTLDevice, _ metalKitView: MTKView) throws -> MTLRenderPipelineState {
		let library = device.makeDefaultLibrary()!
		
		let pipelineDescriptor = MTLRenderPipelineDescriptor()
		pipelineDescriptor.vertexFunction = library.makeFunction(name: "copyVertex")
		pipelineDescriptor.fragmentFunction = library.makeFunction(name: "copyFragment")
		pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
		
		return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
	}
	
	func createAccelerationStructure(for renderable: Renderable) {
		// triangles
		let triangleGeometryDescriptor = MTLAccelerationStructureTriangleGeometryDescriptor()
		
		let triangles = renderable.getTriangles()
		let trianglePrimitiveData = device.makeBuffer(
			bytes: triangles,
			length: MemoryLayout<Triangle>.stride * triangles.count
		)
		let triangleVertexBuffer = device.makeBuffer(
			bytes: triangles.flatMap { $0.getVertices() },
			length: MemoryLayout<SIMD3<Float>>.stride * triangles.count * 3
		)
		
		triangleGeometryDescriptor.vertexBuffer = triangleVertexBuffer
		triangleGeometryDescriptor.vertexStride = MemoryLayout<SIMD3<Float>>.stride
		triangleGeometryDescriptor.triangleCount = triangles.count
		
		triangleGeometryDescriptor.primitiveDataBuffer = trianglePrimitiveData
		triangleGeometryDescriptor.primitiveDataStride = MemoryLayout<Triangle>.stride
		triangleGeometryDescriptor.primitiveDataElementSize = MemoryLayout<Triangle>.size
		
		let triangleAccelerationStructureDescriptor = MTLPrimitiveAccelerationStructureDescriptor()
		
		triangleAccelerationStructureDescriptor.geometryDescriptors = [triangleGeometryDescriptor]
		
		let triangleAccelerationStructure = createAccelerationStructure(from: triangleAccelerationStructureDescriptor, with: device)
		
		// bounding boxes
		let boundingBoxPrimatives = renderable.getBoundingBoxePrimatives()
		let boundingBoxPrimitiveData = device.makeBuffer(
			bytes: boundingBoxPrimatives,
			length: MemoryLayout<BoundingBoxPrimative>.stride
		)
		let boundingBoxBuffer = device.makeBuffer(
			bytes: boundingBoxPrimatives.map { $0.getBoundingBox() },
			length: MemoryLayout<BoundingBox>.stride
		)
		
		let boundingBoxGeometryDescriptor = MTLAccelerationStructureBoundingBoxGeometryDescriptor()
		
		boundingBoxGeometryDescriptor.boundingBoxBuffer = boundingBoxBuffer
		boundingBoxGeometryDescriptor.boundingBoxStride = MemoryLayout<BoundingBox>.stride
		boundingBoxGeometryDescriptor.boundingBoxCount = boundingBoxPrimatives.count
		
		boundingBoxGeometryDescriptor.primitiveDataBuffer = boundingBoxPrimitiveData
		boundingBoxGeometryDescriptor.primitiveDataStride = MemoryLayout<Renderable>.stride
		boundingBoxGeometryDescriptor.primitiveDataElementSize = MemoryLayout<Renderable>.size
		
		boundingBoxGeometryDescriptor.intersectionFunctionTableOffset = 0
		
		let boundingBoxAccelerationStructureDescriptor = MTLPrimitiveAccelerationStructureDescriptor()
		
		boundingBoxAccelerationStructureDescriptor.geometryDescriptors = [boundingBoxGeometryDescriptor]
		
		let boundingBoxAccelerationStructure = createAccelerationStructure(from: boundingBoxAccelerationStructureDescriptor, with: device)
		
		// combined instanceAccelerationStructure
		let accelerationStructureDescriptor = MTLInstanceAccelerationStructureDescriptor()
		
		let instanceDescriptors = (0...1).map {
			var instanceDescriptor = MTLAccelerationStructureInstanceDescriptor()
			instanceDescriptor.accelerationStructureIndex = UInt32($0)
			instanceDescriptor.mask = UInt32($0)
//			instanceDescriptor.intersectionFunctionTableOffset = 0
//			instanceDescriptor.options =
			return instanceDescriptor
		}
		
		let instanceDescriptorBuffer = device.makeBuffer(
			bytes: instanceDescriptors,
			length: MemoryLayout<MTLAccelerationStructureInstanceDescriptor>.stride * instanceDescriptors.count
		)
		
		accelerationStructureDescriptor.instanceDescriptorBuffer = instanceDescriptorBuffer
		accelerationStructureDescriptor.instancedAccelerationStructures = [
			triangleAccelerationStructure, boundingBoxAccelerationStructure
		]
		accelerationStructureDescriptor.instanceCount = instanceDescriptors.count
		
		accelerationStructure = createAccelerationStructure(from: accelerationStructureDescriptor, with: device)
	}
	
	func createAccelerationStructure(
		from accelerationStructureDescriptor: MTLAccelerationStructureDescriptor,
		with device: MTLDevice
	) -> MTLAccelerationStructure {
		let sizes = device.accelerationStructureSizes(descriptor: accelerationStructureDescriptor)
		let accelerationStructure = device.makeAccelerationStructure(size: sizes.accelerationStructureSize)!
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
		
		return accelerationStructure
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
	}
	
	func updateUniforms(size: CGSize) {
		let uniformsPointer = uniformsBuffer.contents().bindMemory(to: Uniforms.self, capacity: 1)
		
		uniformsPointer.pointee.width = UInt32(size.width)
		uniformsPointer.pointee.height = UInt32(size.height)
		
		let fieldOfView = 45.degreesToRadians
		
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
		
		guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
		
		guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
		
		computeEncoder.setBuffer(uniformsBuffer, offset: 0, index: 0)
		computeEncoder.setTexture(accumulationTargets[0], index: 0)
		computeEncoder.setTexture(accumulationTargets[1], index: 1)
		computeEncoder.setAccelerationStructure(accelerationStructure, bufferIndex: 1)
		computeEncoder.setIntersectionFunctionTable(intersectionFunctionTable, bufferIndex: 2)
		
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
		
		guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
		guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
		
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
