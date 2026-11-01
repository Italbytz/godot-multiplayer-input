extends SceneTree

const PlayerInputSlot = preload("res://addons/multiplayer_input/player_slot.gd")
const MultiplayerInputManager = preload("res://addons/multiplayer_input/multiplayer_input_manager.gd")

func _init() -> void:
	print("\n--- Running Headless Unit Tests for Italbytz/godot-multiplayer-input ---")
	var success = true
	success = success and _test_player_slot_defaults()
	success = success and _test_manager_initialization()
	success = success and _test_auto_assignment_without_joypads()
	success = success and _test_manual_joypad_assignment()
	success = success and _test_action_aliases()
	success = success and _test_move_vector_normalization()
	
	if success:
		print("=== ALL 6 TEST SUITES FOR MULTIPLAYER INPUT ADDON PASSED! ===")
		quit(0)
	else:
		printerr("=== TESTS FAILED ===")
		quit(1)

func _test_player_slot_defaults() -> bool:
	print("[1/6] Testing PlayerInputSlot initialization...")
	var slot = PlayerInputSlot.new(0, PlayerInputSlot.DeviceType.KEYBOARD_WASD, -1)
	assert(slot.slot_index == 0, "Slot index mismatch")
	assert(slot.device_type == PlayerInputSlot.DeviceType.KEYBOARD_WASD, "Device type mismatch")
	assert(slot.joypad_id == -1, "Joypad ID should be -1 for keyboard")
	assert(slot.deadzone == 0.2, "Default deadzone should be 0.2")
	print("  -> PlayerInputSlot OK.")
	return true

func _test_manager_initialization() -> bool:
	print("[2/6] Testing MultiplayerInputManager slot allocation...")
	var mgr = MultiplayerInputManager.new()
	assert(mgr.slots.size() == MultiplayerInputManager.MAX_SLOTS, "Must have exactly 4 slots")
	assert(mgr.get_slot(0) != null, "Slot 0 must exist")
	assert(mgr.get_slot(3) != null, "Slot 3 must exist")
	assert(mgr.get_slot(4) == null, "Slot 4 must return null (out of bounds)")
	mgr.queue_free()
	print("  -> MultiplayerInputManager OK.")
	return true

func _test_auto_assignment_without_joypads() -> bool:
	print("[3/6] Testing Auto-Assignment Fallbacks (Zero Joypads)...")
	var mgr = MultiplayerInputManager.new()
	mgr.auto_assign_slots([]) # Simuliere 0 Joypads
	
	var s0 = mgr.get_slot(0)
	var s1 = mgr.get_slot(1)
	var s2 = mgr.get_slot(2)
	var s3 = mgr.get_slot(3)
	
	assert(s0.device_type == PlayerInputSlot.DeviceType.KEYBOARD_WASD, "Slot 0 should default to WASD")
	assert(s1.device_type == PlayerInputSlot.DeviceType.KEYBOARD_ARROWS, "Slot 1 should default to ARROWS")
	assert(s2.device_type == PlayerInputSlot.DeviceType.KEYBOARD_IJKL, "Slot 2 should default to IJKL")
	assert(s3.device_type == PlayerInputSlot.DeviceType.NONE, "Slot 3 should default to NONE")
	
	# Test mit 2 simulierten Joypads [0, 1]
	mgr.auto_assign_slots([0, 1])
	assert(s0.device_type == PlayerInputSlot.DeviceType.JOYPAD and s0.joypad_id == 0, "Slot 0 should get Joypad 0")
	assert(s1.device_type == PlayerInputSlot.DeviceType.JOYPAD and s1.joypad_id == 1, "Slot 1 should get Joypad 1")
	assert(s2.device_type == PlayerInputSlot.DeviceType.KEYBOARD_WASD, "Slot 2 should get Keyboard WASD fallback")
	assert(s3.device_type == PlayerInputSlot.DeviceType.KEYBOARD_ARROWS, "Slot 3 should get Keyboard ARROWS fallback")
	
	mgr.queue_free()
	print("  -> Auto-Assignment Fallbacks OK.")
	return true

func _test_manual_joypad_assignment() -> bool:
	print("[4/6] Testing Manual Device Assignment...")
	var mgr = MultiplayerInputManager.new()
	
	var res = {"signal_received": false}
	mgr.slot_assigned.connect(func(slot, dev, joy):
		if slot == 1 and dev == PlayerInputSlot.DeviceType.JOYPAD and joy == 3:
			res["signal_received"] = true
	)
	
	mgr.assign_joypad(1, 3)
	var s1 = mgr.get_slot(1)
	assert(s1.device_type == PlayerInputSlot.DeviceType.JOYPAD, "Slot 1 must be JOYPAD")
	assert(s1.joypad_id == 3, "Slot 1 joypad ID must be 3")
	assert(res["signal_received"], "slot_assigned signal must have been emitted")
	
	# Reassign to keyboard
	mgr.assign_keyboard(1, PlayerInputSlot.DeviceType.KEYBOARD_WASD)
	assert(s1.device_type == PlayerInputSlot.DeviceType.KEYBOARD_WASD, "Slot 1 must reassign to WASD")
	assert(s1.joypad_id == -1, "Joypad ID must be reset to -1")
	
	mgr.queue_free()
	print("  -> Manual Device Assignment OK.")
	return true

func _test_action_aliases() -> bool:
	print("[5/6] Testing Standard Action Aliases...")
	var slot = PlayerInputSlot.new(0, PlayerInputSlot.DeviceType.KEYBOARD_WASD, -1)
	
	# Verify aliases do not crash and return boolean
	var actions = ["primary", "jump", "fire", "gas", "secondary", "nitro", "bomb", "brake", "start"]
	for act in actions:
		var pressed = slot.is_action_pressed(act)
		assert(typeof(pressed) == TYPE_BOOL, "Action query must return boolean")
		
	print("  -> Action Aliases OK.")
	return true

func _test_move_vector_normalization() -> bool:
	print("[6/6] Testing Move Vector Calculation...")
	var mgr = MultiplayerInputManager.new()
	mgr.auto_assign_slots()
	
	# When no keys are pressed, move vector should be ZERO
	var v0 = mgr.get_move_vector(0)
	assert(v0 == Vector2.ZERO, "Move vector should be ZERO in neutral")
	
	# Test out of bounds player
	var v_invalid = mgr.get_move_vector(99)
	assert(v_invalid == Vector2.ZERO, "Invalid player must return ZERO vector")
	
	mgr.queue_free()
	print("  -> Move Vector Calculation OK.")
	return true
