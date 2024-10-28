extends Node3D

@export var ray_cast_3D: RayCast3D
@export var tick_gap: int = 5

signal add_node_to_root(node: Node)

var is_not_drawing: bool = true
var line_renderer: LineRenderer3D
var curr_tick: int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if ray_cast_3D.is_colliding():
		if is_not_drawing:
			start_draw()
			is_not_drawing = false
			
		if line_renderer:
			Debug.log("draw")
			var collider: Node3D = ray_cast_3D.get_collider()
			if curr_tick == 0 and collider:
				Debug.log("add point")
				line_renderer.points.append(ray_cast_3D.get_collision_point() + (collider.global_transform.basis.y * 0.01))
			curr_tick = (curr_tick + 1) % tick_gap
			
	elif not is_not_drawing:
		is_not_drawing = true

func start_draw():
	if line_renderer:
		curr_tick = 0
		line_renderer.queue_free()
		
	line_renderer = LineRenderer3D.new()
	line_renderer.points.clear()
		
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = Color.BLACK
		
	line_renderer.material_override = new_material
		
	get_tree().root.get_node("/root/Main").add_child(line_renderer)
	
