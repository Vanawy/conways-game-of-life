extends TabContainer

@onready var game: Game = $"../Canvas"

@onready var pause_checkbox: CheckBox = $Simulation/pause/checkbox
@onready var fps_input: LineEdit = $Simulation/fps/input
@onready var wrap_checkbox: CheckBox = $Simulation/wrap/checkbox
@onready var paused_label: Label = $"../Paused Label"
@onready var reset_btn: Button = $Simulation/Reset

@onready var color_alive: ColorPickerButton = $"Display/alive color/color"
@onready var color_dead: ColorPickerButton = $"Display/dead color/color2"
@onready var color_grid: ColorPickerButton = $"Display/grid color/color3"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	reset_btn.pressed.connect(func() -> void:
		game.reset()
	)
	
	pause_checkbox.button_pressed = game.is_simulation_paused
	paused_label.visible = game.is_simulation_paused
	pause_checkbox.toggled.connect(func(v: bool):
		game.is_simulation_paused = v
		paused_label.visible = v
	)
	
	fps_input.text = str(game.simulation_fps)
	fps_input.text_submitted.connect(func(text):
		var v = float(text)
		if v >= 0.01:
			game.simulation_fps = v
		fps_input.text = str(game.simulation_fps)
	)
	
	wrap_checkbox.button_pressed = game.is_warped
	wrap_checkbox.toggled.connect(func(v: bool):
		game.is_warped = v
	)
	
	color_alive.color = game.cell_alive_color
	color_alive.color_changed.connect(func(color: Color):
		game.cell_alive_color = color
		game.update_colors()
	)
	color_dead.color = game.cell_dead_color
	color_dead.color_changed.connect(func(color: Color):
		game.cell_dead_color = color
		game.update_colors()
	)
	color_grid.color = game.grid_color
	color_grid.color_changed.connect(func(color: Color):
		game.grid_color = color
		game.update_colors()
	)
