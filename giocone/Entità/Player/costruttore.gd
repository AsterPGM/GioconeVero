extends Node3D

# ==========================================
# VARIABILI COSTRUZIONE
# ==========================================
var progetto_attuale: BuildingData 
var is_building: bool = false

# Nodi interni al Costruttore
@onready var ologramma = $Ologramma        
@onready var build_cast = $BuildCast      

# Referenza al Player (il suo genitore) per sapere dove guarda
@onready var player = $".." 

# ==========================================
# AGGIORNAMENTO POSIZIONE
# ==========================================
func aggiorna_posizione() -> void:
	if is_building:
		# Usa la last_direction e global_position del Player!
		var spawn_pos = player.global_position + (player.last_direction * 2.0)
		spawn_pos.y = 1.0 
		ologramma.global_position = spawn_pos
		build_cast.global_position = spawn_pos

# ==========================================
# INPUT
# ==========================================
func gestisci_input(event: InputEvent) -> void:
	if event.is_action_pressed("build"):
		if progetto_attuale != null:
			toggle_modalita_costruzione()
		else:
			print("Nessun progetto selezionato! Usa TAB per sceglierne uno.")
		return
		
	if is_building:
		if event.is_action_pressed("rotate_build"):
			ologramma.rotation_degrees.y += 90
			build_cast.rotation_degrees.y += 90
		elif event.is_action_pressed("confirm_build"):
			tenta_piazzamento_edificio()

# ==========================================
# LOGICA COSTRUZIONE
# ==========================================
func toggle_modalita_costruzione() -> void:
	if is_building:
		chiudi_costruzione()
		return

	if progetto_attuale == null:
		return
		
	var risorsa = progetto_attuale.risorsa_richiesta
	var costo = progetto_attuale.quantita_richiesta
	
	if GameManager.inventario.has(risorsa) and GameManager.inventario[risorsa] >= costo: 
		is_building = true 
		ologramma.visible = true
		ologramma.mesh = progetto_attuale.anteprima_mesh
		
		var progetto_fantasma = progetto_attuale.scena_da_costruire.instantiate()
		build_cast.shape = progetto_fantasma.get_node("CollisionShape3D").shape
		progetto_fantasma.queue_free() 
		build_cast.enabled = true
	else:
		print("Risorse insufficienti per iniziare. Ti servono: ", costo, " ", risorsa)
		chiudi_costruzione()

func tenta_piazzamento_edificio() -> void:
	var risorsa = progetto_attuale.risorsa_richiesta
	var costo = progetto_attuale.quantita_richiesta
	
	if not GameManager.inventario.has(risorsa) or GameManager.inventario[risorsa] < costo:
		chiudi_costruzione()
		return 
		
	build_cast.force_shapecast_update()
	var posso_costruire = true 
	
	if build_cast.is_colliding():
		for i in range(build_cast.get_collision_count()):
			var bersaglio = build_cast.get_collider(i)
			if not bersaglio.is_in_group("Terreno") and bersaglio != player:
				posso_costruire = false 
	
	if posso_costruire:
		if GameManager.spendi_risorsa(risorsa, costo): 
			var nuovo_edificio = progetto_attuale.scena_da_costruire.instantiate()
			# get_tree().current_scene punta alla radice del livello
			get_tree().current_scene.add_child(nuovo_edificio)
			nuovo_edificio.global_transform = ologramma.global_transform 
			
			if GameManager.inventario[risorsa] < costo:
				chiudi_costruzione()
	else:
		print("Costruzione bloccata: L'area è ostruita.")

func chiudi_costruzione() -> void:
	is_building = false
	ologramma.visible = false
	build_cast.enabled = false

# ==========================================
# COMUNICAZIONE CON LA UI
# ==========================================
func ricevi_progetto_dal_menu(nuovo_progetto: BuildingData) -> void:
	progetto_attuale = nuovo_progetto
	if is_building:
		chiudi_costruzione()
	toggle_modalita_costruzione()
