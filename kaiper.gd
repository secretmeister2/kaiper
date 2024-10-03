extends CharacterBody2D

# Called when the node enters the scene tree for the first time.
func ready() -> void:
	Dialogic.VAR.HeldObject="none"

@export var collision_shapes: Array[CollisionPolygon2D]

var stancespeeds = {"crouch":5, "normal":10, "stand":5, "sit":0}

var runspeed = 20

var horizjumpmult = 2
var horizjumpvert = 8
var vertjump = 13
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var friction = 10.0

var stance = "normal"
var speed = stancespeeds["normal"]
var standtimer = 0
var jumptimer = 0
var facingdir = 1
var xvelpast = 0

var heldobject = "none"
var heldvel=Vector2(0,0)

@export var textures: Dictionary
var walkingsheet = preload("res://gameassets/KAIPER SPRITE SHEET.png")
#var normaltexture = preload("res://gameassets/WalkingSprite.png")
#var crouchingtexture = preload("res://gameassets/WalkingSprite.png")

var nostand = []
var noupwalk = []
var nodownwalk = []
var nocrouch = []
var colls =[]
##var animation = &"Idle"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:

	if Input.is_action_pressed("sprint") && stance == "normal":
		speed = runspeed
	elif stance == "normal":
		speed = stancespeeds["normal"]
##Grounded Horizontal Movement
	if Input.is_action_pressed("moveright") && Input.is_action_pressed("moveleft")&& is_on_floor():
		velocity.x = velocity.x * (1-(1/friction))
	elif Input.is_action_pressed("moveleft")&& is_on_floor():
		velocity.x -= speed * 4
		velocity.x = velocity.x * (1-(0.5/friction))
	elif Input.is_action_pressed("moveright")&& is_on_floor():
		velocity.x += speed * 4
		velocity.x = velocity.x * (1-(0.5/friction))
	else: 
		if is_on_floor():
			velocity.x = velocity.x  * (1-(1/friction))
##Gravity	
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.x = velocity.x * 0.995
	if is_on_floor():
		velocity.y = 0
##Stance Management
	if Input.is_action_just_pressed("up") && stance=="normal" && is_on_floor() && standtimer <= 0 && nostand.is_empty():
		StanceSwap("stand")
	elif Input.is_action_just_pressed("up") && stance=="crouch" && is_on_floor() && noupwalk.is_empty():
		StanceSwap("normal")
	elif Input.is_action_just_pressed("down") && stance == "stand" && is_on_floor() && nodownwalk.is_empty():
		StanceSwap("normal")
	elif Input.is_action_just_pressed("down") && stance == "normal" && is_on_floor() && nocrouch.is_empty():
		StanceSwap("crouch")
	if stance == "stand":
		if standtimer == 100 && is_on_floor() && nodownwalk.is_empty():
			StanceSwap("normal")
		elif standtimer == 100:
			standtimer=101
	if standtimer > 0:
		standtimer -= 1 
	if stance != "stand" && Input.is_action_just_pressed("sit"):
		StanceSwap("sit")
	if stance == "sit" && (Input.is_action_just_pressed("up")):
		StanceSwap("normal")

##Jumping
	if jumptimer > 0:
		jumptimer -= 1 
	if Input.is_action_pressed("jump") && stance == "stand" && is_on_floor() && jumptimer == 0:
		velocity.y = -100 * vertjump
		jumptimer=50
	elif Input.is_action_pressed("jump") && stance == "normal" && is_on_floor() && jumptimer == 0:
		velocity.y = -100 * horizjumpvert
		velocity.x += horizjumpmult * velocity.x
		jumptimer=50
		if abs(velocity.x) > 1500:
			velocity.x = facingdir * -1500
		if abs(velocity.x) < 400 && abs(velocity.x) > 0:
			velocity.x = facingdir * -400
		if abs(velocity.x) == 0:
			velocity.x = facingdir * -400
	##Physics step and directionality
	move_and_slide()
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_force(c.get_normal() * -180)
	
	if xvelpast <= 0 && velocity.x > 0:
		facingdir=-1
	if xvelpast >= 0 && velocity.x < 0:
		facingdir =1
	xvelpast = velocity.x
	
	set_scale(Vector2((facingdir * -1.1), -1.1))
	set_rotation_degrees(180)
##Held object manipulation
	if Input.is_action_just_pressed("pickup") && not (heldobject is RigidBody2D):
		for body in $PickupArea.get_overlapping_bodies():
			if body.is_in_group("PickupableObjects") && not (heldobject is RigidBody2D):
				heldobject = body
				heldobject.freeze=true
				Dialogic.VAR.HeldObject=body.get_name().erase(0, 0)
	elif Input.is_action_just_pressed("pickup") && heldobject is RigidBody2D:
		heldvel=velocity
		heldobject.freeze=false
		heldobject.reset_physics_interpolation()
		heldobject.get_global_position()
		heldobject.set_global_position(Vector2(facingdir*-210, 50) + self.get_global_position())
		heldobject.apply_central_impulse(0.4*heldvel)
		heldobject="none"
		Dialogic.VAR.HeldObject="none"
	elif heldobject is RigidBody2D:
		heldobject.reset_physics_interpolation()
		heldobject.set_global_position(Vector2(facingdir*-210, 50) + self.get_global_position())
	##animations
	##if abs(velocity.x) > 5 && stance == "normal" && $AnimationPlayer.current_animation != &"walk":
	##	$AnimationPlayer.play(&"walk")
	##elif (stance != "normal" or abs(velocity.x) < 5):
	##	$AnimationPlayer.stop()
func find(parent, type):
	for child in parent.get_children():
		if is_instance_of(child, type):
			return child
		var grandchild = find(child, type)
		if grandchild != null:
			return grandchild
	return null

func CrouchToWalkCollides(body: Node2D) -> void:
	if not (body.get_parent() is CharacterBody2D) && not (body is CharacterBody2D) && not (body.get_rotation_degrees()==0.0 && find(body, CollisionPolygon2D).is_one_way_collision_enabled()):
		noupwalk.append(body)
	if body is RigidBody2D:
		noupwalk.append(body)
func CrouchToWalkUncollides(body: Node2D) -> void:
	while noupwalk.has(body):
		noupwalk.erase(body)
	
func WalkToStandCollides(body: Node2D) -> void:
	if not ((body.get_rotation_degrees()==0.0) && (find(body, CollisionPolygon2D).is_one_way_collision_enabled())):
		nostand.append(body)
	if body is RigidBody2D:
		nostand.append(body)
func WalkToStandUncollides(body: Node2D) -> void:
	while nostand.has(body):
		nostand.erase(body)

func StandtoWalkCollides(body: Node2D) -> void:
	if not (body.get_parent() is CharacterBody2D) && not (body is CharacterBody2D) && not (body.get_rotation_degrees()==0.0 && find(body, CollisionPolygon2D).is_one_way_collision_enabled()):
		nodownwalk.append(body)
	if body is RigidBody2D:
		nodownwalk.append(body)
func StandtoWalkUncollides(body: Node2D) -> void:
	while nodownwalk.has(body):
		nodownwalk.erase(body)

func WalkToCrouchCollides(body: Node2D) -> void:
	if not (body.get_parent() is CharacterBody2D) && not (body is CharacterBody2D) && not (body.get_rotation_degrees()==0.0 && find(body, CollisionPolygon2D).is_one_way_collision_enabled()):
		nocrouch.append(body)
	if body is RigidBody2D:
		nocrouch.append(body)
func WalktoCrouchUncollides(body: Node2D) -> void:
	while nocrouch.has(body):
		nocrouch.erase(body)

func StanceSwap(name: String):
	stance = name
	speed = stancespeeds[name]
	for coll in collision_shapes:
		if coll.name.begins_with(name):
			coll.disabled=false
		else:
			coll.disabled=true
	$KaiperSprite.set_texture(textures[name])
	##$KaiperSprite.set_hframes(1)
	##$KaiperSprite.set_vframes(1)
	##$KaiperSprite.set_frame(0)
	if name == "stand":
		standtimer = 300
		$KaiperSprite.set_rotation_degrees(35)
		$KaiperSprite.set_offset(Vector2(0, 60))
	else:
		standtimer -= 150
		$KaiperSprite.set_rotation_degrees(0)
		$KaiperSprite.set_offset(Vector2(0, 450))

##NOTES FOR WHAT DO NEXT: Ledge grab, fix landing on one ways
