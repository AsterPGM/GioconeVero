extends Node

# ==========================================
# SEGNALI GLOBALI
# ==========================================
signal risorse_aggiornate 

# ==========================================
# DATI
# ==========================================
# Formato: { "nome_risorsa": quantita_intera }
var inventario: Dictionary = {}

# ==========================================
# GESTIONE RISORSE
# ==========================================
func aggiungi_risorsa(nome_risorsa: String, quantita: int) -> void:
	# Usa get() per partire da 0 se la risorsa è nuova, altrimenti somma al valore esistente.
	inventario[nome_risorsa] = inventario.get(nome_risorsa, 0) + quantita
	risorse_aggiornate.emit()

func spendi_risorsa(nome_risorsa: String, quantita: int) -> bool:
	if possiede_risorsa(nome_risorsa, quantita):
		inventario[nome_risorsa] -= quantita
		risorse_aggiornate.emit()
		return true
	return false

# ==========================================
# UTILITY E LETTURA
# ==========================================
func possiede_risorsa(nome_risorsa: String, quantita_richiesta: int) -> bool:
	return inventario.get(nome_risorsa, 0) >= quantita_richiesta

func ottieni_quantita(nome_risorsa: String) -> int:
	return inventario.get(nome_risorsa, 0)
