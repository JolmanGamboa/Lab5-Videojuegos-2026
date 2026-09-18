extends Node

## ============================================================================
## GlobalManager — Estado global del pedido (Autoload)
## ============================================================================
## Registrado como Autoload bajo el identificador exacto `GlobalManager`.
##
## Es el único cerebro de cálculo del sistema: ninguna interfaz calcula precios
## ni guarda el pedido. El estado vive aquí y sobrevive a la destrucción de los
## paneles, por lo que el usuario puede salir del mostrador, visitar créditos y
## regresar encontrando su pedido intacto.
## ----------------------------------------------------------------------------

# --- Constantes del dominio -------------------------------------------------

## Recargo en pesos según el tamaño. Es la tabla que define el negocio.
const RECARGO_TAMANIO: Dictionary = {
	"pequeno": 0,
	"mediano": 1000,
	"grande": 2000
}

## Etiqueta legible de cada tamaño, para las pantallas que lo muestran.
const NOMBRES_TAMANIO: Dictionary = {
	"pequeno": "Pequeño",
	"mediano": "Mediano",
	"grande": "Grande"
}

## Fuente única de verdad sobre qué productos vende la cafetería.
const CATALOGO: Dictionary = {
	"cafe": {"nombre": "Café", "precio": 3000},
	"te": {"nombre": "Té", "precio": 2500},
	"chocolate": {"nombre": "Chocolate", "precio": 3500},
	"pastel": {"nombre": "Pastel", "precio": 4000}
}

const TAMANIO_POR_DEFECTO: String = "pequeno"

## Fila de clientes: cada uno pide productos con un tamaño exacto.
## Al terminar la lista se vuelve a empezar.
const CLIENTES: Array = [
	{"nombre": "Ana", "pide": {"cafe": "grande"}},
	{"nombre": "Luis", "pide": {"te": "pequeno", "pastel": "mediano"}},
	{"nombre": "Sofía", "pide": {"chocolate": "mediano"}},
	{"nombre": "Mateo", "pide": {"cafe": "pequeno", "pastel": "grande"}}
]

# --- Estado global de la cafetería ------------------------------------------

## Colección única de datos lógicos. `pedido` mapea id de producto → tamaño.
var estado: Dictionary = {
	"tamanio_activo": TAMANIO_POR_DEFECTO,
	"pedido": {},
	"total": 0,
	"cliente_actual": 0,
	"atendidos": 0,
	"ganancias": 0
}


func _ready() -> void:
	# Suscripción a las intenciones publicadas por la interfaz.
	EventBus.base_selected.connect(_on_base_selected)
	EventBus.item_added.connect(_on_item_added)
	EventBus.item_removed.connect(_on_item_removed)
	EventBus.order_delivered.connect(_on_order_delivered)

	_recalcular()
	print("[global_manager] Estado del pedido inicializado.")


# --- Suscriptores de intenciones de la GUI ----------------------------------

## Fija el tamaño con el que se registrarán los siguientes productos.
func _on_base_selected(base_name: String) -> void:
	if not RECARGO_TAMANIO.has(base_name):
		push_warning("[global_manager] Tamaño desconocido: " + base_name)
		return

	estado["tamanio_activo"] = base_name
	print("[global_manager] Tamaño activo -> " + base_name)


## Agrega un producto al pedido con el tamaño vigente. Si el producto ya
## estaba en el pedido, el nuevo tamaño reemplaza al anterior.
func _on_item_added(item_id: String) -> void:
	if not CATALOGO.has(item_id):
		push_warning("[global_manager] Producto fuera de catálogo: " + item_id)
		return

	var pedido: Dictionary = estado["pedido"]
	pedido[item_id] = estado["tamanio_activo"]

	print("[global_manager] Producto agregado: %s (%s)" % [item_id, str(estado["tamanio_activo"])])
	_recalcular()


## Retira un producto del pedido.
func _on_item_removed(item_id: String) -> void:
	var pedido: Dictionary = estado["pedido"]
	if not pedido.has(item_id):
		return

	pedido.erase(item_id)
	print("[global_manager] Producto retirado: " + item_id)
	_recalcular()


## Valida el pedido armado contra lo que pidió el cliente en turno.
## Es la regla central de la mecánica: la interfaz solo recibe el resultado.
func _on_order_delivered() -> void:
	var pedido: Dictionary = estado["pedido"]
	var cliente: Dictionary = CLIENTES[estado["cliente_actual"]]

	if pedido.is_empty():
		EventBus.delivery_result.emit(false, "El pedido está vacío.")
		return

	# Dos diccionarios son iguales si tienen las mismas claves y valores:
	# mismos productos y mismos tamaños.
	if pedido != cliente["pide"]:
		print("[global_manager] Entrega rechazada para " + str(cliente["nombre"]))
		EventBus.delivery_result.emit(false, "Eso no es lo que pidió %s. Revisa productos y tamaños." % cliente["nombre"])
		return

	var pagado: int = int(estado["total"])
	estado["ganancias"] = int(estado["ganancias"]) + pagado
	estado["atendidos"] = int(estado["atendidos"]) + 1
	estado["cliente_actual"] = (int(estado["cliente_actual"]) + 1) % CLIENTES.size()
	pedido.clear()

	print("[global_manager] Entrega correcta. Atendidos: %d" % int(estado["atendidos"]))
	EventBus.delivery_result.emit(true, "¡Pedido correcto! %s pagó $%d." % [cliente["nombre"], pagado])
	_recalcular()
	EventBus.customer_changed.emit(obtener_cliente())


# --- Cálculo centralizado ---------------------------------------------------

## Precio de un producto con el recargo de su tamaño.
func _precio_de(item_id: String, tamanio: String) -> int:
	return int(CATALOGO[item_id]["precio"]) + int(RECARGO_TAMANIO[tamanio])


## Suma el pedido y notifica el estado al sistema completo.
func _recalcular() -> void:
	var total: int = 0
	var pedido: Dictionary = estado["pedido"]

	for item_id: String in pedido.keys():
		total += _precio_de(item_id, str(pedido[item_id]))

	estado["total"] = total

	EventBus.total_changed.emit(total)
	EventBus.order_updated.emit(obtener_resumen())


## Construye el resumen legible del pedido vigente.
## Devuelve: { item_id: { nombre, tamanio, precio } }
func obtener_resumen() -> Dictionary:
	var resumen: Dictionary = {}
	var pedido: Dictionary = estado["pedido"]

	for item_id: String in pedido.keys():
		var tamanio: String = str(pedido[item_id])
		resumen[item_id] = {
			"nombre": CATALOGO[item_id]["nombre"],
			"tamanio": NOMBRES_TAMANIO[tamanio],
			"precio": _precio_de(item_id, tamanio)
		}

	return resumen


## Construye el resumen del cliente en turno.
## Devuelve: { nombre, descripcion, atendidos, ganancias }
func obtener_cliente() -> Dictionary:
	var cliente: Dictionary = CLIENTES[estado["cliente_actual"]]
	var partes: Array[String] = []
	var pide: Dictionary = cliente["pide"]

	for item_id: String in pide.keys():
		partes.append("%s (%s)" % [CATALOGO[item_id]["nombre"], NOMBRES_TAMANIO[pide[item_id]]])

	return {
		"nombre": cliente["nombre"],
		"descripcion": ", ".join(partes),
		"atendidos": int(estado["atendidos"]),
		"ganancias": int(estado["ganancias"])
	}


## Reemite el estado vigente. La invoca `MainApp` al montar un panel nuevo, de
## forma que la interfaz entrante se sincronice sin consultar a este nodo.
func emitir_estado_actual() -> void:
	EventBus.total_changed.emit(int(estado["total"]))
	EventBus.order_updated.emit(obtener_resumen())
	EventBus.customer_changed.emit(obtener_cliente())
