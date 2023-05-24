import bpy
from sys import argv

# usage:
# blender --background input.blend --factory-startup --python export_vertices.py -- output.vertices

output_file_name = argv[-1]

def make_string(vertex): 
    return f"{vertex[0]} {vertex[1]} {vertex[2]}"

output = []
for object in bpy.context.scene.objects:
    if object.type != "MESH":
        continue

    vertices = [x.co for x in object.data.vertices.values()]

    # rotation_matrix = object.rotation_euler.to_matrix()
    # rotation_matrix.resize_4x4()
    # object.data.transform(rotation_matrix)
    
    # print(object.scale)
    
    # rotation_matrix = object.rotation_euler.to_matrix()
    # rotation_matrix.resize_4x4()
    # object.data.transform(rotation_matrix)
    
    matrix_basis = object.matrix_basis
    object.data.transform(matrix_basis)

    for triangle in object.data.loop_triangles:
        triangle_vertices = [vertices[x] for x in triangle.vertices]
        triangle_vertices = [make_string(x) for x in triangle_vertices]
        output.append(" ".join(triangle_vertices))

with open(output_file_name, "w") as file:
    file.write("\n".join(output))

print("\nwrite complete!")
