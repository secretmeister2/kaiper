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
var gravity = 40
var friction = 10.0

var stance = 1
var speed = walkspeed
var standtimer = 0
var jumptimer = 0
var facingdir = 1
var xvelpast = 0

var standingtexture = preload("res://gameassets/StandingSprite.png")
var walkingtexture = preload("res://gameassets/WalkingSprite.png")

var nostand = []
var nowalk = []

##var animation = &"Idle"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	
	if Input.is_action_pressed("sprint") && stance == 1:
		speed = runspeed
	elif stance == 1:
		speed = walkspeed
##Grounded Horizontal Movement
	if Input.is_action_pressed("moveright") && Input.is_action_pressed("moveleft")&& is_on_floor():
		velocity.x = velocity.x * (1-(1/friction))
	elif Input.is_action_pressed("moveleft")&& is_on_floor():
		velocity.x -= speed * 4
		velocity.x = velocity.x * (1-(1/friction))
	elif Input.is_action_pressed("moveright")&& is_on_floor():
		velocity.x += speed * 4
		velocity.x = velocity.x * (1-(1/friction))
	else: 
		if is_on_floor():
			velocity.x = velocity.x  * (1-(1/friction))
##Gravity	
	if not is_on_floor():
		velocity.y += gravity
		velocity.x = velocity.x * 0.995
	if is_on_floor():
		velocity.y = 0
##Stance Management
	if Input.is_action_just_pressed("up") && stance==1 && is_on_floor() && standtimer <= 0 && nostand.is_empty():
		stance = 2
		standtimer = 300
		speed = standspeed
	elif Input.is_action_just_pressed("up") && stance==0 && is_on_floor() && nowalk.is_empty():
		stance = 1
		speed = walkspeed
	elif Input.is_action_just_pressed("down") && stance == 2 && is_on_floor():
		stance = 1
		speed = walkspeed
		standtimer -= 150
	elif Input.is_action_just_pressed("down") && stance == 1 && is_on_floor():
		stance = 0
		speed = crouchspeed

	if stance == 2:
		$StandPhysColl.disabled = false
		$NormalPhysColl.disabled = true
		$CrouchPhysColl.disabled = true
		$KaiperSprite.set_texture(standingtexture)
		$KaiperSprite.set_rotation_degrees(35)
		$KaiperSprite.set_offset(Vector2(0, 60))
		if standtimer == 100:
			stance = 1
			speed = walkspeed
	if stance == 1:
		$NormalPhysColl.disabled = false
		$StandPhysColl.disabled = true
		$CrouchPhysColl.disabled = true
		$KaiperSprite.set_texture(walkingtexture)
		$KaiperSprite.set_rotation_degrees(0)
		$KaiperSprite.set_offset(Vector2(0, 450))
	if stance == 0:
		$CrouchPhysColl.disabled = false
		$StandPhysColl.disabled = true
		$NormalPhysColl.disabled = true
		$KaiperSprite.set_texture(walkingtexture)
		$KaiperSprite.set_rotation_degrees(0)
		$KaiperSprite.set_offset(Vector2(0, 450))
		
	
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
	if xvelpast <= 0 && velocity.x > 0:
		facingdir=-1
	if xvelpast >= 0 && velocity.x < 0:
		facingdir =1
	xvelpast = velocity.x
	
	set_scale(Vector2((facingdir * -1.1), -1.1))
	set_rotation_degrees(180)

	##animations
##	var new_animation = &"Idle"
##	if velocity.y < 0:
##		new_animation = &"Jump"
	##elif velocity.y >= 0 and not is_on_floor():
		##new_animation = &"Fall"
	##elif absf(velocity.x) > 1:
		##new_animation = &"Run"
	
##	if new_animation != animation:
	##	animation = new_animation
		##$AnimationPlayer.play(new_animation)



func CrouchToWalkCollides(body: Node2D) -> void:
	if not (body.get_parent() is CharacterBody2D) && (not body is CharacterBody2D):
		nowalk.append(body)
func CourchToWalkUncollides(body: Node2D) -> void:
	if not (body.get_parent() is CharacterBody2D) && (not body is CharacterBody2D):
		nowalk.erase(body)
func WalkToStandCollides(body: Node2D) -> void:
	if not (body.get_parent() is CharacterBody2D) && (not body is CharacterBody2D):
		nostand.append(body)
func WalkToStandUncollides(body: Node2D) -> void:
	if not (body.get_parent() is CharacterBody2D) && (not body is CharacterBody2D):
		nostand.erase(body)
