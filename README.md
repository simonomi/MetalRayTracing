## MetalRayTracing
A custom ray tracing engine written from scratch using Metal.

This was just for fun, with no practical application in mind, so it's little more than a proof-of-concept.
Theres no export feature, no niceties, no pure spheres (mesh spheres only), no nothing.

### Features
- Cubes
- Arbitrary meshes (extracted from `.blend` files using `export_vertices.py`)
- Light emission
- Variable reflectiveness
- Mesh operations (using Swift's result builder syntax)
  - Scale
  - Translate
  - Rotate
  - Reverse normals (turns a mesh inside-out)

### Showcase:

| Ray tracing off | Ray tracing on |
| - | - |
| ![ray tracing off](https://github.com/simonomi/MetalRayTracing/blob/main/renders/cube%20rasterized.png?raw=true) | ![ray tracing off](https://github.com/simonomi/MetalRayTracing/blob/main/renders/cube%20raytraced.png?raw=true) |

![suzanne, the blender monkey, completely reflective](https://github.com/simonomi/MetalRayTracing/blob/main/renders/big%20monke.png?raw=true)
![a large red reflective imp head in a box](https://github.com/simonomi/MetalRayTracing/blob/main/renders/imp.png?raw=true)
![a reflective velociraptor](https://github.com/simonomi/MetalRayTracing/blob/main/renders/velociraptor.png?raw=true)
![a red cube with a glowing white cube floating above it in a white box](https://github.com/simonomi/MetalRayTracing/blob/main/renders/red%20cube.png?raw=true)
![three spheres of varying levels of reflectiveness](https://github.com/simonomi/MetalRayTracing/blob/main/renders/three%20spheres.png?raw=true)

### TODO:
- make the mesh storage format more space-efficient so I don't have 200MB of wasted space on my machine
