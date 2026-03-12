extends Control

@onready var testo_legna = $PannelloInventario/ListaOggetti/SlotLegna/TestoLegna
@onready var testo_pietra = $PannelloInventario/ListaOggetti/SlotPietra/TestoPietra

func _ready() -> void:
	# 1. Si iscrive agli aggiornamenti del GameManager
	GameManager.risorse_aggiornate.connect(aggiorna_schermo)
	# 2. Aggiorna i testi subito all'avvio
	aggiorna_schermo()
	# 3. Parte chiuso!
	visible = false

# ==========================================
# AGGIORNAMENTO TESTI (Copiato dal vecchio HUD!)
# ==========================================
func aggiorna_schermo() -> void:
	testo_legna.text = "Legna: " + str(GameManager.ottieni_quantita("legna"))
	testo_pietra.text = "Pietra: " + str(GameManager.ottieni_quantita("pietra"))

# ==========================================
# APERTURA / CHIUSURA CON TASTO "I" (Inventario)
# ==========================================
func _unhandled_input(event: InputEvent) -> void:
	# Assicurati di avere un'azione "inventory" mappata al tasto I in Impostazioni Progetto -> Mappa Input
	if event.is_action_pressed("inventory"): 
		visible = !visible # Se è chiuso lo apre, se è aperto lo chiude!
