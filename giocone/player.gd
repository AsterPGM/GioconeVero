extends CharacterBody3D

# --- STATISTICHE BASE ---
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var acceleration: float = 12.0
@export var friction: float = 10.0
@export var jump_velocity: float = 5.0 

# --- SCHIVATA ---
@export var dodge_speed: float = 15.0 
@export var dodge_duration: float = 0.25 
var is_dodging: bool = false 
var dodge_timer: float = 0.0 
var last_direction: Vector3 = Vector3.BACK 

# --- SISTEMA E NODI ---
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var sprite = $Sprite3D
@onready var interact_ray = $RayCast3D

# --- GATHERING E BUILDING ---
var inventario_legna: int = 0
@export var muro_scene: PackedScene 

var is_building: bool = false
@onready var ologramma = $Ologramma
@onready var build_cast = $BuildCast

func _physics_process(delta: float) -> void:
	# Gravità
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Logica Schivata
	if is_dodging:
		dodge_timer -= delta
		if dodge_timer <= 0:
			is_dodging = false
		else:
			velocity.x = last_direction.x * dodge_speed
			velocity.z = last_direction.z * dodge_speed
			move_and_slide()
			return 

	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Avvio Schivata
	if Input.is_action_just_pressed("dodge") and is_on_floor() and not is_dodging:
		is_dodging = true 
		dodge_timer = dodge_duration 
		return 

	# Movimento Base
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	var current_speed = walk_speed
	if Input.is_action_pressed("sprint") and direction != Vector3.ZERO:
		current_speed = sprint_speed 

	if direction != Vector3.ZERO:
		last_direction = direction 
		interact_ray.target_position = last_direction * 2.0
		
		velocity.x = move_toward(velocity.x, direction.x * current_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * current_speed, acceleration * delta)
		
		# Gira lo sprite a destra/sinistra
		if direction.x < 0:
			sprite.flip_h = true 
		elif direction.x > 0:
			sprite.flip_h = false 
	else: 
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)

	move_and_slide()

	# --- AGGIORNAMENTO POSIZIONE OLOGRAMMA ---
	if is_building:
		var spawn_pos = global_position + (last_direction * 2.0)
		spawn_pos.y = 1.0 # Mantiene l'ologramma all'altezza giusta
		ologramma.global_position = spawn_pos
		build_cast.global_position = spawn_pos


func _unhandled_input(event: InputEvent) -> void:
	
	# ==========================================
	# 1. AZIONE: RACCOGLIERE (Tasto E)
	# ==========================================
	if event.is_action_pressed("interact") and not is_building:
		interact_ray.force_raycast_update()
		if interact_ray.is_colliding():
			var target = interact_ray.get_collider()
			if target.is_in_group("Risorsa"):
				target.queue_free() 
				inventario_legna += 1 
				print("Cespuglio raccolto! Legna: ", inventario_legna)
			else:
				print("Non raccoglibile.")

	# ==========================================
	# 2. AZIONE: ENTRA/ESCI COSTRUZIONE (Tasto B)
	# ==========================================
	elif event.is_action_pressed("build"):
		if inventario_legna >= 1:
			if muro_scene == null:
				print("ERRORE: Inserisci la Scena del Muro nell'Ispettore!")
				return
				
			is_building = !is_building 
			ologramma.visible = is_building
			
			# Se stiamo ACCENDENDO l'ologramma:
			if is_building:
				var progetto_fantasma = muro_scene.instantiate()
				ologramma.mesh = progetto_fantasma.get_node("MeshInstance3D").mesh
				build_cast.shape = progetto_fantasma.get_node("CollisionShape3D").shape
				progetto_fantasma.queue_free()
				print("Progetto in mano. Premi Q per ruotare, Click per piazzare.")
				
			# Se stiamo SPEGNENDO l'ologramma:
			else:
				build_cast.shape = null # Distrugge il sensore fisico
		else:
			print("Niente legna!")
			is_building = false
			ologramma.visible = false
			build_cast.shape = null

	# ==========================================
	# 3. AZIONI MENTRE HAI IL PROGETTO IN MANO
	# ==========================================
	if is_building:
		
		# ROTAZIONE (Tasto Q)
		if event.is_action_pressed("rotate_build"):
			ologramma.rotation_degrees.y += 90
			build_cast.rotation_degrees.y += 90
			
		# PIAZZAMENTO (Click Sinistro)
		elif event.is_action_pressed("confirm_build"):
			
			# Sicurezza: Hai ancora legna?
			if inventario_legna <= 0:
				is_building = false
				ologramma.visible = false
				build_cast.shape = null
				return 
				
			build_cast.force_shapecast_update()
			var posso_costruire: bool = true 
			
			# Controlla collisioni (ignorando il Terreno)
			if build_cast.is_colliding():
				for i in range(build_cast.get_collision_count()):
					var bersaglio = build_cast.get_collider(i)
					if not bersaglio.is_in_group("Terreno") and bersaglio != self:
						posso_costruire = false 
			
			if posso_costruire == false:
				print("ERRORE: Spazio occupato!")
			else:
				# Piazzo il muro
				inventario_legna -= 1
				var nuovo_muro = muro_scene.instantiate()
				get_tree().current_scene.add_child(nuovo_muro)
				nuovo_muro.global_transform = ologramma.global_transform 
				print("Muro costruito! Legna: ", inventario_legna)
				
				# Se la legna è finita, spegni tutto
				if inventario_legna <= 0:
					is_building = false
					ologramma.visible = false
					build_cast.shape = null
