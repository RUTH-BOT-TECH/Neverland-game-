extends Node3D
## Village blockout assembled once at load. Includes CC0 modular art.
## Foliage uses shared meshes and MultiMesh instances; see asset credits.

const TREE_SCENES := [
	preload("res://assets/models/quaternius_nature/CommonTree_1.gltf"),
	preload("res://assets/models/quaternius_nature/CommonTree_2.gltf")
]
const MEADOW_SCENES := [
	preload("res://assets/models/quaternius_nature/Grass_Common_Short.gltf"),
	preload("res://assets/models/quaternius_nature/Grass_Common_Tall.gltf"),
	preload("res://assets/models/quaternius_nature/Flower_3_Group.gltf")
]
const WINDOW_SCENE := preload("res://assets/models/quaternius_village/Window_Wide_Flat1.gltf")
const DOOR_SCENE := preload("res://assets/models/quaternius_village/Door_1_Flat.gltf")
const GABLE_SCENE := preload("res://assets/models/quaternius_village/Roof_Front_Brick4.gltf")
const CRATE_SCENE := preload("res://assets/models/quaternius_village/Prop_Crate.gltf")
const ROOF_SCENE := preload("res://assets/models/quaternius_village/Roof_RoundTiles_4x4.gltf")
const CHIMNEY_SCENE := preload("res://assets/models/quaternius_village/Prop_Chimney.gltf")
const WAGON_SCENE := preload("res://assets/models/quaternius_village/Prop_Wagon.gltf")
const VINE_SCENES := [preload("res://assets/models/quaternius_village/Prop_Vine1.gltf"), preload("res://assets/models/quaternius_village/Prop_Vine2.gltf")]
const BANNER_TEXTURE := preload("res://assets/textures/eldoria/royal_banner.png")
const WOOD_TEXTURE := preload("res://assets/textures/polyhaven/brown_planks_04.jpg")
const ROAD_TEXTURE := preload("res://assets/textures/polyhaven/mossy_cobblestone.jpg")

var meshes: Dictionary = {}
var materials: Dictionary = {}

func _ready() -> void:
	_setup_assets()
	_build_path()
	_build_houses()
	_build_landmarks()
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

func _part(parent: Node3D, mesh_key: String, part_name: String, position: Vector3, rotation: Vector3 = Vector3.ZERO, part_scale: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = part_name
	part.mesh = meshes[mesh_key]
	part.position = position
	part.rotation_degrees = rotation
	part.scale = part_scale
	parent.add_child(part)
	return part

func _model(parent: Node3D, scene: PackedScene, model_name: String, pos: Vector3, rot: Vector3 = Vector3.ZERO, model_scale: Vector3 = Vector3.ONE) -> Node3D:
	var model := scene.instantiate() as Node3D
	model.name = model_name
	model.position = pos
	model.rotation_degrees = rot
	model.scale = model_scale
	parent.add_child(model)
	return model

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
			_model(house, DOOR_SCENE, "DetailedDoor", Vector3(-0.53, 0.24, 2.12), Vector3.ZERO, Vector3(1, 1, 1))
			for x in [-1.2, 1.2]:
				_model(house, WINDOW_SCENE, "FrontWindow", Vector3(x, 0.5, 2.12), Vector3.ZERO, Vector3(0.65, 0.65, 0.65))
			for z in [-1.0, 1.0]:
				_model(house, WINDOW_SCENE, "LeftWindow", Vector3(-2.1, 0.5, z), Vector3(0, -90, 0), Vector3(0.65, 0.65, 0.65))
				_model(house, WINDOW_SCENE, "RightWindow", Vector3(2.1, 0.5, z), Vector3(0, 90, 0), Vector3(0.65, 0.65, 0.65))
			_model(house, GABLE_SCENE, "GableFront", Vector3(0, 3.0, 2.02), Vector3.ZERO, Vector3(0.9, 0.75, 0.9))
			_model(house, GABLE_SCENE, "GableBack", Vector3(0, 3.0, -2.02), Vector3(0, 180, 0), Vector3(0.9, 0.75, 0.9))
			if row % 2 == 1:
				_model(house, VINE_SCENES[(row + (1 if side == 1 else 0)) % 2], "ClimbingVine", Vector3(1.75, 2.95, 2.15), Vector3.ZERO, Vector3.ONE * 0.8)
			if row % 2 == 0:
				_model(house, CRATE_SCENE, "Crate", Vector3(-1.7, 0, 2.65), Vector3(0, row * 35, 0), Vector3.ONE * 0.65)

func _build_trees() -> void:
	var group := Node3D.new()
	group.name = "Trees"
	add_child(group)
	for side in [-1, 1]:
		for row in range(9):
			var tree_position := Vector3(side * (12.0 + (row % 3) * 1.0), 0, 20.0 - row * 5.6)
			# Leave the survey platform and its approach visually unobstructed.
			if Vector2(tree_position.x - 10.0, tree_position.z + 8.0).length() < 6.5:
				continue
			var tree := Node3D.new()
			tree.name = "Tree_%s_%d" % ["West" if side == -1 else "East", row + 1]
			tree.position = tree_position
			group.add_child(tree)
			var tree_model := TREE_SCENES[row % TREE_SCENES.size()].instantiate() as Node3D
			tree_model.name = "TreeModel"
			tree_model.scale = Vector3.ONE * (0.75 + (row % 3) * 0.09)
			tree_model.rotation_degrees.y = row * 43
			tree.add_child(tree_model)

func _build_landmarks() -> void:
	# Decorative wayfinding and a royal crest: the five empty settings refer
	# to the lost Orbs. These props do not block player movement.
	var group := Node3D.new()
	group.name = "VillageLandmarks"
	add_child(group)
	var banner_material := StandardMaterial3D.new()
	banner_material.albedo_texture = BANNER_TEXTURE
	banner_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	banner_material.alpha_scissor_threshold = 0.5
	banner_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	banner_material.roughness = 1.0
	var cloth := QuadMesh.new()
	cloth.size = Vector2(0.95, 1.43)
	cloth.material = banner_material
	var pole_mesh := CylinderMesh.new()
	pole_mesh.top_radius = 0.055
	pole_mesh.bottom_radius = 0.075
	pole_mesh.height = 3.8
	pole_mesh.radial_segments = 8
	pole_mesh.material = materials["timber"]
	for side in [-1, 1]:
		var pole := MeshInstance3D.new()
		pole.name = "BannerPole"
		pole.mesh = pole_mesh
		pole.position = Vector3(side * 3.25, 1.9, 3.0)
		group.add_child(pole)
		var flag := MeshInstance3D.new()
		flag.name = "EldorianBannerWest" if side == -1 else "EldorianBannerEast"
		flag.mesh = cloth
		flag.position = Vector3(side * 3.25 - side * 0.5, 2.95, 3.02)
		group.add_child(flag)
	_model(group, WAGON_SCENE, "VillageWagon", Vector3(-10.2, 0, 5.8), Vector3(0, 25, 0), Vector3.ONE * 0.75)
	var post := MeshInstance3D.new()
	post.name = "Waypost"
	post.mesh = pole_mesh
	post.position = Vector3(3.25, 1.1, -2.2)
	post.scale.y = 0.58
	group.add_child(post)
	var board_mesh := BoxMesh.new()
	board_mesh.size = Vector3(1.75, 0.35, 0.12)
	board_mesh.material = materials["timber"]
	for i in range(2):
		var board := MeshInstance3D.new()
		board.name = "DirectionBoard%d" % i
		board.mesh = board_mesh
		board.position = Vector3(3.6, 2.02 - i * 0.42, -2.18)
		group.add_child(board)
		var label := Label3D.new()
		label.name = "DirectionText%d" % i
		label.text = ["RUINS  >", "TRIAL GROUNDS  >"][i]
		label.font_size = 40
		label.pixel_size = 0.0038
		label.modulate = Color(1.0, 0.86, 0.58)
		label.outline_size = 0
		label.position = board.position + Vector3(0, 0, 0.065)
		group.add_child(label)

func _build_hills() -> void:
	# Original, low-poly backdrop only: the playable ground still ends at its
	# existing bounds. Faceted ridge replaces the six obvious cone placeholders.
	var group := Node3D.new()
	group.name = "DistantHills"
	add_child(group)
	var rock := StandardMaterial3D.new()
	rock.vertex_color_use_as_albedo = true
	rock.roughness = 1.0
	rock.cull_mode = BaseMaterial3D.CULL_DISABLED
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var depths := [-32.0, -39.0, -48.0, -60.0]
	var strengths := [0.0, 0.60, 1.0, 0.12]
	var points: Array = []
	for row in range(depths.size()):
		var line: Array[Vector3] = []
		for i in range(31):
			var x := -60.0 + i * 4.0
			var peak := 3.0
			for center in [-48.0, -25.0, -3.0, 18.0, 40.0, 57.0]:
				peak += 11.0 * exp(-pow((x - center) / 7.0, 2))
			var rough := sin(x * 1.7 + row * 3.0) * 0.8 + cos(x * 0.7 + row) * 0.6
			line.append(Vector3(x, -1.0 + strengths[row] * (peak + rough), depths[row]))
		points.append(line)
	for row in range(depths.size() - 1):
		for i in range(30):
			var a: Vector3 = points[row][i]
			var b: Vector3 = points[row][i + 1]
			var c: Vector3 = points[row + 1][i]
			var d: Vector3 = points[row + 1][i + 1]
			_rock_triangle(surface, a, c, b, row, i)
			_rock_triangle(surface, b, c, d, row, i + 9)
	var backdrop := MeshInstance3D.new()
	backdrop.name = "RockyRidge"
	backdrop.mesh = surface.commit()
	backdrop.material_override = rock
	backdrop.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	group.add_child(backdrop)

func _rock_triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, row: int, index: int) -> void:
	var normal := (b - a).cross(c - a).normalized()
	if normal.y < 0.0:
		normal = -normal
	var shade := 0.77 + 0.10 * sin(float(index * 19 + row * 31))
	var color := Color(0.60 * shade, 0.58 * shade, 0.49 * shade)
	for vertex in [a, b, c]:
		surface.set_normal(normal)
		surface.set_color(color)
		surface.add_vertex(vertex)

func _build_meadow() -> void:
	# Shared MultiMeshes reduce draw-call overhead. Counts remain conservative;
	# alpha overdraw and overall performance still require real-device profiling.
	var rng := RandomNumberGenerator.new()
	rng.seed = 5317
	var counts := [500, 180, 55]
	for kind in range(MEADOW_SCENES.size()):
		var temporary: Node = (MEADOW_SCENES[kind] as PackedScene).instantiate()
		var sources: Array[Node] = temporary.find_children("*", "MeshInstance3D", true, false)
		if sources.is_empty():
			push_warning("Meadow model has no mesh")
			temporary.free()
			continue
		var source: Mesh = (sources[0] as MeshInstance3D).mesh
		var multi := MultiMesh.new()
		multi.transform_format = MultiMesh.TRANSFORM_3D
		multi.mesh = source
		var positions: Array[Vector3] = []
		while positions.size() < counts[kind]:
			var x := rng.randf_range(-19.0, 19.0)
			var z := rng.randf_range(-24.0, 24.0)
			if absf(x) < 2.6:
				continue
			# Keep the survey platform and its southern entrance clear.
			if absf(x - 10.0) < 3.5 and z > -11.5 and z < -3.5:
				continue
			var blocked := false
			for row in range(4):
				if absf(absf(x) - 6.5) < 2.4 and absf(z - (11.0 - row * 8.0)) < 2.4:
					blocked = true
					break
			if blocked:
				continue
			positions.append(Vector3(x, 0.015, z))
		multi.instance_count = positions.size()
		for i in range(positions.size()):
			var size := rng.randf_range(0.23, 0.38) if kind < 2 else rng.randf_range(0.25, 0.35)
			var basis := Basis(Vector3.UP, rng.randf_range(0, TAU)).scaled(Vector3.ONE * size)
			multi.set_instance_transform(i, Transform3D(basis, positions[i]))
		var grass := MultiMeshInstance3D.new()
		grass.name = "Meadow_%d" % kind
		grass.multimesh = multi
		grass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(grass)
		temporary.free()
