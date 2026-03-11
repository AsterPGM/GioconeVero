extends StaticBody3D

@export var dati_oggetto: ItemData 

func interagisci() -> void:
	if dati_oggetto != null:
		GameManager.aggiungi_risorsa(dati_oggetto.id_oggetto, 1)
		print("Hai raccolto: ", dati_oggetto.nome_visibile)
		queue_free() 
	else:
		print("ERRORE: ItemData mancante nell'ispettore!")
