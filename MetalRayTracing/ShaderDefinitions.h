//
//  ShaderDefinitions.h
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-02.
//

#ifndef ShaderDefinitions_h
#define ShaderDefinitions_h

#include <simd/simd.h>

struct Camera {
	vector_float3 position;
	vector_float3 frustrum;
};

struct Uniforms {
	uint width;
	uint height;
	uint frameNumber;
	struct Camera camera;
};

struct UnknownPrimitive {
	int type;
};

struct Triangle {
	int type;
	vector_float3 vertices[3];
	vector_float3 color;
	float reflectiveness;
	int emits;
};

struct Sphere {
	int type;
	vector_float3 center;
	float radius;
	vector_float3 color;
	float reflectiveness;
	int emits;
};

#endif /* ShaderDefinitions_h */