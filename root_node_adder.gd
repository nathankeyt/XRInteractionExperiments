extends Node

func _on_node_3d_add_node_to_root(node: Node) -> void:
	get_parent().add_child(node)


func _on_pen_add_node_to_root(node: Node) -> void:
	get_parent().add_child(node)
