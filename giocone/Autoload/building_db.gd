extends Node

# Il dizionario dove salveremo tutti i progetti
var database_interno: Dictionary = {}

# Il percorso esatto della cartella dove hai messo i file .tres delle costruzioni
const CARTELLA_PROGETTI = "res://Dati/Progetti_Costruzione/"

func _ready() -> void:
	carica_tutti_i_progetti()

func carica_tutti_i_progetti() -> void:
	var cartella = DirAccess.open(CARTELLA_PROGETTI)
	
	if cartella:
		cartella.list_dir_begin()
		var nome_file = cartella.get_next()
		
		while nome_file != "":
			if not cartella.current_is_dir() and nome_file.ends_with(".tres"):
				var percorso_completo = CARTELLA_PROGETTI + nome_file
				# Carica il file assicurandosi che sia uno "stampino" BuildingData
				var progetto = load(percorso_completo) as BuildingData
				
				if progetto != null and progetto.nome != "":
					# Lo salva nel dizionario usando il nome come "chiave"
					database_interno[progetto.nome] = progetto
					print("BuildingDB ha caricato: ", progetto.nome, " (Categoria: ", progetto.categoria, ")")
					
			nome_file = cartella.get_next()
	else:
		print("ERRORE: Impossibile trovare la cartella ", CARTELLA_PROGETTI)

# ==========================================
# LA FUNZIONE MAGICA PER LA GRIGLIA
# ==========================================
# Quando la UI chiederà "Dammi tutti i progetti della categoria Difesa", 
# questa funzione glieli impacchetterà e glieli manderà pronti da disegnare!
func ottieni_progetti_per_categoria(categoria_richiesta: String) -> Array[BuildingData]:
	var lista_filtrata: Array[BuildingData] = []
	
	# Scorre tutti i progetti che ha in memoria
	for chiave in database_interno:
		var progetto = database_interno[chiave]
		# Se la categoria corrisponde a quella che cerchiamo, lo aggiunge alla lista
		if progetto.categoria == categoria_richiesta:
			lista_filtrata.append(progetto)
			
	return lista_filtrata
