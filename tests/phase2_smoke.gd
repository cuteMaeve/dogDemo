extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var game := MainScene.instantiate()
	root.add_child(game)
	await process_frame

	_check_dash(game)
	_check_net_cooldown(game)
	_check_net_hit(game)
	_check_three_catches_win(game)
	_check_catch_interrupts_interaction(game)
	game.queue_free()
	await process_frame

	if failures.is_empty():
		print("Phase 2 smoke tests passed.")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _check_dash(game: Node) -> void:
	game.start_match(0, 120.0)
	_assert(game.test_start_dash(Vector2.RIGHT), "ready dash should start")
	_assert(game.dog_dash_time_left > 0.0, "dash should have an active duration")
	_assert(game.dog_dash_cooldown_left > 0.0, "dash should start its cooldown")
	_assert(not game.test_start_dash(Vector2.LEFT), "dash should not restart during cooldown")
	game.test_tick_combat(game.DOG_DASH_COOLDOWN + 0.01)
	_assert(game.test_start_dash(Vector2.LEFT), "dash should become ready after cooldown")


func _check_net_cooldown(game: Node) -> void:
	game.start_match(0, 120.0)
	_assert(game.test_throw_net(Vector2.LEFT), "ready net should be thrown")
	_assert(game.net_active, "thrown net should be active")
	_assert(not game.test_throw_net(Vector2.LEFT), "active net should block another throw")
	game.net_active = false
	_assert(not game.test_throw_net(Vector2.LEFT), "net cooldown should block another throw")
	game.test_tick_combat(game.OWNER_NET_COOLDOWN + 0.01)
	_assert(game.test_throw_net(Vector2.LEFT), "net should become ready after cooldown")


func _check_net_hit(game: Node) -> void:
	game.start_match(0, 120.0)
	game.test_force_positions(Vector2(900.0, 620.0), Vector2(1130.0, 620.0))
	game.test_throw_net(Vector2.LEFT)
	game.test_tick_combat(0.5)
	_assert(game.owner_catches == 1, "net crossing dog should add one catch")
	_assert(game.dog_pos == game.DOG_SPAWN, "caught dog should return to spawn")
	_assert(not game.net_active, "net should disappear on catch")


func _check_three_catches_win(game: Node) -> void:
	game.start_match(0, 120.0)
	game.test_register_catch()
	game.test_register_catch()
	_assert(game.phase == game.Phase.PLAYING, "two catches should not end the match")
	game.test_register_catch()
	_assert(game.phase == game.Phase.GAME_OVER, "three catches should end the match")
	_assert(game.result_title.begins_with("Owner Wins"), "three catches should produce owner win")


func _check_catch_interrupts_interaction(game: Node) -> void:
	game.start_match(0, 120.0)
	game.test_force_positions(game.target_pos, Vector2(1130.0, 620.0))
	game.test_tick_interaction(0.8, true, false)
	_assert(game.eat_progress > 0.0, "eat should have progress before catch")
	game.test_register_catch()
	_assert(is_zero_approx(game.eat_progress), "catch should reset eat progress")


func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
