extends StaticBody3D

@export_group("Configurazione Risorsa")
@export var dati_oggetto: ItemData 
@export var quantita_per_colpo: int = 1
@export var colpi_massimi: int = 1 # 1 per il cespuglio, 3 o 4 per un albero!

var colpi_ricevuti: int = 0

func interagisci() -> void:
	if dati_oggetto != null:
		# 1. Da la risorsa al giocatore tramite il GameManager
		GameManager.aggiungi_risorsa(dati_oggetto.id, quantita_per_colpo)
		
		# 2. Aggiorna il contatore
		colpi_ricevuti += 1
		print("Hai raccolto ", quantita_per_colpo, " di ", dati_oggetto.nome_mostrato, ". (Colpi: ", colpi_ricevuti, "/", colpi_massimi, ")")
		
		# 3. Distrugge l'oggetto se abbiamo finito i colpi
		if colpi_ricevuti >= colpi_massimi:
			print(dati_oggetto.nome_mostrato, " esaurito!")
			queue_free() 
	else:
		print("ERRORE: ItemData mancante nell'ispettore del nodo ", name, "!")
