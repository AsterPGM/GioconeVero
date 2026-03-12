extends Resource
class_name BuildingData

@export_group("Identità")
@export var nome: String = "Nuova Struttura"
@export var icona: Texture2D

# ECCO LA NOVITÀ: Un menu a tendina per scegliere la categoria!
@export_enum("Difesa", "Accampamento", "Sopravvivenza", "Altro") var categoria: String = "Difesa"

@export_group("Visual")
@export var scena_da_costruire: PackedScene
@export var anteprima_mesh: Mesh

@export_group("Economia")
@export var risorsa_richiesta: String = "legna"
@export var quantita_richiesta: int = 1
