extends Control

## Catálogo de presentación. Los precios y el pedido NO viven aquí.
const DESCRIPCIONES: Dictionary = {
	"cafe": "Café de origen colombiano, preparado al momento. Precio base $3000.",
	"te": "Infusión de té verde con un toque de limón. Precio base $2500.",
	"chocolate": "Chocolate caliente espeso, receta de la casa. Precio base $3500.",
	"pastel": "Porción de pastel de zanahoria con crema. Precio base $4000."
}

const NOMBRES: Dictionary = {
	"cafe": "Café",
	"te": "Té",
	"chocolate": "Chocolate",
	"pastel": "Pastel"
}

# --- Captura de nodos en caché (operador $ solo en la cabecera) -------------
@onready var btn_cafe: Button = $MarginContainer/VBoxContainer/GridProductos/BtnCafe
@onready var btn_te: Button = $MarginContainer/VBoxContainer/GridProductos/BtnTe
@onready var btn_chocolate: Button = $MarginContainer/VBoxContainer/GridProductos/BtnChocolate
@onready var btn_pastel: Button = $MarginContainer/VBoxContainer/GridProductos/BtnPastel
@onready var lbl_producto: Label = $MarginContainer/VBoxContainer/FichaProducto/MarginFicha/VBoxFicha/LblProducto
@onready var lbl_descripcion: Label = $MarginContainer/VBoxContainer/FichaProducto/MarginFicha/VBoxFicha/LblDescripcion
@onready var lbl_estado: Label = $MarginContainer/VBoxContainer/LblEstado
@onready var lbl_total: Label = $MarginContainer/VBoxContainer/LblTotal
@onready var btn_pequeno: Button = $MarginContainer/VBoxContainer/TamaniosContainer/BtnPequeno
@onready var btn_mediano: Button = $MarginContainer/VBoxContainer/TamaniosContainer/BtnMediano
@onready var btn_grande: Button = $MarginContainer/VBoxContainer/TamaniosContainer/BtnGrande
@onready var lbl_cliente: Label = $MarginContainer/VBoxContainer/PanelCliente/MarginCliente/VBoxCliente/LblCliente
@onready var lbl_atendidos: Label = $MarginContainer/VBoxContainer/PanelCliente/MarginCliente/VBoxCliente/LblAtendidos

## Producto seleccionado en el mostrador. Estado de presentación, no de negocio.
var _producto_seleccionado: String = ""


func _ready() -> void:
	print("[step_1_base] Mostrador montado.")

	# Un único callback por tipo de acción, parametrizado con bind() en lugar
	# de una función por botón. La interfaz no decide nada, solo publica.
	btn_cafe.pressed.connect(_on_producto_pressed.bind("cafe"))
	btn_te.pressed.connect(_on_producto_pressed.bind("te"))
	btn_chocolate.pressed.connect(_on_producto_pressed.bind("chocolate"))
	btn_pastel.pressed.connect(_on_producto_pressed.bind("pastel"))

	btn_pequeno.pressed.connect(_on_tamanio_pressed.bind("pequeno"))
	btn_mediano.pressed.connect(_on_tamanio_pressed.bind("mediano"))
	btn_grande.pressed.connect(_on_tamanio_pressed.bind("grande"))

	# Suscripción reactiva: la etiqueta se actualiza de forma pasiva.
	EventBus.total_changed.connect(_on_total_changed)
	EventBus.customer_changed.connect(_on_customer_changed)


# --- Emisión de intenciones -------------------------------------------------

## Selecciona el producto y muestra su ficha.
func _on_producto_pressed(item_id: String) -> void:
	_producto_seleccionado = item_id
	lbl_producto.text = str(NOMBRES[item_id])
	lbl_descripcion.text = str(DESCRIPCIONES[item_id])
	lbl_estado.text = "Elige el tamaño para agregarlo al pedido."
	print("[step_1_base] Producto seleccionado: " + item_id)


## Publica el tamaño elegido y la intención de agregar el producto.
func _on_tamanio_pressed(base_name: String) -> void:
	if _producto_seleccionado.is_empty():
		lbl_estado.text = "Primero selecciona un producto."
		return

	print("[step_1_base] Intenciones base_selected(%s) e item_added(%s)" % [base_name, _producto_seleccionado])
	EventBus.base_selected.emit(base_name)
	EventBus.item_added.emit(_producto_seleccionado)

	lbl_estado.text = "%s agregado al pedido (tamaño %s)." % [str(NOMBRES[_producto_seleccionado]), base_name]


# --- Reacción a los eventos del bus -----------------------------------------

## Refresca el total sin conocer cómo ni quién lo calculó.
func _on_total_changed(new_total: int) -> void:
	lbl_total.text = "Total del pedido: $%d" % new_total


## Muestra qué pide el cliente en turno: es el contexto de la mecánica.
func _on_customer_changed(customer: Dictionary) -> void:
	lbl_cliente.text = "%s pide: %s" % [str(customer["nombre"]), str(customer["descripcion"])]
	lbl_atendidos.text = "Clientes atendidos: %d · Ganancias: $%d" % [int(customer["atendidos"]), int(customer["ganancias"])]
