extends Control

@onready var tick_graph: Panel = $VBoxContainer/GraphContainer/Tick/TickMemoryGraph
@onready var total_graph: Panel = $VBoxContainer/GraphContainer/Total/TotalMemoryGraph

# Used to get information from the managed runtime
@onready var managed_bridge: Node = $"../ManagedBridge"

## The number of frames to keep in history for graph.
const HISTORY_NUM_FRAMES := 180
const GRAPH_SIZE := Vector2(180, 64)

# History of the last `HISTORY_NUM_FRAMES` rendered frames.
var tick_memory_history: Array[float] = []
var total_memory_history: Array[float] = []

# Name of the inpit action used to toggle visibility of the memory monitor
const input_action_name: String = "cycle_managed_memory_monitor"

## Memory monitor display style.
enum DisplayStyle {
	HIDDEN,           ## Debug menu is hidden.
	VISIBLE_COMPACT,  ## Debug menu is visible, with only the FPS, FPS cap (if any) and time taken to render the last frame.
	VISIBLE_DETAILED, ## Debug menu is visible with full information, including graphs.
	MAX,              ## Represents the size of the DisplayStyle enum.
}

## The style to use when drawing the debug menu.
var style := DisplayStyle.HIDDEN:
	set(value):
		style = value
		match style:
			DisplayStyle.HIDDEN:
				visible = false
			DisplayStyle.VISIBLE_COMPACT, DisplayStyle.VISIBLE_DETAILED:
				visible = true
				$VBoxContainer/GraphContainer.visible = style == DisplayStyle.VISIBLE_DETAILED


func _init() -> void:
	# This must be done here instead of `_ready()` to avoid having `visibility_changed` be emitted immediately.
	visible = false

	if not InputMap.has_action(input_action_name):
		# Create default input action if no user-defined override exists.
		# We can't do it in the editor plugin's activation code as it doesn't seem to work there.
		InputMap.add_action(input_action_name)
		var event := InputEventKey.new()
		event.keycode = KEY_F4
		InputMap.action_add_event(input_action_name, event)


func _ready() -> void:
	tick_graph.draw.connect(_tick_graph_draw)
	total_graph.draw.connect(_total_graph_draw)

	tick_memory_history.resize(HISTORY_NUM_FRAMES)
	total_memory_history.resize(HISTORY_NUM_FRAMES)


func _process(float) -> void:
	if visible:
		tick_graph.queue_redraw()
		total_graph.queue_redraw()
	
		# Collection counts for all GC generations
		$VBoxContainer/CollectionHistory/Gen0Value.text = str(managed_bridge.GetCollectionCount(0))
		$VBoxContainer/CollectionHistory/Gen1Value.text = str(managed_bridge.GetCollectionCount(1))
		$VBoxContainer/CollectionHistory/Gen2Value.text = str(managed_bridge.GetCollectionCount(2))
		
		# Memory per tick
		var tick_memory = managed_bridge.GetTickMemoryMB()		
		tick_memory_history.push_back(tick_memory)
		if tick_memory_history.size() > HISTORY_NUM_FRAMES:
			tick_memory_history.pop_front()
			
		# Total managed memory
		var total_memory = managed_bridge.GetTotalMemoryMB()
		total_memory_history.push_back(total_memory)
		if total_memory_history.size() > HISTORY_NUM_FRAMES:
			total_memory_history.pop_front()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(input_action_name):
		style = wrapi(style + 1, 0, DisplayStyle.MAX) as DisplayStyle


func _on_visibility_changed() -> void:
	if visible:
		# Reset graphs to prevent them from looking strange before `HISTORY_NUM_FRAMES` frames
		# have been drawn.
		tick_memory_history.resize(HISTORY_NUM_FRAMES)
		tick_memory_history.fill(0)
		total_memory_history.resize(HISTORY_NUM_FRAMES)
		total_memory_history.fill(0)


func _tick_graph_draw() -> void:
	var min := tick_memory_history.min()
	var max := tick_memory_history.max()
	$VBoxContainer/GraphContainer/Tick/MinTickValue.text = str(min)
	$VBoxContainer/GraphContainer/Tick/MaxTickValue.text = str(max)
	
	var polyline := PackedVector2Array()
	polyline.resize(HISTORY_NUM_FRAMES)
	for index in tick_memory_history.size():
		var height: float = 0.0
		if min != max:
			height = remap(tick_memory_history[index], min, max, 0.0, GRAPH_SIZE.y)
			
		var x := remap(index, 0, tick_memory_history.size(), 0, GRAPH_SIZE.x)
		var y := GRAPH_SIZE.y - height
		var width := 1
		var bar := Rect2(x, y, width, height)
		tick_graph.draw_rect(bar, Color8(255, 0, 0))


func _total_graph_draw() -> void:
	var min := total_memory_history.min()
	var max := total_memory_history.max()
	$VBoxContainer/GraphContainer/Total/MinTotalValue.text = str(min).pad_decimals(2)
	$VBoxContainer/GraphContainer/Total/MaxTotalValue.text = str(max).pad_decimals(2)
	
	var polyline := PackedVector2Array()
	polyline.resize(HISTORY_NUM_FRAMES)
	for index in total_memory_history.size():
		var height: float = 0.0
		if min != max:
			height = remap(total_memory_history[index], min, max, GRAPH_SIZE.y, 0.0)
		
		polyline[index] = Vector2(
			remap(index, 0, total_memory_history.size(), 0, GRAPH_SIZE.x),
			height
		)

	total_graph.draw_polyline(polyline, Color8(255, 0, 0), 1.0, false)
