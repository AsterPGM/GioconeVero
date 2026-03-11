extends CanvasLayer

@onready var pannello = $PannelloInventario

# ATTENZIONE: Questi percorsi devono combaciare ESATTAMENTE con l'albero dei tuoi nodi.
# Se hai chiamato i nodi in modo diverso, aggiusta i nomi qui sotto!
@onready var testo_legna = $PannelloInventario/ListaOggetti/SlotLegna/TestoLegna
@onready var testo_pietra = $PannelloInventario/ListaOggetti/SlotPietra/TestoPietra

func _ready() -> void:
	# 1. Nascondiamo l'inventario all'avvio del gioco
	pannello.visible = false
	
	# 2. Colleghiamo l'HUD al "megafono" della Divinità
	GameManager.risorse_aggiornate.connect(aggiorna_schermo)
	
	# 3. Aggiorniamo subito i testi per mostrare gli "0" reali del GameManager
	aggiorna_schermo()

func _unhandled_input(event: InputEvent) -> void:
	# Tasto I (o quello che hai impostato) per aprire/chiudere l'inventario
	if event.is_action_pressed("toggle_inventory"):
		pannello.visible = !pannello.visible

func aggiorna_schermo() -> void:
	# Peschiamo i numeri esatti dal Dizionario Universale!
	testo_legna.text = "x " + str(GameManager.inventario["legna"])
	testo_pietra.text = "x " + str(GameManager.inventario["pietra"])
