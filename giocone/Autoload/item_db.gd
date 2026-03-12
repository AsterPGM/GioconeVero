extends Node

# Il dizionario dove salveremo tutti i dati pronti all'uso
var database_interno: Dictionary = {}

# Il percorso della cartella che abbiamo appena creato
const CARTELLA_OGGETTI = "res://Dati/Oggetti_Inventario/"

func _ready() -> void:
	carica_tutti_gli_oggetti()

func carica_tutti_gli_oggetti() -> void:
	# Apre la cartella degli oggetti
	var cartella = DirAccess.open(CARTELLA_OGGETTI)
	
	if cartella:
		cartella.list_dir_begin()
		var nome_file = cartella.get_next()
		
		# Cicla attraverso tutti i file nella cartella
		while nome_file != "":
			# Se non è una sottocartella e finisce con ".tres"...
			if not cartella.current_is_dir() and nome_file.ends_with(".tres"):
				var percorso_completo = CARTELLA_OGGETTI + nome_file
				var oggetto = load(percorso_completo) as ItemData
				
				# Se il caricamento è andato a buon fine, lo salva nel dizionario
				if oggetto != null and oggetto.id != "":
					database_interno[oggetto.id] = oggetto
					print("ItemDB ha caricato in automatico: ", oggetto.nome_mostrato)
					
			nome_file = cartella.get_next() # Passa al file successivo
	else:
		print("ERRORE: Impossibile trovare la cartella ", CARTELLA_OGGETTI)

# La funzione che userà la UI per chiedere le info
func ottieni_dati_oggetto(id_richiesto: String) -> ItemData:
	if database_interno.has(id_richiesto):
		return database_interno[id_richiesto]
	return null
