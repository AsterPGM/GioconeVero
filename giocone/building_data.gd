extends Resource
class_name BuildingData

@export_group("Identità")
@export var nome: String = "Nuova Struttura"
@export var icona: Texture2D

@export_group("Visual")
@export var scena_da_costruire: PackedScene # Il file .tscn finale
@export var anteprima_mesh: Mesh             # La mesh per l'ologramma

@export_group("Economia")
@export var risorsa_richiesta: String = "legna"
@export var quantita_richiesta: int = 1
