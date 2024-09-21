extends Sprite2D


@export_category("Size")
@export var grid_size: Vector2i = Vector2i(80, 40)
@export var cell_size: Vector2i = Vector2i(10, 10)

@export_category("Display")
@export var cell_dead_color: Color = Color.DARK_SLATE_BLUE
@export var cell_alive_color: Color = Color.WHITE_SMOKE
@export var grid_color: Color = Color.TURQUOISE
@export var show_grid: bool = true

@export_category("Simulation")
@export var simulation_fps: float = 3.0
@export var is_simulation_paused: bool = false

var time = 0


class Grid:
	var grid: Array[Array] = []
	var size: Vector2i
	
	static func create_empty(size: Vector2i) -> Grid:
		var obj := Grid.new()
		obj.size = size
		obj.grid.resize(size.x)
		for i in size.x:
			obj.grid[i] = []
			obj.grid[i].resize(size.y)
			obj.grid[i].fill(false)
		return obj
	
	func set_value(pos: Vector2i, value: bool):
		grid[pos.x][pos.y] = value
		
	func get_value(pos: Vector2i) -> bool:
		var x := pos.x
		if x < 0:
			x += size.x
		if x >= size.x:
			x -= size.x
		var y := pos.y
		if y < 0:
			y += size.y
		if y >= size.y:
			y -= size.y
		return grid[x][y]
		
	func alive_neighbors_count(pos: Vector2i) -> int:
		var c = 0
		if self.get_value(pos + Vector2i.UP + Vector2i.LEFT):
			c += 1
		if self.get_value(pos + Vector2i.UP):
			c += 1
		if self.get_value(pos + Vector2i.UP + Vector2i.RIGHT):
			c += 1
		if self.get_value(pos + Vector2i.LEFT):
			c += 1
		if self.get_value(pos + Vector2i.RIGHT):
			c += 1
		if self.get_value(pos + Vector2i.DOWN + Vector2i.LEFT):
			c += 1
		if self.get_value(pos + Vector2i.DOWN):
			c += 1
		if self.get_value(pos + Vector2i.DOWN + Vector2i.RIGHT):
			c += 1
		return c

var state: Grid
var future_state: Grid

var state_image: Image

func _ready() -> void:
	state = Grid.create_empty(grid_size)
	# glider
	#state.set_value(Vector2i(10, 2), true)
	#state.set_value(Vector2i(11, 3), true)
	#state.set_value(Vector2i(12, 1), true)
	#state.set_value(Vector2i(12, 2), true)
	#state.set_value(Vector2i(12, 3), true)
	
	future_state = Grid.create_empty(grid_size)
	_update_texture_size()
	_update_cells()
	
	
func _update_texture_size() -> void:
	var image := Image.create_empty(grid_size.x * cell_size.x, grid_size.y * cell_size.y, false, Image.FORMAT_RGBA8)
	image.fill(cell_dead_color)
	var tex := ImageTexture.create_from_image(image)
	texture = tex
	
	state_image = Image.create_empty(grid_size.x, grid_size.y, false, Image.FORMAT_R8)
	
	material.set("shader_parameter/grid_size", grid_size)
	material.set("shader_parameter/alive_color", cell_alive_color)
	material.set("shader_parameter/dead_color", cell_dead_color)

func _update_cells() -> void:
	
	state_image.fill(Color.BLACK)
	for i in grid_size.x: 
		for j in grid_size.y:
			var pos := Vector2i(i, j)
			var is_alive := state.get_value(pos)
			if is_alive:
				state_image.set_pixel(pos.x, pos.y, Color.WHITE)
	
	material.set("shader_parameter/cells", ImageTexture.create_from_image(state_image))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	if !is_simulation_paused:
		time += delta
		
	if Input.is_action_just_pressed("ui_accept"):
		is_simulation_paused = !is_simulation_paused
		
	
	var tick_time = 1 / simulation_fps
	
	if time >= tick_time:
		time = 0
		tick()
		
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and not event.is_echo() and event.button_index == MOUSE_BUTTON_LEFT:
		if Rect2(position, grid_size * cell_size).has_point(event.position):
			var click_pos: Vector2 = event.position - position
			_mouse_clicked(click_pos)
			get_viewport().set_input_as_handled()
	
func _mouse_clicked(local_pos: Vector2) -> void:
	var grid_pos := Vector2i(local_pos) / cell_size
	print(grid_pos)
	state.set_value(grid_pos, !state.get_value(grid_pos))
	_update_cells()

func tick() -> void:
	
	future_state = future_state.create_empty(grid_size)
	for i in grid_size.x: 
		for j in grid_size.y:
			var pos := Vector2i(i, j)
			var is_alive := state.get_value(pos)
			var neighbors := state.alive_neighbors_count(pos)
			
			if is_alive:
				if neighbors >= 2:
					future_state.set_value(pos, true)
				if neighbors > 3:
					future_state.set_value(pos, false)
			else:
				if neighbors == 3:
					future_state.set_value(pos, true)
				
	state.grid = future_state.grid
	_update_cells()
	
	
func _draw() -> void:
	#for i in grid_size.x: 
		#for j in grid_size.y:
			#var pos := Vector2i(i, j)
			#var from := pos * cell_size
			#var cell := Rect2i(from, cell_size)
			#var color := cell_alive_color if state.get_value(pos) else cell_dead_color
#
			#draw_rect(cell, color)
			#if show_grid:
				#draw_rect(cell, grid_color, false, 1)
	pass
