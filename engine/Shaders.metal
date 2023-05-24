//
//  Shaders.metal
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-02.
//

#define MAX_BOUNCES 20
#define RAYS_PER_PIXEL 1

#include <metal_stdlib>
#include "ShaderDefinitions.h"
using namespace metal;
using namespace raytracing;

// https://www.pcg-random.org/
inline float pcg(thread uint* state) {
	*state = *state * 747796405 + 2891336453;
	uint result = ((*state >> ((*state >> 28) + 4)) ^ *state) * 277803737;
	result = (result >> 22) ^ result;
	return (float)result / UINT_MAX * 2 - 1;
}

inline float3 randomDirection(thread uint* state) {
	return normalize(float3(
		pcg(state),
		pcg(state),
		pcg(state)
	));
}

inline float3 calculateNormal(Triangle triangle) {
	float3 e1 = triangle.vertices[1] - triangle.vertices[0];
	float3 e2 = triangle.vertices[2] - triangle.vertices[0];
	
	return normalize(cross(e1, e2));
}

float3 traceRay(ray ray, thread uint* rngState, primitive_acceleration_structure accelerationStructure) {
	intersector<triangle_data> intersector;
	intersection_result<triangle_data> intersection;
	
	intersector.assume_geometry_type(geometry_type::triangle);
	intersector.force_opacity(forced_opacity::opaque);
	
	float3 rayColor = 1;
	
	for(int bounce = 0; bounce < MAX_BOUNCES + 1; bounce++) {
		intersection = intersector.intersect(ray, accelerationStructure);
		
		if (intersection.type == intersection_type::none)
			return 0;
		
		Triangle triangle = *(const device Triangle*)intersection.primitive_data;
		
		if (!intersection.triangle_front_facing) {
			ray.origin = ray.origin + ray.direction * (intersection.distance + 0.01);
			bounce--;
			continue;
		}
		
		if (triangle.emission)
			return rayColor * triangle.color * triangle.emission;
		
		rayColor *= triangle.color;
		
		float3 normal = calculateNormal(triangle);
		
		float3 intersectionPosition = ray.origin + ray.direction * intersection.distance;
		ray.origin = intersectionPosition + normal * 0.01;
		
		float3 diffuseDirection = normalize(normal + randomDirection(rngState));
		
		float3 specularDirection = ray.direction - 2 * dot(ray.direction, normal) * normal;
		
		ray.direction = triangle.reflectiveness * specularDirection + (1 - triangle.reflectiveness) * diffuseDirection;
	}
	
	return 0;
}

kernel void rayTracingKernel(
	uint2 tid [[thread_position_in_grid]],
	constant Uniforms &uniforms [[buffer(0)]],
	texture2d<float> previousTexture [[texture(0)]],
	texture2d<float, access::write> destinationTexture [[texture(1)]],
	primitive_acceleration_structure accelerationStructure [[buffer(1)]]
) {
	if (tid.x > uniforms.width || tid.y > uniforms.height)
		return;
	
	// rng seed
	thread uint rngState = (tid.y * uniforms.width + tid.x) * uniforms.frameNumber;
	
	// a little bit of antialiasing
	float2 pixel = (float2)tid + float2(pcg(&rngState), pcg(&rngState));
	float2 uv = pixel / float2(uniforms.width, uniforms.height);
	uv = uv * 2.0f - 1.0f;
	
	float3 averageColor = 0;
	
	for(int i = 0; i < RAYS_PER_PIXEL; i++) {
		ray ray;
		ray.origin = uniforms.camera.position;
		ray.direction = normalize(float3(uv, 1) * uniforms.camera.frustrum);
		ray.max_distance = INFINITY;
		
		averageColor += traceRay(ray, &rngState, accelerationStructure);
	}
	
	averageColor /= RAYS_PER_PIXEL;
	
	if (uniforms.frameNumber > 1) {
		float3 previousColor = previousTexture.read(tid).xyz;

		previousColor *= uniforms.frameNumber;

		averageColor += previousColor;
		averageColor /= uniforms.frameNumber + 1;
	}
	
	destinationTexture.write(float4(averageColor, 1), tid);
}

// screen-filling quad
constant float2 quadVertices[] = {
	float2(-1, -1),
	float2(-1,  1),
	float2( 1, -1),
	float2( 1,  1)
};

struct CopyVertexOut {
	float4 position [[position]];
	float2 uv;
};

vertex CopyVertexOut copyVertex(unsigned short vid [[vertex_id]]) {
	float2 position = quadVertices[vid];
	
	CopyVertexOut out;
	
	out.position = float4(position, 0, 1);
	out.uv = position / 2 + 0.5;
	
	return out;
}

fragment float4 copyFragment(CopyVertexOut in [[stage_in]], texture2d<float> texture) {
	return texture.sample(sampler(), in.uv);
}
