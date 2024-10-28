extends Node3D

@export var ray_cast_3D: RayCast3D
@export var tick_gap: int = 5
@export var hand: XRToolsHand
@export var pivot: Node3D
@export var sensitivity: float = 45.0
@export var hold_point: Node3D

signal add_node_to_root(node: Node)

var should_draw: bool = false
var can_draw: bool = true
var line_renderer: LineRenderer3D
var curr_tick: int = 0
var holdable_object: Node3D
var holding_object: Node3D
var can_hold: bool = true

func _ready() -> void:
	if hand:
		hand._controller.button_pressed.connect(on_press)
		hand._controller.button_released.connect(on_release)

func on_press(name: String):
	Debug.log(name)
	if name == "trigger_click" and holdable_object:	
		holdable_object.reparent(hold_point)
		holdable_object.global_transform = hold_point.global_transform
		holding_object = holdable_object
		holdable_object = null
		can_draw = false
			
func on_release(name: String):
	Debug.log(name)
	if name == "trigger_click" and holding_object:
		holding_object.reparent(get_tree().root.get_node("/root/Main"), true)
		holding_object = null
		can_draw = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if hand:
		if hand._controller.get_float("grip") and not should_draw:
			start_draw()
			
		var joystick_axis: Vector2 = hand._controller.get_vector2("primary")
		if joystick_axis:
			pivot.rotation.y = -joystick_axis.x * sensitivity
			pivot.rotation.x = joystick_axis.y * sensitivity
			pivot.rotation.y = clamp(pivot.rotation.y, deg_to_rad(-45), deg_to_rad(45))
			pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-45), deg_to_rad(45))
			Debug.log(str(pivot.rotation))
		else:
			pivot.rotation.y = 0
			pivot.rotation.x = 0
			
	if holding_object:
		holding_object.global_transform = hold_point.global_transform
	
	if not hand._controller.get_float("grip") and should_draw:
		stop_draw()
		
	if can_draw and should_draw and line_renderer and ray_cast_3D.is_colliding():
		Debug.log("draw")
		var collider: Node3D = ray_cast_3D.get_collider()
		if curr_tick == 0 and collider:
			Debug.log("add point")
			line_renderer.points.append(ray_cast_3D.get_collision_point() + (collider.global_transform.basis.y * 0.01))
		curr_tick = (curr_tick + 1) % tick_gap

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("draw"):
		start_draw()
		
	if event.is_action_released("draw"):
		stop_draw()

func start_draw():
	if line_renderer:
		line_renderer.queue_free()
		
	line_renderer = LineRenderer3D.new()
	line_renderer.points.clear()
		
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = Color.BLACK
		
	line_renderer.material_override = new_material
		
	get_tree().root.get_node("/root/Main").add_child(line_renderer)
	should_draw = true

func stop_draw():
	should_draw = false
	curr_tick = 0


func _on_area_3d_body_entered(body: Node3D) -> void:
	holdable_object = body
	Debug.log("can_hold")

func _on_area_3d_body_exited(body: Node3D) -> void:
	holdable_object = null
