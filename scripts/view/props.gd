class_name Props
extends RefCounted
## Helpers to build placeholder scenery from primitive meshes.


static func material(color: Color, roughness: float = 0.9) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	if color.a < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat


static func box(parent: Node3D, size: Vector3, mat: Material, position: Vector3) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh_instance(parent, mesh, mat, position)


static func mesh_instance(parent: Node3D, mesh: Mesh, mat: Material, position: Vector3) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = mat
	instance.position = position
	parent.add_child(instance)
	return instance


static func label(parent: Node3D, text: String, font_size: int, position: Vector3, outline: Color) -> Label3D:
	var label_3d := Label3D.new()
	label_3d.text = text
	label_3d.font_size = font_size
	label_3d.pixel_size = 0.006
	label_3d.outline_size = font_size / 8
	label_3d.outline_modulate = outline
	label_3d.position = position
	parent.add_child(label_3d)
	return label_3d
