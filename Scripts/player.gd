extends CharacterBody2D

class_name PlayerCharacter

@onready var ui = $Camera2D/Container/UI

# var texturePath: String = ""
# var sprite: Node2D = null
var animation_player: AnimationPlayer = null
var sprite_texture: AnimatedSprite2D = null
var walking_colision: CollisionShape2D = null
var hit_box : CollisionShape2D = null
var hit_box_node : Area2D = null
var attack_area: Area2D = null
var delta_time: float = 0.0
const SECONDS_COUNT: int = 60

enum state {
	IDLE,
	WALK,
	RUN,
	ATTACK,
	DEATH
}

var current_state: state = state.IDLE

# var speed: float = 2.5
# var stats: Dictionary = {}
#Stats:
var level = 0
var exp = 0

var base_stats: Dictionary = {
	"Constitution": 0,
	"Strength": 0,
	"Dexterity": 0,
	"Intelligence": 0,
	"Wisdom": 0,
	"Charisma": 0
}

# enum Stats {
# 	Constitution,
# 	Strength,
# 	Dexterity,
# 	Intelligence,
# 	Wisdom,
# 	Charisma,
# 	Health,
# 	Mana,
# 	Mana_Regen,
# 	Stamina,
# 	Defense,
# 	Damage,
# 	Weight_Capacity,
# 	Base_Speed,
# 	Weight_Ignore,
# 	Speed,
# 	Poison_Resist,
# 	Magic_Resist,
# 	Fire_Resist,
# 	Cold_Resist,
# 	Lightning_Resist,
# 	Current_Weight,
# 	Replacement_Damage
# }

const Stats = Structures.Stats

const PROVIDER = {
	Stats.Strength: [Stats.Damage, Stats.Weight_Capacity, Stats.Weight_Ignore, Stats.Speed],
	Stats.Constitution: [Stats.Health, Stats.Stamina, Stats.Poison_Resist, Stats.Fire_Resist, Stats.Cold_Resist, Stats.Lightning_Resist, Stats.Defense],
	Stats.Dexterity: [Stats.Defense, Stats.Base_Speed, Stats.Speed],
	Stats.Intelligence: [Stats.Mana, Stats.Mana_Regen],
	Stats.Wisdom: [Stats.Magic_Resist],
	Stats.Weight_Capacity: [Stats.Speed],
	Stats.Base_Speed: [Stats.Speed],
	Stats.Weight_Ignore: [Stats.Speed, Stats.Weight_Capacity],
	Stats.Current_Weight: [Stats.Speed]
}
const DEPENDENCIES = {
	Stats.Health: [Stats.Constitution],
	Stats.Mana: [Stats.Intelligence],
	Stats.Mana_Regen: [Stats.Intelligence],
	Stats.Stamina: [Stats.Constitution],
	Stats.Defense: [Stats.Dexterity, Stats.Constitution],
	Stats.Damage: [Stats.Strength], #Depend of weapon type
	Stats.Weight_Capacity: [Stats.Strength, Stats.Weight_Ignore],
	Stats.Weight_Ignore: [Stats.Strength],
	Stats.Base_Speed: [Stats.Dexterity],
	Stats.Speed: [Stats.Base_Speed, Stats.Weight_Capacity, Stats.Weight_Ignore],
	Stats.Poison_Resist: [Stats.Constitution],
	Stats.Magic_Resist: [Stats.Wisdom],
	Stats.Fire_Resist: [Stats.Constitution],
	Stats.Cold_Resist: [Stats.Constitution],
	Stats.Lightning_Resist: [Stats.Constitution]
}

var modified_stats: Dictionary = {} # Stats modified by items or buffs {enum Stats: [constant, multiplier]}, if 0, stat is removed from the dictionary

var dirtied_stats: Array = [] # List of stats modified that need recalculation

var constitution = 0
var strength = 0
var dexterity = 0
var intelligence = 0
var wisdom = 0
var charisma = 0

var health: int = 0
var current_health: int = 0
var mana: int = 0
var current_mana: int = 0
var mana_regen: float = 0.0
var stamina: int = 40
var current_stamina: int = 40
var defense: int = 0
# var damage: int = 0
var min_damage: int = 0
var max_damage: int = 0
var weight_capacity: int = 0
var soft_capacity: float = 0.0
var hard_capacity: float = 0.0
var base_speed: float = 0.0
var weight_ignore: float = 0.0
var speed: float = 0.0
var resistences: Dictionary = {
	"Poison_Resist": 0.0,
	"Magic_Resist": 0.0,
	"Fire_Resist": 0.0,
	"Cold_Resist": 0.0,
	"Lightning_Resist": 0.0
}

var inventory: Array = []
var equippedItems: Dictionary = {}

func _ready() -> void:
	animation_player = get_node_or_null("Animations") as AnimationPlayer
	animation_player.play("Idle")
	sprite_texture = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	walking_colision = get_node_or_null("Walking Collision") as CollisionShape2D
	hit_box_node = get_node_or_null("Area2D")
	hit_box = hit_box_node.get_node_or_null("Hit Box") as CollisionShape2D
	attack_area = get_node_or_null("AttackBoxes") as Area2D
	ui.player_character = self
	# attack_area = %AttackBoxes as Area2D
	print("Attack Area: ", attack_area)
	attack_area.character_owner = "Player"

func set_player(player: Structures.Player):
	level = player.stats["Level"]
	exp = player.stats["Exp"]
	for stat_name in base_stats.keys():
		base_stats[stat_name] = player.stats[stat_name]
	# constitution = player.stats["Constitution"]
	# strength = player.stats["Strength"]
	# dexterity = player.stats["Dexterity"]
	# intelligence = player.stats["Intelligence"]
	# wisdom = player.stats["Wisdom"]
	# charisma = player.stats["Charisma"]
	for stat in Stats.values():
		dirtify_stat(stat)
		# dirtied_stats.append(stat)
		# print("Marking stat dirty: ", stat)
		# if stat in dirtied_stats:
		# 	print("Stat ", stat, " is dirty.")
	for stat in DEPENDENCIES:
		check_if_dirty(stat)
	# health = constitution * 10 + constitution * 5 * level
	# current_health = health
	# mana = intelligence * 10 + intelligence * 5 * level
	# current_mana = mana
	# mana_regen = intelligence * 0.1 + intelligence * 0.05 * level
	# stamina = 40 + constitution * level
	# current_stamina = stamina
	# defense = int(dexterity * 0.5 * level + constitution * 0.2 * level)
	# damage = strength * 1.5 + strength * 0.5 * level
	# weight_ignore = strength * 1.5
	# weight_capacity = strength * 15
	# soft_capacity = strength * 7.5 - weight_ignore
	# hard_capacity = weight_capacity - weight_ignore
	# base_speed = 1 + dexterity * 0.1 + dexterity * 0.01 * level
	# speed = base_speed
	# resistences["Poison_Resist"] = constitution / (constitution + 50)
	# resistences["Magic_Resist"] = wisdom / (wisdom + 50)
	# resistences["Fire_Resist"] = constitution / (constitution + 50)
	# resistences["Cold_Resist"] = constitution / (constitution + 50)
	# resistences["Lightning_Resist"] = constitution / (constitution + 50)

	MapDetails.set_player_base_stats(base_stats)
	inventory = player.inventory
	equippedItems = player.equippedItems
	set_item_modifiers()
	set_process(true)


func _process(delta: float):
	check_if_dirty(Stats.Speed)
	# print("Current Speed: ", speed)
	if current_state == state.DEATH:
		return
	if current_state == state.ATTACK:
		if not animation_player.is_playing():
			current_state = state.IDLE
			animation_player.play("Idle")
		return
	if current_state == state.IDLE or current_state == state.WALK or current_state == state.RUN:
		var movement = speed
		var movement_change = Vector2.ZERO
		if Input.is_key_pressed(KEY_SHIFT):
			movement *= 2
		if Input.is_key_pressed(KEY_W):
			# code for moving the player up
			movement_change.y -= 1
		if Input.is_key_pressed(KEY_S):
			# code for moving the player down
			movement_change.y += 1
		if Input.is_key_pressed(KEY_A):
			# code for moving the player left
			movement_change.x -= 1
		if Input.is_key_pressed(KEY_D):
			# code for moving the player right
			movement_change.x += 1
		
		# Use move_and_collide to handle collision detection
		if movement_change != Vector2.ZERO:
			movement_change = movement_change.normalized() * movement * delta * SECONDS_COUNT
			var collision = move_and_collide(movement_change) as KinematicCollision2D
			if collision:
				if movement_change.x != 0:
					move_and_collide(Vector2(collision.get_remainder().x, 0))
				if movement_change.y != 0:
					move_and_collide(Vector2(0, collision.get_remainder().y))
			if Input.is_key_pressed(KEY_SHIFT) and animation_player.current_animation != "Run":
				animation_player.play("Run")
				current_state = state.RUN
			elif not Input.is_key_pressed(KEY_SHIFT) and animation_player.current_animation != "Walk":
				animation_player.play("Walk")
				current_state = state.WALK
		
		if movement_change.x != 0 or movement_change.y != 0:
			if sprite_texture and movement_change.x > 0 and sprite_texture.flip_h:
				sprite_texture.flip_h = false
				walking_colision.position.x *= -1
				hit_box_node.position.x *= -1
			elif sprite_texture and movement_change.x < 0 and not sprite_texture.flip_h:
				sprite_texture.flip_h = true
				walking_colision.position.x *= -1
				hit_box_node.position.x *= -1
		else:
			if animation_player.current_animation != "Idle":
				animation_player.play("Idle")
				current_state = state.IDLE
		if Input.is_key_pressed(KEY_SPACE):
			current_state = state.ATTACK
			check_if_dirty(Stats.Damage)
			animation_player.play("Attack")
		
	# Camera zoom control
	if Input.is_key_pressed(KEY_UP):
		var camera = get_node_or_null("Camera2D") as Camera2D
		var zoom_scalescale = camera.zoom.x * 0.02
		if camera and camera.zoom.x < 5.5:
			camera.zoom += Vector2(zoom_scalescale, zoom_scalescale)
	if Input.is_key_pressed(KEY_DOWN):
		var camera = get_node_or_null("Camera2D") as Camera2D
		var zoom_scale = camera.zoom.x * 0.02
		if camera and camera.zoom.x > 2.0:
			camera.zoom -= Vector2(zoom_scale, zoom_scale)

func set_item_modifiers():
	pass

# item.modifiers = {enumStatName: [constant, multiplier], ...}

func apply_item_buff(item):
	for stat in item.modifiers.keys():
		if stat == Stats.Replacement_Damage:
			# modified_stats[Stats.Replacement_Damage] = item.modifiers[Stats.Replacement_Damage]
			modified_stats[Stats.Replacement_Damage] = [item.modifiers[Stats.Replacement_Damage][0], item.modifiers[Stats.Replacement_Damage][1], item.modifiers[Stats.Replacement_Damage][2], item.modifiers[Stats.Replacement_Damage][3]]
			# dirtify_stat(Stats.Replacement_Damage)
			dirtify_stat(Stats.Damage) # ensure damage recalculates after replacement change
			continue
		if stat == Stats.Current_Weight: continue
		var stat_name = stat
		var const_mod = item.modifiers[stat][0]
		var mult_mod = 1 + item.modifiers[stat][1]
		modify_stat(stat_name, const_mod, mult_mod)

func remove_item_buff(item):
	for stat in item.modifiers.keys():
		if stat == Stats.Replacement_Damage:
			modified_stats.erase(Stats.Replacement_Damage)
			dirtify_stat(Stats.Damage) # ensure damage recalculates after removal
			continue
		if stat == Stats.Current_Weight: continue
		var stat_name = stat
		var const_mod = -item.modifiers[stat][0]
		var mult_mod = 1 / (1 + item.modifiers[stat][1])
		modify_stat(stat_name, const_mod, mult_mod)

func add_weight(weight: float):
	modify_stat(Stats.Current_Weight, weight, 1.0)
	dirtify_stat(Stats.Speed)
	# dirtify_stat(Stats.Current_Weight)
func remove_weight(weight: float):
	modify_stat(Stats.Current_Weight, -weight, 1.0)
	dirtify_stat(Stats.Speed)

# Marks a stat as dirty so it will be recalculated
func dirtify_stat(stat_name: Stats):
	if stat_name not in dirtied_stats:
		dirtied_stats.append(stat_name)
	if stat_name in PROVIDER:
		for stat in PROVIDER[stat_name]:
			if stat not in dirtied_stats:
				dirtied_stats.append(stat)
		# print("Stat ", stat_name, " marked dirty. Type: ", typeof(stat_name))

func modify_stat(stat_name: Stats, constant, multiplier: float):
	if modified_stats.has(stat_name):
		var current_data = modified_stats[stat_name]
		constant += current_data[0]
		multiplier *= current_data[1]
	modified_stats[stat_name] = [constant, multiplier]
	if modified_stats[stat_name][0] == 0 and modified_stats[stat_name][1] == 1.0:
		modified_stats.erase(stat_name)
	dirtify_stat(stat_name)
	# Not every stat provides derived stats (e.g., Current_Weight or Replacement_Damage)
	if PROVIDER.has(stat_name):
		for dependent_stat in PROVIDER[stat_name]:
			dirtify_stat(dependent_stat)

func check_if_dirty(stat_name: Stats):
	if stat_name not in dirtied_stats:
		# for i in dirtied_stats:
			# print("Dirty stat: ", i, " Type: ", typeof(i), " Looking for: ", stat_name, " Type: ", typeof(stat_name))
		return
	# print("Recalculating stat: ", stat_name)
	# Recalculate the stat here
	match stat_name:
		Stats.Constitution:
			recalc_constitution()
		Stats.Strength:
			recalc_strength()
		Stats.Dexterity:
			recalc_dexterity()
		Stats.Intelligence:
			recalc_intelligence()
		Stats.Wisdom:
			recalc_wisdom()
		Stats.Charisma:
			recalc_charisma()
		# Add additional stat recalculations as needed
		Stats.Health:
			recalc_health()
		Stats.Mana:
			recalc_mana()
		Stats.Mana_Regen:
			recalc_mana_regen()
		Stats.Stamina:
			recalc_stamina()
		Stats.Defense:
			recalc_defense()
		Stats.Damage:
			recalc_damage()
		Stats.Weight_Capacity:
			recalc_weight_capacity()
		Stats.Base_Speed:
			recalc_base_speed()
		Stats.Weight_Ignore:
			recalc_weight_ignore()
		Stats.Speed:
			recalc_speed()
		Stats.Poison_Resist:
			recalc_poison_resist()
		Stats.Magic_Resist:
			recalc_magic_resist()
		Stats.Fire_Resist:
			recalc_fire_resist()
		Stats.Cold_Resist:
			recalc_cold_resist()
		Stats.Lightning_Resist:
			recalc_lightning_resist()

func recalc_constitution():
	constitution = base_stats["Constitution"]
	if Stats.Constitution in modified_stats.keys():
		var mod_data = modified_stats[Stats.Constitution]
		constitution = int(constitution * mod_data[1] + mod_data[0])
	dirtied_stats.erase(Stats.Constitution)

func recalc_strength():
	strength = base_stats["Strength"]
	if Stats.Strength in modified_stats.keys():
		var mod_data = modified_stats[Stats.Strength]
		strength = int(strength * mod_data[1] + mod_data[0])
	dirtied_stats.erase(Stats.Strength)

func recalc_dexterity():
	dexterity = base_stats["Dexterity"]
	if Stats.Dexterity in modified_stats.keys():
		var mod_data = modified_stats[Stats.Dexterity]
		dexterity = int(dexterity * mod_data[1] + mod_data[0])
	dirtied_stats.erase(Stats.Dexterity)

func recalc_intelligence():
	intelligence = base_stats["Intelligence"]
	if Stats.Intelligence in modified_stats.keys():
		var mod_data = modified_stats[Stats.Intelligence]
		intelligence = int(intelligence * mod_data[1] + mod_data[0])
	dirtied_stats.erase(Stats.Intelligence)

func recalc_wisdom():
	wisdom = base_stats["Wisdom"]
	if Stats.Wisdom in modified_stats.keys():
		var mod_data = modified_stats[Stats.Wisdom]
		wisdom = int(wisdom * mod_data[1] + mod_data[0])
	dirtied_stats.erase(Stats.Wisdom)

func recalc_charisma():
	charisma = base_stats["Charisma"]
	if Stats.Charisma in modified_stats.keys():
		var mod_data = modified_stats[Stats.Charisma]
		charisma = int(charisma * mod_data[1] + mod_data[0])
	dirtied_stats.erase(Stats.Charisma)

func recalc_health():
	for stat in DEPENDENCIES[Stats.Health]:
		check_if_dirty(stat)
	var tmp_health = health
	health = constitution * 10 + constitution * 5 * level
	if Stats.Health in modified_stats.keys():
		var mod_data = modified_stats[Stats.Health]
		health = int(health * mod_data[1] + mod_data[0])
	if current_health > health:
		current_health = health
	if tmp_health < health:
		current_health += health - tmp_health
	health = round(health)
	dirtied_stats.erase(Stats.Health)

func recalc_mana():
	for stat in DEPENDENCIES[Stats.Mana]:
		check_if_dirty(stat)
	var tmp_mana = mana
	mana = intelligence * 10 + intelligence * 5 * level
	if Stats.Mana in modified_stats.keys():
		var mod_data = modified_stats[Stats.Mana]
		mana = int(mana * mod_data[1] + mod_data[0])
	if current_mana > mana:
		current_mana = mana
	if tmp_mana < mana:
		current_mana += mana - tmp_mana
	mana = round(mana)
	dirtied_stats.erase(Stats.Mana)

func recalc_mana_regen():
	for stat in DEPENDENCIES[Stats.Mana_Regen]:
		check_if_dirty(stat)
	mana_regen = intelligence * 0.1 + intelligence * 0.05 * level
	if Stats.Mana_Regen in modified_stats.keys():
		var mod_data = modified_stats[Stats.Mana_Regen]
		mana_regen = mana_regen * mod_data[1] + mod_data[0]
	mana_regen = round(mana_regen * 100) / 100.0
	dirtied_stats.erase(Stats.Mana_Regen)

func recalc_stamina():
	for stat in DEPENDENCIES[Stats.Stamina]:
		check_if_dirty(stat)
	stamina = 40 + constitution * level
	if Stats.Stamina in modified_stats.keys():
		var mod_data = modified_stats[Stats.Stamina]
		stamina = int(stamina * mod_data[1] + mod_data[0])
	if current_stamina > stamina:
		current_stamina = stamina
	stamina = round(stamina)
	dirtied_stats.erase(Stats.Stamina)

func recalc_defense():
	for stat in DEPENDENCIES[Stats.Defense]:
		check_if_dirty(stat)
	defense = int(dexterity * 0.5 * level + constitution * 0.2 * level)
	# if armor_equiped:
	# 	pass
	if Stats.Defense in modified_stats.keys():
		var mod_data = modified_stats[Stats.Defense]
		defense = int(defense * mod_data[1] + mod_data[0])
	defense = round(defense)
	dirtied_stats.erase(Stats.Defense)

func recalc_damage():
	if Stats.Replacement_Damage in modified_stats.keys():
		check_if_dirty(modified_stats[Stats.Replacement_Damage][3]) # Right now only strength or Dex
		var lower = modified_stats[Stats.Replacement_Damage][0]
		var upper = modified_stats[Stats.Replacement_Damage][1]
		var constant = modified_stats[Stats.Replacement_Damage][2]
		var stat_enum = modified_stats[Stats.Replacement_Damage][3]
		var stat_value = strength if stat_enum == Stats.Strength else dexterity
		min_damage = lower * stat_value + constant
		max_damage = upper * stat_value + constant
		print("Using replacement damage: ", min_damage, " to ", max_damage)
	else:
		for stat in DEPENDENCIES[Stats.Damage]:
			check_if_dirty(stat)
		var damage = strength * 0.5 + strength * 0.1 * level
		min_damage = damage
		max_damage = damage
	if Stats.Damage in modified_stats.keys():
		var mod_data = modified_stats[Stats.Damage]
		min_damage = min_damage * mod_data[1] + mod_data[0]
		max_damage = max_damage * mod_data[1] + mod_data[0]
	min_damage = round(min_damage)
	max_damage = round(max_damage)
		# damage = round(damage)
	# if attack_area:
	attack_area.min_damage = min_damage
	attack_area.max_damage = max_damage
	dirtied_stats.erase(Stats.Damage)

func recalc_weight_capacity():
	for stat in DEPENDENCIES[Stats.Weight_Capacity]:
		check_if_dirty(stat)
	weight_capacity = strength * 5
	if Stats.Weight_Capacity in modified_stats.keys():
		var mod_data = modified_stats[Stats.Weight_Capacity]
		weight_capacity = int(weight_capacity * mod_data[1] + mod_data[0])
	soft_capacity = weight_capacity * 0.5
	hard_capacity = weight_capacity
	weight_capacity = round(weight_capacity)
	soft_capacity = round(soft_capacity * 100) / 100.0
	hard_capacity = round(hard_capacity * 100) / 100.0
	weight_capacity += weight_ignore # This is for UI, so the player sees the full capacity
	dirtied_stats.erase(Stats.Weight_Capacity)

func recalc_base_speed():
	for stat in DEPENDENCIES[Stats.Base_Speed]:
		check_if_dirty(stat)
	base_speed = 1 + dexterity * 0.1 + dexterity * 0.05 * level
	if Stats.Base_Speed in modified_stats.keys():
		var mod_data = modified_stats[Stats.Base_Speed]
		base_speed = base_speed * mod_data[1] + mod_data[0]
	base_speed = round(base_speed * 100) / 100.0
	dirtied_stats.erase(Stats.Base_Speed)

func recalc_weight_ignore():
	for stat in DEPENDENCIES[Stats.Weight_Ignore]:
		check_if_dirty(stat)
	weight_ignore = strength * 1.5
	if Stats.Weight_Ignore in modified_stats.keys():
		var mod_data = modified_stats[Stats.Weight_Ignore]
		weight_ignore = weight_ignore * mod_data[1] + mod_data[0]
	weight_ignore = round(weight_ignore * 100) / 100.0
	dirtied_stats.erase(Stats.Weight_Ignore)

func recalc_speed():
	# print("Recalculating speed...")
	for stat in DEPENDENCIES[Stats.Speed]:
		check_if_dirty(stat)
	speed = base_speed
	var current_weight = 0.0
	var effective_weight = 0.0
	if Stats.Current_Weight in modified_stats.keys():
		current_weight = modified_stats[Stats.Current_Weight][0]
	if current_weight > weight_ignore:
		effective_weight = current_weight - weight_ignore
	else:
		effective_weight = 0.0
	if soft_capacity <= 0:
		assert(false, "Soft capacity is less than or equal to zero in speed calculation")
	if effective_weight <= soft_capacity:
		speed = base_speed * (0.75 + 0.25 * (1 - (effective_weight / soft_capacity)))
	else:
		# Between soft and hard cap: linearly reduce from 75% to 0%
		var remaining_capacity = hard_capacity - soft_capacity
		if remaining_capacity > 0:
			# speed = base_speed * (0.75 * (hard_capacity - effective_weight) / remaining_capacity)
			speed = base_speed * (0.75 * (1 - ((effective_weight - soft_capacity) / remaining_capacity)))
		else:
			speed = 0
	if speed < 0:
		speed = 0
	if Stats.Speed in modified_stats.keys():
		var mod_data = modified_stats[Stats.Speed]
		speed = speed * mod_data[1] + mod_data[0]
	speed = round(speed * 100) / 100.0
	dirtied_stats.erase(Stats.Speed)

func recalc_poison_resist():
	for stat in DEPENDENCIES[Stats.Poison_Resist]:
		check_if_dirty(stat)
	resistences["Poison_Resist"] = constitution / (constitution + 50)
	if Stats.Poison_Resist in modified_stats.keys():
		var mod_data = modified_stats[Stats.Poison_Resist]
		resistences["Poison_Resist"] = resistences["Poison_Resist"] * mod_data[1] + mod_data[0]
	resistences["Poison_Resist"] = round(resistences["Poison_Resist"] * 100) / 100.0
	dirtied_stats.erase(Stats.Poison_Resist)

func recalc_magic_resist():
	for stat in DEPENDENCIES[Stats.Magic_Resist]:
		check_if_dirty(stat)
	resistences["Magic_Resist"] = wisdom / (wisdom + 50)
	if Stats.Magic_Resist in modified_stats.keys():
		var mod_data = modified_stats[Stats.Magic_Resist]
		resistences["Magic_Resist"] = resistences["Magic_Resist"] * mod_data[1] + mod_data[0]
	resistences["Magic_Resist"] = round(resistences["Magic_Resist"] * 100) / 100.0
	dirtied_stats.erase(Stats.Magic_Resist)

func recalc_fire_resist():
	for stat in DEPENDENCIES[Stats.Fire_Resist]:
		check_if_dirty(stat)
	resistences["Fire_Resist"] = constitution / (constitution + 50)
	if Stats.Fire_Resist in modified_stats.keys():
		var mod_data = modified_stats[Stats.Fire_Resist]
		resistences["Fire_Resist"] = resistences["Fire_Resist"] * mod_data[1] + mod_data[0]
	resistences["Fire_Resist"] = round(resistences["Fire_Resist"] * 100) / 100.0
	dirtied_stats.erase(Stats.Fire_Resist)

func recalc_cold_resist():
	for stat in DEPENDENCIES[Stats.Cold_Resist]:
		check_if_dirty(stat)
	resistences["Cold_Resist"] = constitution / (constitution + 50)
	if Stats.Cold_Resist in modified_stats.keys():
		var mod_data = modified_stats[Stats.Cold_Resist]
		resistences["Cold_Resist"] = resistences["Cold_Resist"] * mod_data[1] + mod_data[0]
	resistences["Cold_Resist"] = round(resistences["Cold_Resist"] * 100) / 100.0
	dirtied_stats.erase(Stats.Cold_Resist)

func recalc_lightning_resist():
	for stat in DEPENDENCIES[Stats.Lightning_Resist]:
		check_if_dirty(stat)
	resistences["Lightning_Resist"] = constitution / (constitution + 50)
	if Stats.Lightning_Resist in modified_stats.keys():
		var mod_data = modified_stats[Stats.Lightning_Resist]
		resistences["Lightning_Resist"] = resistences["Lightning_Resist"] * mod_data[1] + mod_data[0]
	resistences["Lightning_Resist"] = round(resistences["Lightning_Resist"] * 100) / 100.0
	dirtied_stats.erase(Stats.Lightning_Resist)

func take_damage(dmg: int) -> void:
	check_if_dirty(Stats.Defense)
	current_health -= max(dmg - defense, 0)
	if current_health <= 0:
		current_health = 0
		die()

func die() -> void:
	# Handle player death (e.g., respawn, game over screen, etc.)
	animation_player.play("Death")
	walking_colision.disabled = true
	attack_area.monitoring = false
	hit_box.disabled = true
	# Additional death handling code here

func get_current_weight() -> float:
	var current_weight = 0.0
	# check_if_dirty(Stats.Current_Weight)
	check_if_dirty(Stats.Speed)
	# check_if_dirty(Stats.Weight_Capacity)
	if Stats.Current_Weight in modified_stats.keys():
		current_weight = modified_stats[Stats.Current_Weight][0]
	# check_if_dirty(Stats.Current_Weight)
	return current_weight
