extends Node3D

@export var ray_cast_3D: RayCast3D
@export var tick_gap: int = 5

signal add_node_to_root(node: Node)

var should_draw: bool = false
var line_renderer: LineRenderer3D
var curr_tick: int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if should_draw and line_renderer and ray_cast_3D.is_colliding():
		Debug.log("draw")
		var collider: Node3D = ray_cast_3D.get_collider()
		if curr_tick == 0 and collider:
			Debug.log("add point")
			line_renderer.points.append(ray_cast_3D.get_collision_point() + (collider.global_transform.basis.y * 0.025))
		curr_tick = (curr_tick + 1) % tick_gap

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("draw"):
		if line_renderer:
			line_renderer.queue_free()
		
		line_renderer = LineRenderer3D.new()
		line_renderer.points.clear()
		
		var new_material = StandardMaterial3D.new()
		new_material.albedo_color = Color.BLACK
		
		line_renderer.material_override = new_material
		
		add_node_to_root.emit(line_renderer)
		should_draw = true
		
	if event.is_action_released("draw"):
		should_draw = false
		curr_tick = 0
