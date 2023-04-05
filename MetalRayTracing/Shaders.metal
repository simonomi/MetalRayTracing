//
//  Shaders.metal
//  MetalRayTracing
//
//  Created by simon pellerin on 2023-04-02.
//

#define MAX_BOUNCES 10
#define RAYS_PER_PIXEL 1

#define TRIANGLE 0
#define SPHERE 1

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

float3 calculateNormal(Triangle triangle) {
	float3 e1 = triangle.vertices[1] - triangle.vertices[0];
	float3 e2 = triangle.vertices[2] - triangle.vertices[0];
	
	return normalize(cross(e1, e2));
}

bool isZero(float3 x) {
	return x.x == 0 && x.y == 0 && x.z == 0;
}

float3 traceRay(
	ray ray,
	thread uint* rngState,
	primitive_acceleration_structure accelerationStructure,
	intersection_function_table<triangle_data, instancing> intersectionFunctionTable
) {
	intersector<triangle_data> intersector;
	intersection_result<triangle_data> intersection;
	
	float3 rayColor = 1;
	
	for(int bounce = 0; bounce < MAX_BOUNCES + 1; bounce++) {
		intersection = intersector.intersect(ray, accelerationStructure, intersectionFunctionTable);
		
		if (intersection.type == intersection_type::none)
			return 0;
		
		UnknownPrimitive primitive = *(const device UnknownPrimitive*)intersection.primitive_data;
		
		float3 color, normal;
		float reflectiveness;
		int emits;
		
		if (primitive.type == TRIANGLE) {
			Triangle triangle = *(const device Triangle*)intersection.primitive_data;
			color = triangle.color;
			normal = calculateNormal(triangle);
			reflectiveness = triangle.reflectiveness;
			emits = triangle.emits;
		} else if (primitive.type == SPHERE) {
			Sphere sphere = *(const device Sphere*)intersection.primitive_data;
			color = sphere.color;
//			normal =
			reflectiveness = sphere.reflectiveness;
			emits = sphere.emits;
		} else {
			return 0;
		}
		
//		Triangle triangle = *(const device Triangle*)intersection.primitive_data;
		
		if (!intersection.triangle_front_facing) {
			ray.origin = ray.origin + ray.direction * (intersection.distance + 0.01);
			bounce--;
			continue;
		}
		
		rayColor *= color;
		
		if (emits)
			return rayColor;
		
		float3 intersectionPosition = ray.origin + ray.direction * intersection.distance;
		ray.origin = intersectionPosition + normal * 0.01;
		
		float3 diffuseDirection = randomDirection(rngState);
		diffuseDirection *= sign(dot(ray.direction, normal)); // flip towards normal if necessary
		
		float3 specularDirection = ray.direction - 2 * dot(ray.direction, normal) * normal;
		
		ray.direction = reflectiveness * specularDirection + (1 - reflectiveness) * diffuseDirection;
	}
	
	return rayColor;
//	return 0;
}

// it seems to me like c++ is allocating data for the result of `randomDirection`, setting `value` to that data, then the data is overwritten when `intersector.intersect` is called ??

kernel void rayTracingKernel(
	uint2 tid [[thread_position_in_grid]],
	constant Uniforms &uniforms [[buffer(0)]],
	texture2d<float> previousTexture [[texture(0)]],
	texture2d<float, access::write> destinationTexture [[texture(1)]],
	primitive_acceleration_structure accelerationStructure [[buffer(1)]],
	intersection_function_table<triangle_data, instancing> intersectionFunctionTable [[buffer(2)]]
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
		
		float3 outputColor = traceRay(ray, &rngState, accelerationStructure, intersectionFunctionTable);
		
		averageColor += outputColor;
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

struct BoundingBoxIntersection {
	bool accept    [[accept_intersection]];
	float distance [[distance]];
};

[[intersection(bounding_box)]]
BoundingBoxIntersection sphereIntersectionFunction(
	float3 origin [[origin]],
	float3 direction [[direction]],
	float minDistance [[min_distance]],
	float maxDistance [[max_distance]],
	const device void* primitive_data [[primitive_data]]
) {
	Sphere sphere = *(const device Sphere*)primitive_data;
	
	float3 oc = origin - sphere.center;
	
	float a = dot(direction, direction);
	float b = 2 * dot(oc, direction);
	float c = dot(oc, oc) - sphere.radius * sphere.radius;
	
	float disc = b * b - 4 * a * c;
	
	BoundingBoxIntersection ret;
	
	if (disc <= 0) {
		ret.accept = false;
	}
	else {
		ret.distance = (-b - sqrt(disc)) / (2 * a);
		ret.accept = ret.distance >= minDistance && ret.distance <= maxDistance;
	}
	
	return ret;
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

// Simple vertex shader that passes through NDC quad positions.
vertex CopyVertexOut copyVertex(unsigned short vid [[vertex_id]]) {
	float2 position = quadVertices[vid];
	
	CopyVertexOut out;
	
	out.position = float4(position, 0, 1);
	out.uv = position / 2 + 0.5;
	
	return out;
}

// Simple fragment shader that copies a texture and applies a simple tonemapping function.
fragment float4 copyFragment(CopyVertexOut in [[stage_in]], texture2d<float> texture) {
	constexpr sampler sampler;
	
	float3 color = texture.sample(sampler, in.uv).xyz;
	
	return float4(color, 1);
}
