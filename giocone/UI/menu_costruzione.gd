extends Control

# ==========================================
# SEGNALI
# ==========================================
signal progetto_da_costruire(progetto: BuildingData)

# ==========================================
# COLLEGAMENTI
# ==========================================
@export var scena_slot: PackedScene 
@onready var griglia = $ScrollContainer/Griglia

func _ready() -> void:
	visible = false

# ==========================================
# GESTIONE CATEGORIE
# ==========================================
func apri_categoria(nome_categoria: String) -> void:
	# 1. Pulisce la griglia precedente
	for bottone_vecchio in griglia.get_children():
		bottone_vecchio.queue_free()
		
	# 2. Ottiene i nuovi progetti
	var lista_progetti = BuildingDB.ottieni_progetti_per_categoria(nome_categoria)
	
	if lista_progetti.is_empty():
		print("Nessun progetto trovato per la categoria: ", nome_categoria)
		return
		
	# 3. Popola la griglia
	for progetto in lista_progetti:
		var nuovo_bottone = scena_slot.instantiate()
		griglia.add_child(nuovo_bottone) 
		nuovo_bottone.inizializza(progetto) 
		nuovo_bottone.progetto_scelto.connect(_on_bottone_premuto)
		
	visible = true

func chiudi_menu() -> void:
	visible = false

# ==========================================
# GESTIONE INPUT E SEGNALI
# ==========================================
func _unhandled_input(event: InputEvent) -> void:
	# Early exit: ignora gli input se il menu è chiuso
	if not visible:
		return
		
	# Chiusura con ESC (ui_cancel)
	if event.is_action_pressed("ui_cancel"):
		chiudi_menu()
		
	# Chiusura con Tasto Destro del mouse
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			chiudi_menu()

func _on_bottone_premuto(progetto_ricevuto: BuildingData) -> void:
	chiudi_menu() # Usa la funzione esistente per coerenza
	progetto_da_costruire.emit(progetto_ricevuto)
