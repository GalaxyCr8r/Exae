extends Timer



func _on_Timer_timeout():
	print("TICK")
	for node in get_tree().get_nodes_in_group("tickable"):
		print("TOCK")
		if node.has_method("tick"):
			print("tick()")
			node.tick()
