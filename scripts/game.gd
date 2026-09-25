extends Node2D

const ASSET_ROOT := "res://assets/sprites/Ninja Adventure - Asset Pack/"
const DOG_TEXTURE := preload("res://assets/sprites/Ninja Adventure - Asset Pack/Actor/Animal/Dog/SpriteSheet.png")
const OWNER_WALK_TEXTURE := preload("res://assets/sprites/Ninja Adventure - Asset Pack/Actor/Character/Villager/SeparateAnim/Walk.png")
const FLOOR_TEXTURE := preload("res://assets/sprites/Ninja Adventure - Asset Pack/Backgrounds/Tilesets/TilesetFloor.png")
const NATURE_TEXTURE := preload("res://assets/sprites/Ninja Adventure - Asset Pack/Backgrounds/Tilesets/TilesetNature.png")
const NET_TEXTURE := preload("res://assets/sprites/Ninja Adventure - Asset Pack/Backgrounds/Vehicles/FishNet.png")
const UI_PANEL_TEXTURE := preload("res://assets/sprites/Ninja Adventure - Asset Pack/Ui/Theme/Theme Wood/nine_path_panel.png")
const MUSIC_STREAM := preload("res://assets/sprites/Ninja Adventure - Asset Pack/Audio/Musics/20 - Good Time.ogg")
const DOG_SOUND := preload("res://assets/sprites/Ninja Adventure - Asset Pack/Audio/Sounds/Creature/Dog.wav")
const SNIFF_SOUND := preload("res://assets/sprites/Ninja Adventure - Asset Pack/Audio/Sounds/Magic & Skill/Spirit.wav")
const DASH_SOUND := preload("res://assets/sprites/Ninja Adventure - Asset Pack/Audio/Sounds/Whoosh & Slash/Whoosh.wav")
const NET_SOUND := preload("res://assets/sprites/Ninja Adventure - Asset Pack/Audio/Sounds/Whoosh & Slash/Launch.wav")
const CATCH_SOUND := preload("res://assets/sprites/Ninja Adventure - Asset Pack/Audio/Sounds/Hit & Impact/Hit3.wav")
const DISCOVER_SOUND := preload("res://assets/sprites/Ninja Adventure - Asset Pack/Audio/Sounds/Alert/Alert2.wav")
const WIN_SOUND := preload("res://assets/sprites/Ninja Adventure - Asset Pack/Audio/Jingles/Success2.wav")
const GRASS_SOUND := preload("res://assets/sprites/Ninja Adventure - Asset Pack/Audio/Sounds/Elemental/Grass.wav")

const VIEW_SIZE := Vector2(1280.0, 720.0)
const LEGACY_YARD_SIZE := Vector2(1152.0, 576.0)
const YARD_RECT := Rect2(Vector2(64.0, 80.0), Vector2(2304.0, 1152.0))
const MATCH_SECONDS := 120.0
const DISCOVERY_RADIUS := 72.0
const INTERACT_RADIUS := 42.0
const DOG_RADIUS := 16.0
const OWNER_RADIUS := 18.0
const DOG_SPEED := 235.0
const OWNER_SPEED := 195.0
const HOLD_SECONDS := 1.5
const DEBUG_SHORT_TIMER := 20.0
const DOG_DASH_COOLDOWN := 3.0
const DOG_DASH_DURATION := 0.18
const DOG_DASH_SPEED_MULTIPLIER := 3.2
const OWNER_NET_COOLDOWN := 2.5
const NET_SPEED := 560.0
const NET_LIFETIME := 0.85
const NET_RADIUS := 14.0
const CATCHES_TO_WIN := 3
const CATCH_INVULNERABILITY := 1.0
const DOG_SPAWN := Vector2(236.0, 1160.0)
const OWNER_SPAWN := Vector2(2196.0, 1160.0)
const SNIFF_COOLDOWN := 4.0
const SNIFF_FEEDBACK_DURATION := 1.5
const SNIFF_HOT_DISTANCE := 240.0
const SNIFF_WARM_DISTANCE := 600.0
const SNIFF_FAINT_DISTANCE := 1100.0
const CAMERA_PADDING := Vector2(320.0, 240.0)
const CAMERA_MIN_ZOOM := 0.45
const CAMERA_MAX_ZOOM := 1.25
const INTRO_DURATION := 3.0
const WORLD_TILE_SIZE := 64.0
const VEGETATION_COVERAGE := 0.60
const VEGETATION_TRIGGER_RADIUS := 34.0
const VEGETATION_SOUND_INTERVAL := 0.28
const VEGETATION_OBSTACLE_CLEARANCE := 64.0
const VEGETATION_JITTER_MARGIN := 16.0

const FLOOR_TILE_SOURCES: Array[Rect2] = [
	Rect2(0.0, 192.0, 16.0, 16.0),
	Rect2(48.0, 176.0, 16.0, 16.0),
	Rect2(64.0, 192.0, 16.0, 16.0),
]
const GRASS_SOURCES: Array[Rect2] = [
	Rect2(0.0, 160.0, 16.0, 16.0),
	Rect2(16.0, 160.0, 16.0, 16.0),
	Rect2(32.0, 160.0, 16.0, 16.0),
	Rect2(48.0, 160.0, 16.0, 16.0),
	Rect2(64.0, 160.0, 16.0, 16.0),
	Rect2(80.0, 160.0, 16.0, 16.0),
	Rect2(96.0, 160.0, 16.0, 16.0),
	Rect2(112.0, 160.0, 16.0, 16.0),
]
const FLOWER_SOURCES: Array[Rect2] = [
	Rect2(0.0, 176.0, 32.0, 16.0),
	Rect2(48.0, 176.0, 16.0, 16.0),
	Rect2(96.0, 176.0, 32.0, 16.0),
]
const TREE_SOURCES: Array[Rect2] = [
	Rect2(0.0, 0.0, 32.0, 32.0),
	Rect2(32.0, 0.0, 32.0, 32.0),
	Rect2(64.0, 0.0, 32.0, 32.0),
	Rect2(96.0, 0.0, 32.0, 32.0),
]
const STUMP_SOURCES: Array[Rect2] = [
	Rect2(0.0, 128.0, 32.0, 32.0),
	Rect2(32.0, 128.0, 32.0, 32.0),
]
const ROCK_SOURCES: Array[Rect2] = [
	Rect2(240.0, 160.0, 32.0, 32.0),
	Rect2(272.0, 160.0, 48.0, 48.0),
	Rect2(240.0, 224.0, 32.0, 32.0),
	Rect2(272.0, 224.0, 48.0, 48.0),
]

enum Phase { PLAYING, GAME_OVER }

var phase: Phase = Phase.PLAYING
var dog_pos := Vector2.ZERO
var owner_pos := Vector2.ZERO
var target_pos := Vector2.ZERO
var target_index := 0
var target_discovered := false
var dog_target_discovered := false
var owner_target_discovered := false
var time_left := MATCH_SECONDS
var result_title := ""
var result_detail := ""
var eat_progress := 0.0
var clean_progress := 0.0
var debug_visible := false
var debug_short_timer := false
var rng := RandomNumberGenerator.new()
var dog_facing := Vector2.RIGHT
var owner_facing := Vector2.LEFT
var dash_direction := Vector2.RIGHT
var dog_dash_cooldown_left := 0.0
var dog_dash_time_left := 0.0
var owner_net_cooldown_left := 0.0
var net_active := false
var net_pos := Vector2.ZERO
var net_direction := Vector2.ZERO
var net_lifetime_left := 0.0
var owner_catches := 0
var dog_catch_invulnerability_left := 0.0
var dash_key_was_down := false
var net_key_was_down := false
var restart_key_was_down := false
var cycle_key_was_down := false
var sniff_cooldown_left := 0.0
var sniff_feedback_left := 0.0
var sniff_heat_level := ""
var sniff_key_was_down := false
var camera_center := YARD_RECT.get_center()
var camera_zoom := 1.0
var intro_time_left := INTRO_DURATION
var animation_time := 0.0
var dog_move_direction := Vector2.ZERO
var owner_move_direction := Vector2.ZERO
var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var next_sfx_player := 0
var round_seed := 0
var round_rng := RandomNumberGenerator.new()
var floor_tile_indices := PackedInt32Array()
var obstacle_layout_index := 0
var obstacle_anchors: Array[Vector2] = []
var obstacle_kinds := PackedInt32Array()
var obstacle_variants := PackedInt32Array()
var vegetation_positions: Array[Vector2] = []
var vegetation_variants := PackedInt32Array()
var vegetation_phases := PackedFloat32Array()
var vegetation_sway := PackedFloat32Array()
var vegetation_sound_cooldown := 0.0

var target_points: Array[Vector2] = [
	Vector2(316.0, 252.0),
	Vector2(720.0, 228.0),
	Vector2(1284.0, 260.0),
	Vector2(2026.0, 236.0),
	Vector2(380.0, 696.0),
	Vector2(1032.0, 660.0),
	Vector2(1644.0, 724.0),
	Vector2(2156.0, 924.0),
]

var obstacles: Array[Rect2] = []

var obstacle_layouts: Array[Array] = [
	[
		Vector2(520.0, 340.0), Vector2(940.0, 300.0), Vector2(1540.0, 330.0), Vector2(1850.0, 420.0),
		Vector2(650.0, 560.0), Vector2(1320.0, 520.0), Vector2(1940.0, 650.0), Vector2(760.0, 820.0),
		Vector2(1220.0, 860.0), Vector2(1780.0, 980.0), Vector2(430.0, 980.0), Vector2(1450.0, 1070.0),
	],
	[
		Vector2(450.0, 420.0), Vector2(820.0, 380.0), Vector2(1120.0, 360.0), Vector2(1500.0, 400.0),
		Vector2(2200.0, 420.0), Vector2(600.0, 780.0), Vector2(900.0, 820.0), Vector2(1360.0, 680.0),
		Vector2(1900.0, 800.0), Vector2(520.0, 1020.0), Vector2(1100.0, 1080.0), Vector2(1680.0, 1060.0),
	],
	[
		Vector2(300.0, 450.0), Vector2(680.0, 450.0), Vector2(1000.0, 300.0), Vector2(1400.0, 380.0),
		Vector2(1800.0, 320.0), Vector2(2180.0, 560.0), Vector2(540.0, 600.0), Vector2(850.0, 720.0),
		Vector2(1400.0, 900.0), Vector2(1880.0, 1000.0), Vector2(760.0, 1080.0), Vector2(1500.0, 1120.0),
	],
]

func _ready() -> void:
	rng.randomize()
	_setup_audio()
	start_match()


func _setup_audio() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.stream = MUSIC_STREAM
	music_player.volume_db = -12.0
	music_player.finished.connect(music_player.play)
	add_child(music_player)
	if DisplayServer.get_name() != "headless":
		music_player.play()
	for index in 3:
		var player := AudioStreamPlayer.new()
		player.volume_db = -5.0
		add_child(player)
		sfx_players.append(player)


func _exit_tree() -> void:
	if music_player != null:
		music_player.stop()
		music_player.stream = null
	for player in sfx_players:
		player.stop()
		player.stream = null
	sfx_players.clear()


func _play_sfx(stream: AudioStream, volume_db := -5.0) -> void:
	if sfx_players.is_empty() or DisplayServer.get_name() == "headless":
		return
	var player := sfx_players[next_sfx_player]
	next_sfx_player = (next_sfx_player + 1) % sfx_players.size()
	player.stream = stream
	player.volume_db = volume_db
	player.play()


func start_match(forced_target_index := -1, forced_time := MATCH_SECONDS, forced_seed := -1) -> void:
	phase = Phase.PLAYING
	dog_pos = DOG_SPAWN
	owner_pos = OWNER_SPAWN
	time_left = forced_time
	target_index = _pick_target_index(forced_target_index)
	target_pos = target_points[target_index]
	round_seed = forced_seed if forced_seed >= 0 else rng.randi()
	round_rng.seed = round_seed
	_generate_round_map()
	target_discovered = false
	dog_target_discovered = false
	owner_target_discovered = false
	result_title = ""
	result_detail = ""
	eat_progress = 0.0
	clean_progress = 0.0
	dog_facing = Vector2.RIGHT
	owner_facing = Vector2.LEFT
	dash_direction = dog_facing
	dog_dash_cooldown_left = 0.0
	dog_dash_time_left = 0.0
	owner_net_cooldown_left = 0.0
	net_active = false
	net_lifetime_left = 0.0
	owner_catches = 0
	dog_catch_invulnerability_left = 0.0
	sniff_cooldown_left = 0.0
	sniff_feedback_left = 0.0
	sniff_heat_level = ""
	intro_time_left = INTRO_DURATION
	dog_move_direction = Vector2.ZERO
	owner_move_direction = Vector2.ZERO
	vegetation_sound_cooldown = 0.0
	_update_camera()
	queue_redraw()


func _generate_round_map() -> void:
	_generate_floor_tiles()
	_generate_obstacles()
	_generate_vegetation()


func _generate_floor_tiles() -> void:
	floor_tile_indices.clear()
	var columns := ceili(YARD_RECT.size.x / WORLD_TILE_SIZE)
	var rows := ceili(YARD_RECT.size.y / WORLD_TILE_SIZE)
	for index in columns * rows:
		var roll := round_rng.randf()
		var variant := 0
		if roll > 0.78:
			variant = 2
		elif roll > 0.55:
			variant = 1
		floor_tile_indices.append(variant)


func _generate_obstacles() -> void:
	obstacles.clear()
	obstacle_anchors.clear()
	obstacle_kinds.clear()
	obstacle_variants.clear()
	obstacle_layout_index = round_rng.randi_range(0, obstacle_layouts.size() - 1)
	for anchor: Vector2 in obstacle_layouts[obstacle_layout_index]:
		var roll := round_rng.randf()
		var kind := 0 if roll < 0.45 else (1 if roll < 0.80 else 2)
		var collision_size := Vector2(44.0, 36.0)
		if kind == 1:
			collision_size = Vector2(64.0, 48.0)
		elif kind == 2:
			collision_size = Vector2(48.0, 36.0)
		obstacle_anchors.append(anchor)
		obstacle_kinds.append(kind)
		var variant_count := TREE_SOURCES.size() if kind == 0 else (ROCK_SOURCES.size() if kind == 1 else STUMP_SOURCES.size())
		obstacle_variants.append(round_rng.randi_range(0, variant_count - 1))
		obstacles.append(Rect2(anchor - collision_size * 0.5, collision_size))


func _generate_vegetation() -> void:
	vegetation_positions.clear()
	vegetation_variants.clear()
	vegetation_phases.clear()
	vegetation_sway.clear()
	var columns := ceili(YARD_RECT.size.x / WORLD_TILE_SIZE)
	var rows := ceili(YARD_RECT.size.y / WORLD_TILE_SIZE)
	var candidates: Array[Vector2] = []
	for row in rows:
		for column in columns:
			var base_pos := YARD_RECT.position + Vector2(column + 0.5, row + 0.5) * WORLD_TILE_SIZE
			if _vegetation_position_is_clear(base_pos):
				candidates.append(base_pos)
	_shuffle_positions(candidates)
	var desired_count := mini(roundi(float(columns * rows) * VEGETATION_COVERAGE), candidates.size())
	for index in desired_count:
		var jitter := Vector2(round_rng.randf_range(-12.0, 12.0), round_rng.randf_range(-10.0, 10.0))
		vegetation_positions.append(candidates[index] + jitter)
		var is_flower := round_rng.randf() < 0.22
		var variant := GRASS_SOURCES.size() + round_rng.randi_range(0, FLOWER_SOURCES.size() - 1) if is_flower else round_rng.randi_range(0, GRASS_SOURCES.size() - 1)
		vegetation_variants.append(variant)
		vegetation_phases.append(round_rng.randf_range(0.0, TAU))
		vegetation_sway.append(0.0)


func _vegetation_position_is_clear(position: Vector2) -> bool:
	if position.distance_to(DOG_SPAWN) < 90.0 or position.distance_to(OWNER_SPAWN) < 90.0:
		return false
	for point in target_points:
		if position.distance_to(point) < 78.0:
			return false
	for obstacle in obstacles:
		if obstacle.grow(VEGETATION_OBSTACLE_CLEARANCE + VEGETATION_JITTER_MARGIN).has_point(position):
			return false
	return true


func _shuffle_positions(positions: Array[Vector2]) -> void:
	for index in range(positions.size() - 1, 0, -1):
		var swap_index := round_rng.randi_range(0, index)
		var temporary := positions[index]
		positions[index] = positions[swap_index]
		positions[swap_index] = temporary


func _process(delta: float) -> void:
	_handle_global_input()
	animation_time += delta
	if phase == Phase.PLAYING and intro_time_left > 0.0:
		intro_time_left = maxf(0.0, intro_time_left - delta)
	elif phase == Phase.PLAYING:
		_tick_playing(delta)
	_update_camera()
	queue_redraw()


func _tick_playing(delta: float) -> void:
	_tick_cooldowns(delta)
	var dog_direction := _dog_input_vector()
	var owner_direction := _owner_input_vector()
	dog_move_direction = dog_direction
	owner_move_direction = owner_direction
	if dog_direction != Vector2.ZERO:
		dog_facing = dog_direction
	if owner_direction != Vector2.ZERO:
		owner_facing = owner_direction
	_handle_combat_input(dog_direction)
	var active_dog_direction := dash_direction if dog_dash_time_left > 0.0 else dog_direction
	var active_dog_speed := DOG_SPEED * DOG_DASH_SPEED_MULTIPLIER if dog_dash_time_left > 0.0 else DOG_SPEED
	dog_pos = _move_actor(dog_pos, active_dog_direction, active_dog_speed, DOG_RADIUS, delta)
	owner_pos = _move_actor(owner_pos, owner_direction, OWNER_SPEED, OWNER_RADIUS, delta)
	_update_vegetation(delta, dog_direction != Vector2.ZERO or dog_dash_time_left > 0.0, owner_direction != Vector2.ZERO)
	_tick_net(delta)
	_update_discovery()
	_update_interactions(delta, Input.is_key_pressed(KEY_F), Input.is_key_pressed(KEY_K))
	time_left = maxf(0.0, time_left - delta)
	if time_left <= 0.0 and phase == Phase.PLAYING:
		_finish_match("owner", "Time Up", "Owner wins by running out the clock.")


func _handle_global_input() -> void:
	var restart_key_down := Input.is_key_pressed(KEY_R)
	if restart_key_down and not restart_key_was_down:
		start_match()
	restart_key_was_down = restart_key_down
	if Input.is_key_pressed(KEY_TAB):
		debug_visible = true
	if Input.is_key_pressed(KEY_F1):
		debug_visible = false
	if Input.is_key_pressed(KEY_T):
		if not debug_short_timer:
			time_left = minf(time_left, DEBUG_SHORT_TIMER)
			debug_short_timer = true
	else:
		debug_short_timer = false
	var cycle_key_down := Input.is_key_pressed(KEY_C)
	if cycle_key_down and not cycle_key_was_down:
		_cycle_target_debug()
	cycle_key_was_down = cycle_key_down


func _tick_cooldowns(delta: float) -> void:
	dog_dash_cooldown_left = maxf(0.0, dog_dash_cooldown_left - delta)
	dog_dash_time_left = maxf(0.0, dog_dash_time_left - delta)
	owner_net_cooldown_left = maxf(0.0, owner_net_cooldown_left - delta)
	dog_catch_invulnerability_left = maxf(0.0, dog_catch_invulnerability_left - delta)
	sniff_cooldown_left = maxf(0.0, sniff_cooldown_left - delta)
	sniff_feedback_left = maxf(0.0, sniff_feedback_left - delta)
	vegetation_sound_cooldown = maxf(0.0, vegetation_sound_cooldown - delta)


func _update_vegetation(delta: float, dog_moving: bool, owner_moving: bool) -> void:
	var played_sound := false
	for index in vegetation_positions.size():
		var position := vegetation_positions[index]
		var dog_touching := dog_moving and dog_pos.distance_squared_to(position) <= VEGETATION_TRIGGER_RADIUS * VEGETATION_TRIGGER_RADIUS
		var owner_touching := owner_moving and owner_pos.distance_squared_to(position) <= VEGETATION_TRIGGER_RADIUS * VEGETATION_TRIGGER_RADIUS
		if dog_touching or owner_touching:
			vegetation_sway[index] = minf(1.0, vegetation_sway[index] + delta * 9.0)
			if not played_sound and vegetation_sound_cooldown <= 0.0:
				_play_sfx(GRASS_SOUND, -14.0)
				vegetation_sound_cooldown = VEGETATION_SOUND_INTERVAL
				played_sound = true
		else:
			vegetation_sway[index] = maxf(0.0, vegetation_sway[index] - delta * 3.5)


func _handle_combat_input(dog_direction: Vector2) -> void:
	var sniff_key_down := Input.is_key_pressed(KEY_Q)
	if sniff_key_down and not sniff_key_was_down:
		_try_sniff()
	sniff_key_was_down = sniff_key_down

	var dash_key_down := Input.is_key_pressed(KEY_E)
	if dash_key_down and not dash_key_was_down:
		_try_start_dash(dog_direction)
	dash_key_was_down = dash_key_down

	var net_key_down := Input.is_key_pressed(KEY_J)
	if net_key_down and not net_key_was_down:
		_try_throw_net()
	net_key_was_down = net_key_down


func _try_sniff() -> bool:
	if phase != Phase.PLAYING or sniff_cooldown_left > 0.0:
		return false
	var distance := dog_pos.distance_to(target_pos)
	if dog_target_discovered:
		sniff_heat_level = "FOUND"
	elif distance <= SNIFF_HOT_DISTANCE:
		sniff_heat_level = "HOT"
	elif distance <= SNIFF_WARM_DISTANCE:
		sniff_heat_level = "WARM"
	elif distance <= SNIFF_FAINT_DISTANCE:
		sniff_heat_level = "FAINT"
	else:
		sniff_heat_level = "COLD"
	sniff_feedback_left = SNIFF_FEEDBACK_DURATION
	sniff_cooldown_left = SNIFF_COOLDOWN
	_play_sfx(SNIFF_SOUND, -8.0)
	return true


func _try_start_dash(direction: Vector2) -> bool:
	if phase != Phase.PLAYING or dog_dash_cooldown_left > 0.0:
		return false
	dash_direction = direction if direction != Vector2.ZERO else dog_facing
	dog_facing = dash_direction
	dog_dash_time_left = DOG_DASH_DURATION
	dog_dash_cooldown_left = DOG_DASH_COOLDOWN
	_play_sfx(DASH_SOUND, -7.0)
	return true


func _try_throw_net() -> bool:
	if phase != Phase.PLAYING or owner_net_cooldown_left > 0.0 or net_active:
		return false
	net_active = true
	net_direction = owner_facing.normalized()
	net_pos = owner_pos + net_direction * (OWNER_RADIUS + NET_RADIUS + 4.0)
	net_lifetime_left = NET_LIFETIME
	owner_net_cooldown_left = OWNER_NET_COOLDOWN
	_play_sfx(NET_SOUND, -7.0)
	return true


func _tick_net(delta: float) -> void:
	if not net_active:
		return
	var old_pos := net_pos
	var travel := net_direction * NET_SPEED * delta
	net_pos += travel
	net_lifetime_left = maxf(0.0, net_lifetime_left - delta)

	if dog_catch_invulnerability_left <= 0.0 and _segment_distance_to_point(old_pos, net_pos, dog_pos) <= NET_RADIUS + DOG_RADIUS:
		_register_catch()
		return

	if net_lifetime_left <= 0.0 or not YARD_RECT.grow(NET_RADIUS).has_point(net_pos):
		net_active = false
		return
	for obstacle in obstacles:
		if _circle_intersects_rect(net_pos, NET_RADIUS, obstacle):
			net_active = false
			return


func _segment_distance_to_point(start: Vector2, finish: Vector2, point: Vector2) -> float:
	var segment := finish - start
	if is_zero_approx(segment.length_squared()):
		return start.distance_to(point)
	var amount := clampf((point - start).dot(segment) / segment.length_squared(), 0.0, 1.0)
	return point.distance_to(start + segment * amount)


func _register_catch() -> void:
	net_active = false
	owner_catches += 1
	eat_progress = 0.0
	clean_progress = 0.0
	dog_dash_time_left = 0.0
	dog_pos = DOG_SPAWN
	dog_catch_invulnerability_left = CATCH_INVULNERABILITY
	_play_sfx(CATCH_SOUND, -4.0)
	_play_sfx(DOG_SOUND, -8.0)
	if owner_catches >= CATCHES_TO_WIN:
		_finish_match("owner", "Dog Caught 3 Times", "Owner wins by landing three nets.")


func _dog_input_vector() -> Vector2:
	return _vector_from_keys(KEY_A, KEY_D, KEY_W, KEY_S)


func _owner_input_vector() -> Vector2:
	return _vector_from_keys(KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN)


func _vector_from_keys(left_key: Key, right_key: Key, up_key: Key, down_key: Key) -> Vector2:
	var direction := Vector2.ZERO
	if Input.is_key_pressed(left_key):
		direction.x -= 1.0
	if Input.is_key_pressed(right_key):
		direction.x += 1.0
	if Input.is_key_pressed(up_key):
		direction.y -= 1.0
	if Input.is_key_pressed(down_key):
		direction.y += 1.0
	return direction.normalized() if direction.length_squared() > 0.0 else Vector2.ZERO


func _move_actor(position: Vector2, direction: Vector2, speed: float, radius: float, delta: float) -> Vector2:
	if direction == Vector2.ZERO:
		return position
	var next_pos := position
	var step := direction * speed * delta
	next_pos = _try_axis_move(next_pos, Vector2(step.x, 0.0), radius)
	next_pos = _try_axis_move(next_pos, Vector2(0.0, step.y), radius)
	return next_pos


func _try_axis_move(position: Vector2, step: Vector2, radius: float) -> Vector2:
	var candidate := position + step
	candidate.x = clampf(candidate.x, YARD_RECT.position.x + radius, YARD_RECT.end.x - radius)
	candidate.y = clampf(candidate.y, YARD_RECT.position.y + radius, YARD_RECT.end.y - radius)
	for obstacle in obstacles:
		if _circle_intersects_rect(candidate, radius, obstacle):
			return position
	return candidate


func _circle_intersects_rect(point: Vector2, radius: float, rect: Rect2) -> bool:
	var closest := Vector2(
		clampf(point.x, rect.position.x, rect.end.x),
		clampf(point.y, rect.position.y, rect.end.y)
	)
	return closest.distance_squared_to(point) <= radius * radius


func _update_camera() -> void:
	var player_span := (dog_pos - owner_pos).abs() + CAMERA_PADDING
	camera_zoom = clampf(
		minf(VIEW_SIZE.x / player_span.x, VIEW_SIZE.y / player_span.y),
		CAMERA_MIN_ZOOM,
		CAMERA_MAX_ZOOM
	)
	var desired_center := (dog_pos + owner_pos) * 0.5
	var half_view_world := VIEW_SIZE * 0.5 / camera_zoom
	camera_center = Vector2(
		_camera_axis_center(desired_center.x, YARD_RECT.position.x, YARD_RECT.end.x, half_view_world.x),
		_camera_axis_center(desired_center.y, YARD_RECT.position.y, YARD_RECT.end.y, half_view_world.y)
	)


func _camera_axis_center(desired: float, minimum: float, maximum: float, half_view: float) -> float:
	if maximum - minimum <= half_view * 2.0:
		return (minimum + maximum) * 0.5
	return clampf(desired, minimum + half_view, maximum - half_view)


func _world_to_screen(world_position: Vector2) -> Vector2:
	return (world_position - camera_center) * camera_zoom + VIEW_SIZE * 0.5


func _visible_world_rect(margin := 0.0) -> Rect2:
	var half_view := VIEW_SIZE * 0.5 / camera_zoom
	return Rect2(camera_center - half_view, half_view * 2.0).grow(margin)


func _update_discovery() -> void:
	var was_discovered := target_discovered
	if not dog_target_discovered and dog_pos.distance_to(target_pos) <= DISCOVERY_RADIUS:
		dog_target_discovered = true
	if not owner_target_discovered and owner_pos.distance_to(target_pos) <= DISCOVERY_RADIUS:
		owner_target_discovered = true
	target_discovered = dog_target_discovered or owner_target_discovered
	if target_discovered and not was_discovered:
		_play_sfx(DISCOVER_SOUND, -7.0)


func _update_interactions(delta: float, dog_holding: bool, owner_holding: bool) -> void:
	var dog_can_interact := dog_target_discovered and dog_pos.distance_to(target_pos) <= INTERACT_RADIUS and dog_holding
	var owner_can_interact := owner_target_discovered and owner_pos.distance_to(target_pos) <= INTERACT_RADIUS and owner_holding

	eat_progress = minf(HOLD_SECONDS, eat_progress + delta) if dog_can_interact else 0.0
	clean_progress = minf(HOLD_SECONDS, clean_progress + delta) if owner_can_interact else 0.0

	if eat_progress >= HOLD_SECONDS and phase == Phase.PLAYING:
		_finish_match("dog", "Dog Ate It", "Dog wins by finishing the hold-to-eat action.")
	if clean_progress >= HOLD_SECONDS and phase == Phase.PLAYING:
		_finish_match("owner", "Poop Cleaned", "Owner wins by finishing the hold-to-clean action.")


func _finish_match(winner: String, title: String, detail: String) -> void:
	phase = Phase.GAME_OVER
	result_title = title
	result_detail = detail
	if winner == "dog":
		result_title = "Dog Wins - " + result_title
	else:
		result_title = "Owner Wins - " + result_title
	_play_sfx(WIN_SOUND, -3.0)


func _pick_target_index(forced_target_index: int) -> int:
	if forced_target_index >= 0:
		return clampi(forced_target_index, 0, target_points.size() - 1)
	return rng.randi_range(0, target_points.size() - 1)


func _cycle_target_debug() -> void:
	if phase != Phase.PLAYING:
		return
	if Input.is_key_pressed(KEY_SHIFT):
		target_index = (target_index + 1) % target_points.size()
		target_pos = target_points[target_index]
		target_discovered = false
		dog_target_discovered = false
		owner_target_discovered = false
		eat_progress = 0.0
		clean_progress = 0.0


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), Color(0.08, 0.11, 0.09))
	var world_origin := VIEW_SIZE * 0.5 - camera_center * camera_zoom
	draw_set_transform(world_origin, 0.0, Vector2.ONE * camera_zoom)
	_draw_world()
	_draw_target()
	_draw_net()
	_draw_dog()
	_draw_owner()
	_draw_vegetation()
	_draw_sniff_feedback()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_ui()
	if debug_visible:
		_draw_debug()
	if phase == Phase.GAME_OVER:
		_draw_result_overlay()
	elif intro_time_left > 0.0:
		_draw_intro_overlay()


func _draw_world() -> void:
	draw_rect(YARD_RECT, Color(0.20, 0.33, 0.13))
	_draw_floor_tiles()
	_draw_obstacles()
	draw_rect(YARD_RECT, Color(0.20, 0.11, 0.05), false, 12.0)


func _draw_floor_tiles() -> void:
	var columns := ceili(YARD_RECT.size.x / WORLD_TILE_SIZE)
	var rows := ceili(YARD_RECT.size.y / WORLD_TILE_SIZE)
	var visible_rect := _visible_world_rect(WORLD_TILE_SIZE)
	for row in rows:
		for column in columns:
			var index := row * columns + column
			if index >= floor_tile_indices.size():
				continue
			var tile_pos := YARD_RECT.position + Vector2(column, row) * WORLD_TILE_SIZE
			if not visible_rect.has_point(tile_pos + Vector2.ONE * WORLD_TILE_SIZE * 0.5):
				continue
			var tile_size_clipped := Vector2(
				minf(WORLD_TILE_SIZE, YARD_RECT.end.x - tile_pos.x),
				minf(WORLD_TILE_SIZE, YARD_RECT.end.y - tile_pos.y)
			)
			var source := FLOOR_TILE_SOURCES[floor_tile_indices[index]]
			draw_texture_rect_region(FLOOR_TEXTURE, Rect2(tile_pos, tile_size_clipped), source)


func _draw_vegetation() -> void:
	var visible_rect := _visible_world_rect(72.0)
	for index in vegetation_positions.size():
		if not visible_rect.has_point(vegetation_positions[index]):
			continue
		var source: Rect2
		var is_flower := vegetation_variants[index] >= GRASS_SOURCES.size()
		if is_flower:
			source = FLOWER_SOURCES[vegetation_variants[index] - GRASS_SOURCES.size()]
		else:
			source = GRASS_SOURCES[vegetation_variants[index]]
		var active_sway := vegetation_sway[index]
		var phase := vegetation_phases[index]
		var idle_offset := sin(animation_time * 1.8 + phase) * 1.2
		var touch_wave := sin(animation_time * 18.0 + phase) * active_sway
		var offset_x := idle_offset + touch_wave * 7.0
		var height_scale := 1.0 - absf(touch_wave) * 0.12
		var draw_size := Vector2(58.0, 34.0) if is_flower else Vector2(46.0, 46.0)
		draw_size.y *= height_scale
		var destination := Rect2(
			vegetation_positions[index] + Vector2(-draw_size.x * 0.5 + offset_x, -draw_size.y),
			draw_size
		)
		draw_texture_rect_region(NATURE_TEXTURE, destination, source)


func _draw_obstacles() -> void:
	var visible_rect := _visible_world_rect(160.0)
	for index in obstacle_anchors.size():
		var anchor := obstacle_anchors[index]
		if not visible_rect.has_point(anchor):
			continue
		var kind := obstacle_kinds[index]
		var variant := obstacle_variants[index]
		var source: Rect2
		var destination: Rect2
		if kind == 0:
			source = TREE_SOURCES[variant]
			var tree_size := Vector2(96.0, 96.0)
			destination = Rect2(anchor + Vector2(-tree_size.x * 0.5, 22.0 - tree_size.y), tree_size)
		elif kind == 1:
			source = ROCK_SOURCES[variant]
			var rock_size := Vector2(72.0, 72.0) if source.size.x == 32.0 else Vector2(88.0, 88.0)
			destination = Rect2(anchor + Vector2(-rock_size.x * 0.5, 28.0 - rock_size.y), rock_size)
		else:
			source = STUMP_SOURCES[variant]
			destination = Rect2(anchor + Vector2(-32.0, -46.0), Vector2(64.0, 64.0))
		draw_texture_rect_region(NATURE_TEXTURE, destination, source)
		if debug_visible:
			draw_rect(obstacles[index], Color(1.0, 0.2, 0.2, 0.65), false, 2.0)


func _draw_target() -> void:
	if target_discovered or debug_visible:
		var alpha := 1.0 if target_discovered else 0.35
		draw_ellipse_shadow(target_pos + Vector2(0.0, 7.0), Vector2(18.0, 8.0), Color(0.05, 0.03, 0.01, 0.35 * alpha))
		var dark := Color(0.22, 0.09, 0.025, alpha)
		var mid := Color(0.38, 0.17, 0.05, alpha)
		var light := Color(0.58, 0.30, 0.10, alpha)
		draw_circle(target_pos + Vector2(-7.0, 2.0), 8.0, dark)
		draw_circle(target_pos + Vector2(4.0, 0.0), 10.0, mid)
		draw_circle(target_pos + Vector2(0.0, -8.0), 7.0, mid)
		draw_circle(target_pos + Vector2(-1.0, -11.0), 3.0, light)
	if debug_visible:
		draw_arc(target_pos, DISCOVERY_RADIUS, 0.0, TAU, 64, Color(1.0, 0.95, 0.2, 0.45), 2.0)
		draw_arc(target_pos, INTERACT_RADIUS, 0.0, TAU, 64, Color(1.0, 1.0, 1.0, 0.5), 2.0)


func _draw_dog() -> void:
	var alpha := 0.48 if dog_catch_invulnerability_left > 0.0 else 1.0
	draw_circle(dog_pos + Vector2(0.0, 9.0), 19.0, Color(1.0, 0.72, 0.20, 0.30 * alpha))
	var frame := int(animation_time * 7.0) % 2 if dog_move_direction != Vector2.ZERO or dog_dash_time_left > 0.0 else 0
	draw_texture_rect_region(
		DOG_TEXTURE,
		Rect2(dog_pos + Vector2(-24.0, -32.0), Vector2(48.0, 48.0)),
		Rect2(frame * 16.0, 0.0, 16.0, 16.0),
		Color(1.0, 1.0, 1.0, alpha)
	)
	draw_string(ThemeDB.fallback_font, dog_pos + Vector2(-32.0, 32.0), "DOG", HORIZONTAL_ALIGNMENT_CENTER, 64.0, 14.0, Color(1.0, 0.92, 0.58))


func _draw_owner() -> void:
	draw_circle(owner_pos + Vector2(0.0, 9.0), 21.0, Color(0.25, 0.65, 1.0, 0.28))
	var frame := int(animation_time * 7.0) % 4 if owner_move_direction != Vector2.ZERO else 0
	var row := _owner_sprite_row()
	draw_texture_rect_region(
		OWNER_WALK_TEXTURE,
		Rect2(owner_pos + Vector2(-24.0, -34.0), Vector2(48.0, 48.0)),
		Rect2(frame * 16.0, row * 16.0, 16.0, 16.0)
	)
	draw_string(ThemeDB.fallback_font, owner_pos + Vector2(-38.0, 32.0), "OWNER", HORIZONTAL_ALIGNMENT_CENTER, 76.0, 14.0, Color(0.65, 0.86, 1.0))


func _owner_sprite_row() -> int:
	if absf(owner_facing.x) > absf(owner_facing.y):
		return 1 if owner_facing.x < 0.0 else 2
	return 3 if owner_facing.y < 0.0 else 0


func draw_ellipse_shadow(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in 24:
		var angle := TAU * float(index) / 24.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)


func _draw_net() -> void:
	if not net_active:
		return
	draw_texture_rect(NET_TEXTURE, Rect2(net_pos + Vector2(-22.0, -17.0), Vector2(44.0, 34.0)), false)


func _draw_sniff_feedback() -> void:
	if sniff_feedback_left <= 0.0:
		return
	var color := _sniff_color(sniff_heat_level)
	var pulse := 30.0 + sin(sniff_feedback_left * 12.0) * 5.0
	draw_arc(dog_pos, pulse, 0.0, TAU, 48, color, 4.0)
	draw_arc(dog_pos, pulse + 10.0, 0.0, TAU, 48, Color(color.r, color.g, color.b, 0.35), 2.0)


func _sniff_color(level: String) -> Color:
	match level:
		"FOUND", "HOT":
			return Color(1.0, 0.24, 0.16)
		"WARM":
			return Color(1.0, 0.58, 0.12)
		"FAINT":
			return Color(0.95, 0.88, 0.35)
		_:
			return Color(0.48, 0.78, 1.0)


func _draw_ui() -> void:
	_draw_pixel_panel(Rect2(52.0, 6.0, 510.0, 52.0), Color(0.08, 0.10, 0.08, 0.88))
	_draw_pixel_panel(Rect2(718.0, 6.0, 510.0, 52.0), Color(0.08, 0.10, 0.08, 0.88))
	_draw_pixel_panel(Rect2(574.0, 4.0, 132.0, 58.0), Color(0.10, 0.08, 0.05, 0.95))
	_draw_pixel_panel(Rect2(56.0, 582.0, 420.0, 116.0), Color(0.08, 0.10, 0.08, 0.88))
	_draw_pixel_panel(Rect2(804.0, 582.0, 420.0, 116.0), Color(0.08, 0.10, 0.08, 0.88))
	_draw_pixel_panel(Rect2(500.0, 672.0, 280.0, 42.0), Color(0.08, 0.10, 0.08, 0.88))
	var minutes := int(time_left) / 60
	var seconds := int(time_left) % 60
	var time_text := "%02d:%02d" % [minutes, seconds]
	draw_string(ThemeDB.fallback_font, Vector2(584.0, 42.0), time_text, HORIZONTAL_ALIGNMENT_CENTER, 112.0, 36.0, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(78.0, 36.0), "Dog: WASD move, Q sniff, E dash, F eat", HORIZONTAL_ALIGNMENT_LEFT, 520.0, 20.0, Color(1.0, 0.93, 0.68))
	draw_string(ThemeDB.fallback_font, Vector2(790.0, 36.0), "Owner: Arrows move, J net, K hold clean", HORIZONTAL_ALIGNMENT_LEFT, 500.0, 20.0, Color(0.70, 0.86, 1.0))
	var state_text := _discovery_state_text()
	draw_string(ThemeDB.fallback_font, Vector2(528.0, 704.0), state_text, HORIZONTAL_ALIGNMENT_CENTER, 224.0, 18.0, Color.WHITE)
	_draw_progress_bar(Vector2(82.0, 664.0), eat_progress / HOLD_SECONDS, Color(1.0, 0.76, 0.25), "Eat")
	_draw_progress_bar(Vector2(1036.0, 664.0), clean_progress / HOLD_SECONDS, Color(0.38, 0.72, 1.0), "Clean")
	var dash_text := "Dash READY" if dog_dash_cooldown_left <= 0.0 else "Dash %.1fs" % dog_dash_cooldown_left
	var net_text := "Net READY" if owner_net_cooldown_left <= 0.0 else "Net %.1fs" % owner_net_cooldown_left
	draw_string(ThemeDB.fallback_font, Vector2(82.0, 630.0), dash_text, HORIZONTAL_ALIGNMENT_LEFT, 190.0, 17.0, Color(1.0, 0.86, 0.48))
	draw_string(ThemeDB.fallback_font, Vector2(1010.0, 630.0), net_text, HORIZONTAL_ALIGNMENT_RIGHT, 190.0, 17.0, Color(0.72, 0.90, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(1030.0, 604.0), "Catches %d/%d" % [owner_catches, CATCHES_TO_WIN], HORIZONTAL_ALIGNMENT_RIGHT, 170.0, 18.0, Color.WHITE)
	var sniff_ready_text := "Sniff READY" if sniff_cooldown_left <= 0.0 else "Sniff %.1fs" % sniff_cooldown_left
	draw_string(ThemeDB.fallback_font, Vector2(82.0, 606.0), sniff_ready_text, HORIZONTAL_ALIGNMENT_LEFT, 190.0, 17.0, Color(0.76, 0.93, 1.0))
	if sniff_feedback_left > 0.0:
		draw_string(ThemeDB.fallback_font, Vector2(272.0, 630.0), "SCENT: " + sniff_heat_level, HORIZONTAL_ALIGNMENT_LEFT, 190.0, 22.0, _sniff_color(sniff_heat_level))


func _draw_pixel_panel(rect: Rect2, fill: Color) -> void:
	draw_rect(rect, fill)
	var corner := 8.0
	var source_corner := 4.0
	var source_middle := 8.0
	var x0 := rect.position.x
	var x1 := rect.end.x - corner
	var y0 := rect.position.y
	var y1 := rect.end.y - corner
	var middle_width := maxf(0.0, rect.size.x - corner * 2.0)
	var middle_height := maxf(0.0, rect.size.y - corner * 2.0)
	var tint := Color(1.0, 0.78, 0.40, 0.92)
	_draw_panel_piece(Rect2(x0, y0, corner, corner), Rect2(0.0, 0.0, source_corner, source_corner), tint)
	_draw_panel_piece(Rect2(x1, y0, corner, corner), Rect2(12.0, 0.0, source_corner, source_corner), tint)
	_draw_panel_piece(Rect2(x0, y1, corner, corner), Rect2(0.0, 12.0, source_corner, source_corner), tint)
	_draw_panel_piece(Rect2(x1, y1, corner, corner), Rect2(12.0, 12.0, source_corner, source_corner), tint)
	_draw_panel_piece(Rect2(x0 + corner, y0, middle_width, corner), Rect2(4.0, 0.0, source_middle, source_corner), tint)
	_draw_panel_piece(Rect2(x0 + corner, y1, middle_width, corner), Rect2(4.0, 12.0, source_middle, source_corner), tint)
	_draw_panel_piece(Rect2(x0, y0 + corner, corner, middle_height), Rect2(0.0, 4.0, source_corner, source_middle), tint)
	_draw_panel_piece(Rect2(x1, y0 + corner, corner, middle_height), Rect2(12.0, 4.0, source_corner, source_middle), tint)


func _draw_panel_piece(destination: Rect2, source: Rect2, tint: Color) -> void:
	if destination.size.x > 0.0 and destination.size.y > 0.0:
		draw_texture_rect_region(UI_PANEL_TEXTURE, destination, source, tint)


func _discovery_state_text() -> String:
	if dog_target_discovered and owner_target_discovered:
		return "Both found target"
	if dog_target_discovered:
		return "Dog found target"
	if owner_target_discovered:
		return "Owner found target"
	return "Target hidden"


func _draw_progress_bar(pos: Vector2, value: float, color: Color, label: String) -> void:
	var size := Vector2(162.0, 18.0)
	draw_rect(Rect2(pos, size), Color(0.06, 0.06, 0.06, 0.80))
	draw_rect(Rect2(pos, Vector2(size.x * clampf(value, 0.0, 1.0), size.y)), color)
	draw_rect(Rect2(pos, size), Color.WHITE, false, 2.0)
	draw_string(ThemeDB.fallback_font, pos + Vector2(0.0, -8.0), label, HORIZONTAL_ALIGNMENT_LEFT, size.x, 15.0, Color.WHITE)


func _draw_debug() -> void:
	var lines: Array[String] = [
		"DEBUG Tab:on F1:off R:restart T:20s Shift+C:cycle target",
		"target_index=%d dog_found=%s owner_found=%s time=%.1f" % [target_index, str(dog_target_discovered), str(owner_target_discovered), time_left],
		"dog=(%.0f, %.0f) owner=(%.0f, %.0f) target=(%.0f, %.0f)" % [dog_pos.x, dog_pos.y, owner_pos.x, owner_pos.y, target_pos.x, target_pos.y],
		"dash=%.1f net=%.1f active=%s catches=%d invulnerable=%.1f" % [dog_dash_cooldown_left, owner_net_cooldown_left, str(net_active), owner_catches, dog_catch_invulnerability_left],
		"sniff=%.1f feedback=%.1f heat=%s distance=%.0f" % [sniff_cooldown_left, sniff_feedback_left, sniff_heat_level, dog_pos.distance_to(target_pos)],
		"camera=(%.0f, %.0f) zoom=%.2f" % [camera_center.x, camera_center.y, camera_zoom],
		"seed=%d layout=%d vegetation=%d coverage=%.2f" % [round_seed, obstacle_layout_index, vegetation_positions.size(), float(vegetation_positions.size()) / (ceili(YARD_RECT.size.x / WORLD_TILE_SIZE) * ceili(YARD_RECT.size.y / WORLD_TILE_SIZE))],
		"fps=%d visible_world=(%.0f x %.0f)" % [Engine.get_frames_per_second(), _visible_world_rect().size.x, _visible_world_rect().size.y],
	]
	var y := 96.0
	for line in lines:
		draw_string(ThemeDB.fallback_font, Vector2(78.0, y), line, HORIZONTAL_ALIGNMENT_LEFT, 820.0, 15.0, Color(0.95, 1.0, 0.65))
		y += 18.0


func _draw_result_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), Color(0.0, 0.0, 0.0, 0.58))
	_draw_pixel_panel(Rect2(Vector2(340.0, 230.0), Vector2(600.0, 210.0)), Color(0.09, 0.10, 0.12, 0.96))
	draw_string(ThemeDB.fallback_font, Vector2(384.0, 300.0), result_title, HORIZONTAL_ALIGNMENT_CENTER, 512.0, 34.0, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(384.0, 350.0), result_detail, HORIZONTAL_ALIGNMENT_CENTER, 512.0, 20.0, Color(0.82, 0.87, 0.92))
	draw_string(ThemeDB.fallback_font, Vector2(384.0, 395.0), "Press R for a quick rematch", HORIZONTAL_ALIGNMENT_CENTER, 512.0, 20.0, Color(1.0, 0.93, 0.68))


func _draw_intro_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), Color(0.02, 0.04, 0.03, 0.52))
	_draw_pixel_panel(Rect2(250.0, 180.0, 780.0, 330.0), Color(0.08, 0.10, 0.09, 0.96))
	draw_string(ThemeDB.fallback_font, Vector2(320.0, 238.0), "DOG vs OWNER", HORIZONTAL_ALIGNMENT_CENTER, 640.0, 42.0, Color(1.0, 0.86, 0.42))
	draw_string(ThemeDB.fallback_font, Vector2(320.0, 286.0), "Dog: find and hold F to eat", HORIZONTAL_ALIGNMENT_CENTER, 640.0, 24.0, Color(1.0, 0.91, 0.62))
	draw_string(ThemeDB.fallback_font, Vector2(320.0, 320.0), "Owner: clean it, run out the clock, or catch the dog 3 times", HORIZONTAL_ALIGNMENT_CENTER, 640.0, 21.0, Color(0.68, 0.86, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(320.0, 366.0), "WASD + Q/E/F                         Arrows + J/K", HORIZONTAL_ALIGNMENT_CENTER, 640.0, 20.0, Color.WHITE)
	var countdown := maxi(1, ceili(intro_time_left))
	draw_string(ThemeDB.fallback_font, Vector2(320.0, 447.0), str(countdown), HORIZONTAL_ALIGNMENT_CENTER, 640.0, 56.0, Color.WHITE)


func test_force_positions(new_dog_pos: Vector2, new_owner_pos: Vector2) -> void:
	dog_pos = new_dog_pos
	owner_pos = new_owner_pos
	_update_discovery()


func test_tick_interaction(delta: float, dog_holding: bool, owner_holding: bool) -> void:
	_update_interactions(delta, dog_holding, owner_holding)


func test_tick_timer(delta: float) -> void:
	if phase == Phase.PLAYING:
		time_left = maxf(0.0, time_left - delta)
		if time_left <= 0.0:
			_finish_match("owner", "Time Up", "Owner wins by running out the clock.")


func test_start_dash(direction: Vector2) -> bool:
	return _try_start_dash(direction)


func test_throw_net(direction: Vector2) -> bool:
	owner_facing = direction.normalized()
	return _try_throw_net()


func test_tick_combat(delta: float) -> void:
	_tick_cooldowns(delta)
	_tick_net(delta)


func test_register_catch() -> void:
	_register_catch()


func test_sniff() -> bool:
	return _try_sniff()


func test_update_camera() -> void:
	_update_camera()


func test_world_to_screen(world_position: Vector2) -> Vector2:
	return _world_to_screen(world_position)


func test_tick_vegetation(delta: float, dog_moving: bool, owner_moving: bool) -> void:
	_update_vegetation(delta, dog_moving, owner_moving)


func test_visible_world_rect(margin := 0.0) -> Rect2:
	return _visible_world_rect(margin)
