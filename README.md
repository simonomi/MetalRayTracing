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
| ![ray tracing off](https://github.com/simonomi/MetalRayTracing/blob/main/renders/scene3%20rasterized.png?raw=true) | ![ray tracing off](https://github.com/simonomi/MetalRayTracing/blob/main/renders/scene3.png?raw=true) |

![suzanne, the blender monkey, as a disco ball](https://github.com/simonomi/MetalRayTracing/blob/main/renders/scene3%20suzanne.png?raw=true)
![a reflective velociraptor](https://github.com/simonomi/MetalRayTracing/blob/main/renders/scene3%20velociraptor.png?raw=true)
![a red cube with a glowing white cube floating above it in a white box](https://github.com/simonomi/MetalRayTracing/blob/main/renders/scene2.png?raw=true)
![three cubes of varying levels of reflectiveness](https://github.com/simonomi/MetalRayTracing/blob/main/renders/scene4.png?raw=true)
![three spheres of varying levels of reflectiveness](https://github.com/simonomi/MetalRayTracing/blob/main/renders/scene4%20spheres.png?raw=true)
