extends Resource
class_name ItemData

@export_group("Dati Base")
@export var id: String = "" # IMPORTANTE: Questo deve essere "legna", "pietra", ecc.
@export var nome_mostrato: String = "" # Es: "Legno di Quercia"
@export var icona: Texture2D
@export_multiline var descrizione: String = ""
