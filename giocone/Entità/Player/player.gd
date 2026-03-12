extends CharacterBody3D

# ==========================================
# STATISTICHE E MOVIMENTO
# ==========================================
@export_group("Statistiche Base")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var acceleration: float = 12.0
@export var friction: float = 10.0
@export var jump_velocity: float = 5.0 

@export_group("Schivata")
@export var dodge_speed: float = 15.0 
@export var dodge_duration: float = 0.25 
var is_dodging: bool = false 
var dodge_timer: float = 0.0 
var last_direction: Vector3 = Vector3.BACK 

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var sprite = $Sprite3D
@onready var interact_ray = $RayCast3D 

# ==========================================
# UI E COMPONENTI
# ==========================================
@onready var menu_radiale = $"../MenuRadiale"
@onready var menu_costruzione = $"../MenuCostruzione"
var is_tab_held: bool = false
var tab_hold_time: float = 0.0
const TAB_DELAY: float = 0.5 

# IL NOSTRO NUOVO COMPONENTE!
@onready var costruttore = $Costruttore

func _ready() -> void:
	# Il player connette la UI direttamente al Costruttore!
	if menu_costruzione != null:
		menu_costruzione.progetto_da_costruire.connect(costruttore.ricevi_progetto_dal_menu)

func _physics_process(delta: float) -> void:
	applica_gravita(delta)
	
	if is_dodging:
		elabora_schivata(delta)
	else:
		controlla_salto()
		controlla_avvio_schivata()
		elabora_movimento_base(delta)

	move_and_slide()

	# Il Player ordina al costruttore di aggiornare la posizione dell'ologramma
	costruttore.aggiorna_posizione()
	gestisci_cronometro_menu(delta)

func _unhandled_input(event: InputEvent) -> void:
	gestisci_input_interazione(event)
	gestisci_input_menu(event)
	
	# Il Player passa i tasti premuti al Costruttore
	costruttore.gestisci_input(event)

# ==========================================

# ==========================================

func applica_gravita(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

func controlla_salto() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

func controlla_avvio_schivata() -> void:
	if Input.is_action_just_pressed("dodge") and is_on_floor() and not is_dodging:
		is_dodging = true 
		dodge_timer = dodge_duration 

func elabora_schivata(delta: float) -> void:
	dodge_timer -= delta
	if dodge_timer <= 0:
		is_dodging = false
	else:
		velocity.x = last_direction.x * dodge_speed
		velocity.z = last_direction.z * dodge_speed

func elabora_movimento_base(delta: float) -> void:
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
		
		sprite.flip_h = (direction.x < 0)
	else: 
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)

func gestisci_cronometro_menu(delta: float) -> void:
	if is_tab_held:
		tab_hold_time += delta 
		if tab_hold_time >= TAB_DELAY and menu_radiale != null and not menu_radiale.visible:
			menu_radiale.visible = true 

func gestisci_input_interazione(event: InputEvent) -> void:
	# Controlliamo che il costruttore non stia costruendo prima di interagire
	if event.is_action_pressed("interact") and not costruttore.is_building:
		interact_ray.force_raycast_update() 
		if interact_ray.is_colliding():
			var target = interact_ray.get_collider()
			if target.has_method("interagisci"):
				target.interagisci() 

func gestisci_input_menu(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next"): 
		is_tab_held = true
		tab_hold_time = 0.0

	elif event.is_action_released("ui_focus_next"):
		is_tab_held = false
		if menu_radiale != null and menu_radiale.visible:
			menu_radiale.visible = false 

			if menu_radiale.indice_scelto != -1:
				var categoria_scelta = menu_radiale.categorie[menu_radiale.indice_scelto]
				if menu_costruzione != null:
					menu_costruzione.apri_categoria(categoria_scelta)

		tab_hold_time = 0.0
