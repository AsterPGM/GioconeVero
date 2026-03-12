extends Control

@onready var testo_centro = $TestoCentro

# ==========================================
# IMPOSTAZIONI MENU
# ==========================================
var categorie: Array[String] = ["Difesa", "Accampamento", "Sopravvivenza", "Altro"]
var indice_scelto: int = -1
const ZONA_MORTA: float = 40.0 # Raggio centrale in cui non si seleziona nulla

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	# Early exit: se il menu è chiuso, non calcolare nulla
	if not visible:
		return 
		
	var centro_schermo = get_viewport_rect().size / 2.0
	var mouse = get_global_mouse_position()
	var direzione = mouse - centro_schermo
	
	# Controllo zona morta al centro
	if direzione.length() < ZONA_MORTA:
		indice_scelto = -1
		testo_centro.text = "Scegli Categoria"
		return
		
	# Calcolo dell'angolo e dello spicchio selezionato
	var angolo = rad_to_deg(direzione.angle())
	if angolo < 0:
		angolo += 360.0
		
	var gradi_spicchio = 360.0 / categorie.size()
	var angolo_corretto = fmod(angolo + (gradi_spicchio / 2.0), 360.0)
	
	indice_scelto = int(angolo_corretto / gradi_spicchio)
	testo_centro.text = categorie[indice_scelto]
