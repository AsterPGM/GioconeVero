extends Node

signal risorse_aggiornate 

# IL VERO INVENTARIO: Un Dizionario!
var inventario: Dictionary = {
	"legna": 0,
	"pietra": 0
	# Un domani aggiungerai qui "ferro": 0, "carne": 0, ecc.
}

# 1. FUNZIONE UNIVERSALE PER RACCOGLIERE
func aggiungi_risorsa(nome_risorsa: String, quantita: int) -> void:
	if inventario.has(nome_risorsa): # Controlla se l'oggetto esiste nel dizionario
		inventario[nome_risorsa] += quantita
		risorse_aggiornate.emit()
	else:
		print("ERRORE: La risorsa '", nome_risorsa, "' non esiste nell'inventario!")

# 2. FUNZIONE UNIVERSALE PER SPENDERE/COSTRUIRE
func spendi_risorsa(nome_risorsa: String, quantita: int) -> bool:
	if inventario.has(nome_risorsa) and inventario[nome_risorsa] >= quantita:
		inventario[nome_risorsa] -= quantita
		risorse_aggiornate.emit()
		return true
	return false
