extends Node3D
## Decorative artwork for the village survey ruins. The quest marker and
## platform collision remain in Foundation.tscn; this node adds no collisions.

const STONE_COLOR := preload("res://assets/textures/polyhaven/rock_wall_08_diff.jpg")
const STONE_NORMAL := preload("res://assets/textures/polyhaven/rock_wall_08_nor_gl.jpg")

func _ready() -> void:
	# Keep the existing interaction target, but make its silhouette distinct
	# from the collectible spherical Orbs.
	var marker := get_node("../TestMarker") as MeshInstance3D
	marker.mesh = _survey_crystal(marker.mesh.surface_get_material(0))
	var stone := StandardMaterial3D.new()
	stone.albedo_texture = STONE_COLOR
	stone.albedo_color = Color(0.8, 0.84, 0.78)
	stone.normal_enabled = true
	stone.normal_texture = STONE_NORMAL
	stone.normal_scale = 0.55
	stone.uv1_triplanar = true
	stone.uv1_scale = Vector3(1.0, 1.0, 1.0)
	stone.roughness = 1.0
	var trim := StandardMaterial3D.new()
	trim.albedo_color = Color(0.37, 0.35, 0.29)
	trim.roughness = 0.85
	var inlay := StandardMaterial3D.new()
	inlay.albedo_color = Color(0.70, 0.53, 0.25)
	inlay.metallic = 0.35
	inlay.roughness = 0.65

	var plinth := _cylinder(0.55, 0.58, 0.25, 12, stone)
	var shaft := _cylinder(0.34, 0.40, 1.8, 12, stone)
	var capital := _cylinder(0.56, 0.40, 0.30, 12, stone)
	var collar := _cylinder(0.43, 0.43, 0.09, 12, trim)
	for x in [-2.5, 2.5]:
		for z in [-2.5, 2.5]:
			var column := Node3D.new()
			column.name = "Column_%s_%s" % ["W" if x < 0 else "E", "N" if z < 0 else "S"]
			column.position = Vector3(x, 0.5, z)
			add_child(column)
			_part(column, plinth, "Foot", Vector3(0, 0.125, 0))
			_part(column, shaft, "Shaft", Vector3(0, 1.15, 0))
			_part(column, collar, "LowerCollar", Vector3(0, 0.31, 0))
			_part(column, collar, "UpperCollar", Vector3(0, 2.02, 0))
			_part(column, capital, "Capital", Vector3(0, 2.18, 0))

	# A damaged lintel at the rear keeps the southern approach open.
	var lintel := BoxMesh.new()
	lintel.size = Vector3(5.5, 0.30, 0.65)
	lintel.material = stone
	_part(self, lintel, "RearLintel", Vector3(0, 2.99, -2.5))
	var slab := _cylinder(0.79, 0.85, 0.15, 12, stone)
	_part(self, slab, "PedestalCrown", Vector3(0, 1.56, 0))

	# Five empty brass inlays reference the lost Orbs. They are decorative,
	# lie flat on the platform and are not collectible objects.
	var ring := TorusMesh.new()
	ring.inner_radius = 0.19
	ring.outer_radius = 0.24
	ring.rings = 24
	ring.ring_segments = 8
	ring.material = inlay
	for i in range(5):
		var angle := TAU * float(i) / 5.0 - PI / 2.0
		var socket := _part(self, ring, "EmptyInlay%d" % i, Vector3(cos(angle) * 1.7, 0.525, sin(angle) * 1.7))
		socket.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _survey_crystal(material: Material) -> ArrayMesh:
	var mesh_builder := SurfaceTool.new()
	mesh_builder.begin(Mesh.PRIMITIVE_TRIANGLES)
	mesh_builder.set_material(material)
	var top := Vector3(0, 0.58, 0)
	var bottom := Vector3(0, -0.42, 0)
	var rim := [Vector3(0.38, 0, 0), Vector3(0, 0, 0.38), Vector3(-0.38, 0, 0), Vector3(0, 0, -0.38)]
	for i in range(4):
		_crystal_face(mesh_builder, top, rim[(i + 1) % 4], rim[i])
		_crystal_face(mesh_builder, bottom, rim[i], rim[(i + 1) % 4])
	return mesh_builder.commit()

func _crystal_face(builder: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	var normal := (b - a).cross(c - a).normalized()
	if normal.dot((a + b + c) / 3.0) < 0:
		var temp := b
		b = c
		c = temp
		normal = -normal
	for vertex in [a, b, c]:
		builder.set_normal(normal)
		builder.add_vertex(vertex)

func _cylinder(top: float, bottom: float, height: float, sides: int, material: Material) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = top
	mesh.bottom_radius = bottom
	mesh.height = height
	mesh.radial_segments = sides
	mesh.material = material
	return mesh

func _part(parent: Node3D, mesh: Mesh, part_name: String, at: Vector3) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = part_name
	node.mesh = mesh
	node.position = at
	parent.add_child(node)
	return node
