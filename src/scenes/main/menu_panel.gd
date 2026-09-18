extends Control

# --- Captura de nodos en caché (operador $ solo en la cabecera) -------------
@onready var btn_salir: Button = $MarginContainer/VBoxContainer/BtnSalir


func _ready() -> void:
	print("[menu_panel] Menú de la cafetería montado.")
	btn_salir.pressed.connect(_on_btn_salir_pressed)


## Cierre limpio de la aplicación liberando los recursos del equipo.
func _on_btn_salir_pressed() -> void:
	print("[menu_panel] Cerrando la cafetería y liberando recursos...")
	get_tree().quit()
