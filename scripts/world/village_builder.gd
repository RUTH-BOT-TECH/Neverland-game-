extends Node3D
## Lightweight, original blockout. Generated once on load, not every frame.
## The visual assets are deliberately placeholders and use shared meshes/materials.

const TREE_SCENE := preload("res://assets/models/gobkit/TreeMed001.glb")
const ROOF_SCENE := preload("res://assets/models/quaternius_village/Roof_RoundTiles_4x4.gltf")
const CHIMNEY_SCENE := preload("res://assets/models/quaternius_village/Prop_Chimney.gltf")
const WOOD_TEXTURE := preload("res://assets/textures/polyhaven/brown_planks_04.jpg")
const ROAD_TEXTURE := preload("res://assets/textures/polyhaven/mossy_cobblestone.jpg")

var meshes: Dictionary = {}
var materials: Dictionary = {}

func _ready() -> void:
	_setup_assets()
	_build_path()
	_build_houses()
	_build_trees()
	_build_hills()
	_build_meadow()

func _material(key: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	materials[key] = material

func _box(key: String, size: Vector3, material: String) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = materials[material]
	meshes[key] = mesh

func _setup_assets() -> void:
	_material("timber", Color(0.25, 0.12, 0.065))
	_material("wall", Color(0.90, 0.84, 0.75))
	materials["wall"].albedo_texture = WOOD_TEXTURE
	materials["wall"].uv1_scale = Vector3(3, 2, 1)
	_material("roof", Color(0.13, 0.24, 0.31))
	_material("stone", Color(0.38, 0.39, 0.36))
	_material("road", Color(1, 1, 1))
	materials["road"].albedo_texture = ROAD_TEXTURE
	materials["road"].uv1_scale = Vector3(2, 20, 1)
	_material("road_alt", Color(0.36, 0.40, 0.37))
	_material("door", Color(0.22, 0.10, 0.055))
	_material("window", Color(0.86, 0.64, 0.30))
	_material("leaves", Color(0.19, 0.36, 0.18))
	_material("leaves_light", Color(0.30, 0.46, 0.20))
	_material("mountain", Color(0.43, 0.43, 0.36))
	_box("walls", Vector3(4, 2.8, 4), "wall")
	_box("base", Vector3(4.25, 0.35, 4.25), "stone")
	_box("roof", Vector3(2.75, 0.2, 4.7), "roof")
	_box("post", Vector3(0.20, 2.9, 0.20), "timber")
	_box("beam", Vector3(4.1, 0.18, 0.18), "timber")
	_box("door", Vector3(0.86, 1.8, 0.12), "door")
	_box("window", Vector3(0.66, 0.68, 0.10), "window")
	_box("window_bar_v", Vector3(0.06, 0.68, 0.06), "timber")
	_box("window_bar_h", Vector3(0.66, 0.06, 0.06), "timber")
	_box("tile", Vector3(4.4, 0.04, 42), "road")
	_box("tile_alt", Vector3(1.36, 0.06, 1.15), "road_alt")
	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.19
	trunk.bottom_radius = 0.32
	trunk.height = 2.8
	trunk.radial_segments = 7
	trunk.material = materials["timber"]
	meshes["trunk"] = trunk
	for key in ["leaves", "leaves_light"]:
		var foliage := SphereMesh.new()
		foliage.radius = 1.25
		foliage.height = 2.5
		foliage.radial_segments = 8
		foliage.rings = 4
		foliage.material = materials[key]
		meshes[key] = foliage
	var hill := CylinderMesh.new()
	hill.top_radius = 0.0
	hill.bottom_radius = 6.0
	hill.height = 8.0
	hill.radial_segments = 7
	hill.material = materials["mountain"]
	meshes["hill"] = hill

func _part(parent: Node3D, mesh_key: String, part_name: String, position: Vector3, rotation: Vector3 = Vector3.ZERO, part_scale: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = part_name
	part.mesh = meshes[mesh_key]
	part.position = position
	part.rotation_degrees = rotation
	part.scale = part_scale
	parent.add_child(part)
	return part

func _build_path() -> void:
	var path := Node3D.new()
	path.name = "CobblePath"
	add_child(path)
	_part(path, "tile", "MossyRoad", Vector3(0, 0.035, -1))

func _build_houses() -> void:
	var group := Node3D.new()
	group.name = "Houses"
	add_child(group)
	for side in [-1, 1]:
		for row in range(4):
			var house := StaticBody3D.new()
			house.name = "House_%s_%d" % ["West" if side == -1 else "East", row + 1]
			house.position = Vector3(side * 6.5, 0, 11.0 - row * 8.0)
			house.rotation_degrees.y = -side * 90
			group.add_child(house)
			var collider := CollisionShape3D.new()
			var shape := BoxShape3D.new()
			shape.size = Vector3(4.2, 3.0, 4.2)
			collider.shape = shape
			collider.position = Vector3(0, 1.5, 0)
			house.add_child(collider)
			_part(house, "base", "StoneFoundation", Vector3(0, 0.175, 0))
			_part(house, "walls", "Walls", Vector3(0, 1.75, 0))
			var roof := ROOF_SCENE.instantiate() as Node3D
			roof.name = "TiledRoof"
			roof.position = Vector3(0, 3.0, 0)
			roof.scale = Vector3(0.88, 0.75, 0.88)
			house.add_child(roof)
			if row % 2 == 0:
				var chimney := CHIMNEY_SCENE.instantiate() as Node3D
				chimney.name = "Chimney"
				chimney.position = Vector3(-1.0, 2.2, -0.8)
				chimney.scale = Vector3(0.65, 0.85, 0.65)
				house.add_child(chimney)
			for x in [-1.9, 1.9]:
				for z in [-1.93, 1.93]:
					_part(house, "post", "TimberPost", Vector3(x, 1.78, z))
			_part(house, "beam", "FrontBeam", Vector3(0, 2.8, 2.06))
			_part(house, "door", "Door", Vector3(0, 1.25, 2.08))
			for x in [-1.18, 1.18]:
				_part(house, "window", "Window", Vector3(x, 1.86, 2.08))
				_part(house, "window_bar_v", "WindowBarV", Vector3(x, 1.86, 2.15))
				_part(house, "window_bar_h", "WindowBarH", Vector3(x, 1.86, 2.15))

func _build_trees() -> void:
	var group := Node3D.new()
	group.name = "Trees"
	add_child(group)
	for side in [-1, 1]:
		for row in range(9):
			var tree := Node3D.new()
			tree.name = "Tree_%s_%d" % ["West" if side == -1 else "East", row + 1]
			tree.position = Vector3(side * (12.0 + (row % 3) * 1.0), 0, 20.0 - row * 5.6)
			group.add_child(tree)
			var tree_model := TREE_SCENE.instantiate() as Node3D
			tree_model.name = "TreeModel"
			tree_model.scale = Vector3.ONE * (0.008 + (row % 3) * 0.001)
			tree_model.rotation_degrees.y = row * 43
			tree.add_child(tree_model)

func _build_hills() -> void:
	var group := Node3D.new()
	group.name = "DistantHills"
	add_child(group)
	for i in range(6):
		_part(group, "hill", "Hill_%d" % i, Vector3(-22 + i * 9, 3.5, -27.0 - (i % 2) * 4.0), Vector3(0, i * 12, 0), Vector3(1.2, 1.0 + (i % 3) * 0.3, 1.0))

func _build_meadow() -> void:
	# MultiMesh keeps hundreds of small decorative tufts in three draw batches.
	var rng := RandomNumberGenerator.new()
	rng.seed = 5317
	for kind in range(3):
		var material := StandardMaterial3D.new()
		material.albedo_color = [Color(0.20, 0.38, 0.12), Color(0.39, 0.53, 0.18), Color(0.88, 0.71, 0.21)][kind]
		material.roughness = 1.0
		var blade := BoxMesh.new()
		blade.size = Vector3(0.12 if kind < 2 else 0.08, 0.42 if kind < 2 else 0.25, 0.08)
		blade.material = material
		var multi := MultiMesh.new()
		multi.transform_format = MultiMesh.TRANSFORM_3D
		multi.mesh = blade
		var positions: Array[Vector3] = []
		while positions.size() < (350 if kind < 2 else 90):
			var x := rng.randf_range(-19.0, 19.0)
			var z := rng.randf_range(-24.0, 24.0)
			if absf(x) < 2.6:
				continue
			var blocked := false
			for row in range(4):
				if absf(absf(x) - 6.5) < 2.4 and absf(z - (11.0 - row * 8.0)) < 2.4:
					blocked = true
					break
			if blocked:
				continue
			positions.append(Vector3(x, 0.2 if kind < 2 else 0.12, z))
		multi.instance_count = positions.size()
		for i in range(positions.size()):
			var basis := Basis(Vector3.UP, rng.randf_range(0, TAU)).scaled(Vector3(1, rng.randf_range(0.7, 1.3), 1))
			multi.set_instance_transform(i, Transform3D(basis, positions[i]))
		var grass := MultiMeshInstance3D.new()
		grass.name = "Meadow_%d" % kind
		grass.multimesh = multi
		add_child(grass)
