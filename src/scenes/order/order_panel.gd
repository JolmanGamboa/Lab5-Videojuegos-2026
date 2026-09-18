extends Control

# --- Captura de nodos en caché (operador $ solo en la cabecera) -------------
@onready var lista_container: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/ListaContainer
@onready var lbl_resumen: Label = $MarginContainer/VBoxContainer/LblResumen
@onready var lbl_cliente: Label = $MarginContainer/VBoxContainer/LblCliente
@onready var btn_entregar: Button = $MarginContainer/VBoxContainer/BtnEntregar
@onready var lbl_resultado: Label = $MarginContainer/VBoxContainer/LblResultado


func _ready() -> void:
	print("[order_panel] Panel de pedido montado.")

	# Suscripción reactiva: la vista se redibuja cuando el pedido cambia.
	EventBus.order_updated.connect(_on_order_updated)
	EventBus.total_changed.connect(_on_total_changed)
	EventBus.customer_changed.connect(_on_customer_changed)
	EventBus.delivery_result.connect(_on_delivery_result)

	btn_entregar.pressed.connect(_on_entregar_pressed)


# --- Reacción a los eventos del bus -----------------------------------------

## Redibuja la lista completa con el pedido recibido.
func _on_order_updated(order: Dictionary) -> void:
	_limpiar_lista()

	# Sin productos no hay nada que entregar: el botón se desactiva.
	btn_entregar.disabled = order.is_empty()

	if order.is_empty():
		_agregar_mensaje_vacio()
		return

	for item_id: String in order.keys():
		_agregar_fila(item_id, order[item_id])


## Refresca el total sin calcular nada por su cuenta.
func _on_total_changed(new_total: int) -> void:
	lbl_resumen.text = "Total del pedido: $%d" % new_total


## Muestra el cliente en turno para comparar con el pedido armado.
func _on_customer_changed(customer: Dictionary) -> void:
	lbl_cliente.text = "%s pide: %s" % [str(customer["nombre"]), str(customer["descripcion"])]


## Retroalimentación de la entrega: verde si fue correcta, roja si no.
func _on_delivery_result(success: bool, message: String) -> void:
	lbl_resultado.text = message
	if success:
		lbl_resultado.add_theme_color_override("font_color", Color(0.4, 0.85, 0.4))
	else:
		lbl_resultado.add_theme_color_override("font_color", Color(0.95, 0.4, 0.4))


# --- Construcción dinámica de la lista --------------------------------------

## Destruye las filas previas liberando su memoria.
func _limpiar_lista() -> void:
	for fila: Node in lista_container.get_children():
		fila.queue_free()


## Crea una fila con los datos del producto y su botón para retirarlo.
func _agregar_fila(item_id: String, datos: Dictionary) -> void:
	var fila: HBoxContainer = HBoxContainer.new()
	fila.add_theme_constant_override("separation", 16)

	var etiqueta: Label = Label.new()
	etiqueta.text = "%s · tamaño %s · $%d" % [
		str(datos["nombre"]),
		str(datos["tamanio"]),
		int(datos["precio"])
	]
	etiqueta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(etiqueta)

	var btn_quitar: Button = Button.new()
	btn_quitar.text = "Quitar"
	btn_quitar.custom_minimum_size = Vector2(120, 40)
	# El mismo callback sirve a todas las filas gracias a bind().
	btn_quitar.pressed.connect(_on_quitar_pressed.bind(item_id))
	fila.add_child(btn_quitar)

	lista_container.add_child(fila)


## Estado vacío del pedido.
func _agregar_mensaje_vacio() -> void:
	var etiqueta: Label = Label.new()
	etiqueta.text = "El pedido está vacío. Agrega productos desde el mostrador."
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lista_container.add_child(etiqueta)


# --- Emisión de intenciones -------------------------------------------------

## Publica la intención de retirar el producto. El pedido lo actualiza GlobalManager.
func _on_quitar_pressed(item_id: String) -> void:
	print("[order_panel] Intención item_removed -> " + item_id)
	EventBus.item_removed.emit(item_id)


## Publica la intención de entregar. La validación la hace GlobalManager.
func _on_entregar_pressed() -> void:
	print("[order_panel] Intención order_delivered")
	EventBus.order_delivered.emit()
