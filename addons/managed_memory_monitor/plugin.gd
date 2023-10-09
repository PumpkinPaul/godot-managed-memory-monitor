@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton("ManagedMemoryMonitor", "res://addons/managed_memory_monitor/managed_memory_monitor.tscn")


func _exit_tree() -> void:
	remove_autoload_singleton("ManagedMemoryMonitor")
	# Don't remove the project setting's value and input map action,
	# as the plugin may be re-enabled in the future.
