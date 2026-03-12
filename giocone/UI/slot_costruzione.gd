extends Button

# ==========================================
# SEGNALI
# ==========================================
signal progetto_scelto(progetto: BuildingData)

# ==========================================
# COMPONENTI VISIVI
# ==========================================
@onready var icona_struttura = $VBoxContainer/IconaStruttura
@onready var nome_struttura = $VBoxContainer/NomeStruttura
@onready var testo_costo = $VBoxContainer/TestoCosto

var progetto_assegnato: BuildingData

# ==========================================
# INIZIALIZZAZIONE
# ==========================================
func inizializza(dati_progetto: BuildingData) -> void:
	progetto_assegnato = dati_progetto
	
	# Compilazione dati visivi
	nome_struttura.text = dati_progetto.nome
	if dati_progetto.icona != null:
		icona_struttura.texture = dati_progetto.icona
		
	var risorsa: String = dati_progetto.risorsa_richiesta
	var costo: int = dati_progetto.quantita_richiesta
	testo_costo.text = "Costo: %d %s" % [costo, risorsa] # Metodo di formattazione stringhe più pulito
	
	# Controllo disponibilità risorse
	if GameManager.possiede_risorsa(risorsa, costo):
		disabled = false
		modulate = Color(1, 1, 1, 1) 
	else:
		# Bottone disabilitato con tinta rossastra
		disabled = true
		modulate = Color(1.0, 0.5, 0.5, 0.7) 

# ==========================================
# INTERAZIONE
# ==========================================
func _pressed() -> void:
	progetto_scelto.emit(progetto_assegnato)
