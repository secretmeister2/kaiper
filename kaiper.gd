extends CharacterBody2D

# Called when the node enters the scene tree for the first time.
func ready() -> void:
	pass

var crouchspeed = 5
var standspeed = 5
var walkspeed = 10
var runspeed = 20
var horizjumpmult = 2
var horizjumpvert = 8
var vertjump = 13
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var friction = 10.0

var stance = 1
var speed = walkspeed
var standtimer = 0
var jumptimer = 0
var facingdir = 1
var xvelpast = 0

var walkingsheet = preload("res://gameassets/KAIPER SPRITE SHEET.png")
var walkingtexture = preload("res://gameassets/WalkingSprite.png")
var standingtexture = preload("res://gameassets/StandingSprite.png")
var crouchingtexture = preload("res://gameassets/WalkingSprite.png")

var nostand = []
var noupwalk = []
var nodownwalk = []
var nocrouch = []
var colls =[]
##var animation = &"Idle"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("sprint") && stance == 1:
		speed = runspeed
	elif stance == 1:
		speed = walkspeed
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
	if Input.is_action_just_pressed("up") && stance==1 && is_on_floor() && standtimer <= 0 && nostand.is_empty():
		stance = 2
		standtimer = 300
		speed = standspeed
	elif Input.is_action_just_pressed("up") && stance==0 && is_on_floor() && noupwalk.is_empty():
		stance = 1
		speed = walkspeed
	elif Input.is_action_just_pressed("down") && stance == 2 && is_on_floor() && nodownwalk.is_empty():
		stance = 1
		speed = walkspeed
		standtimer -= 150
	elif Input.is_action_just_pressed("down") && stance == 1 && is_on_floor() && nocrouch.is_empty():
		stance = 0
		speed = crouchspeed

	if stance == 2:
		$StandPhysColl.disabled = false
		$NormalPhysColl.disabled = true
		$CrouchPhysColl.disabled = true
		$KaiperSprite.set_texture(standingtexture)
		##$KaiperSprite.set_hframes(1)
		##$KaiperSprite.set_vframes(1)
		##$KaiperSprite.set_frame(0)
		$KaiperSprite.set_rotation_degrees(35)
		$KaiperSprite.set_offset(Vector2(0, 60))
		##KaiperSprite.scale = Vector2(1, 1)

		if standtimer == 100 && is_on_floor() && nodownwalk.is_empty():
			stance = 1
			speed = walkspeed
		elif standtimer == 100:
			standtimer=101
	if stance == 1:
		$NormalPhysColl.disabled = false
		$StandPhysColl.disabled = true
		$CrouchPhysColl.disabled = true
		$KaiperSprite.set_texture(walkingtexture)
		##$KaiperSprite.set_hframes(5)
		##$KaiperSprite.set_vframes(5)
		$KaiperSprite.set_rotation_degrees(0)
		$KaiperSprite.set_offset(Vector2(0, 450))
		##$KaiperSprite.scale = Vector2(3, 3)
	if stance == 0:
		$CrouchPhysColl.disabled = false
		$StandPhysColl.disabled = true
		$NormalPhysColl.disabled = true
		$KaiperSprite.set_texture(crouchingtexture)
		##$KaiperSprite.set_hframes(1)
		##$KaiperSprite.set_vframes(1)
		##$KaiperSprite.set_frame(0)
		$KaiperSprite.set_rotation_degrees(0)
		$KaiperSprite.set_offset(Vector2(0, 450))
		##$KaiperSprite.scale = Vector2(1, 1)

	
	if standtimer > 0:
		standtimer -= 1 
	if jumptimer > 0:
		jumptimer -= 1 
##Jumping
	if Input.is_action_pressed("jump") && stance == 2 && is_on_floor() && jumptimer == 0:
		velocity.y = -100 * vertjump
		jumptimer=50
	elif Input.is_action_pressed("jump") && stance == 1 && is_on_floor() && jumptimer == 0:
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
	
	##animations
	##if abs(velocity.x) > 5 && stance == 1 && $AnimationPlayer.current_animation != &"walk":
	##	$AnimationPlayer.play(&"walk")
	##elif (stance != 1 or abs(velocity.x) < 5):
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
	if not (body.get_parent() is CharacterBody2D) && (not body is CharacterBody2D) && not (body.get_rotation_degrees()==0.0 && find(body, CollisionPolygon2D).is_one_way_collision_enabled()):
		noupwalk.append(body)
	if is_instance_of(body, RigidBody2D):
		noupwalk.append(body)
func CourchToWalkUncollides(body: Node2D) -> void:
	while noupwalk.has(body):
		noupwalk.erase(body)
	
func WalkToStandCollides(body: Node2D) -> void:
	if not (body.get_parent() is CharacterBody2D) && (not body is CharacterBody2D) && not (body.get_rotation_degrees()==0.0 && find(body, CollisionPolygon2D).is_one_way_collision_enabled()):
		nostand.append(body)
	if is_instance_of(body, RigidBody2D):
		nostand.append(body)
func WalkToStandUncollides(body: Node2D) -> void:
	while nostand.has(body):
		nostand.erase(body)

func StandtoWalkCollides(body: Node2D) -> void:
	if not (body.get_parent() is CharacterBody2D) && (not body is CharacterBody2D) && not (body.get_rotation_degrees()==0.0 && find(body, CollisionPolygon2D).is_one_way_collision_enabled()):
		nodownwalk.append(body)
	if is_instance_of(body, RigidBody2D):
		nodownwalk.append(body)
func StandtoWalkUncollides(body: Node2D) -> void:
	while nodownwalk.has(body):
		nodownwalk.erase(body)

func WalkToCrouchCollides(body: Node2D) -> void:
	if not (body.get_parent() is CharacterBody2D) && (not body is CharacterBody2D) && not (body.get_rotation_degrees()==0.0 && find(body, CollisionPolygon2D).is_one_way_collision_enabled()):
		nocrouch.append(body)
	if is_instance_of(body, RigidBody2D):
		nocrouch.append(body)
func WalktoCrouchUncollides(body: Node2D) -> void:
	while nocrouch.has(body):
		nocrouch.erase(body)
