extends Node

## Solicitud de navegación. La emiten las instancias de `ButtonNav`; la escucha
## exclusivamente `main_app.gd`. `discard_previous` indica si la pantalla
## saliente debe retirarse de la pila de historial (caso de los regresos).
signal navigation_requested(target_scene: String, discard_previous: bool)

## Intención de fijar el tamaño base de la bebida (pequeño, mediano o grande).
signal base_selected(base_name: String)

## Intención de añadir un producto al pedido con el tamaño vigente.
signal item_added(item_id: String)

## Intención de retirar un producto del pedido.
signal item_removed(item_id: String)

## Notificación del nuevo total del pedido, calculado por `GlobalManager`.
## La GUI lo muestra sin saber cómo se obtuvo.
signal total_changed(new_total: int)

## Notificación del pedido completo vigente.
signal order_updated(order: Dictionary)

# --- Señales de la mecánica de atención (Actividad 5) -----------------------

## Intención de entregar el pedido armado al cliente en turno.
signal order_delivered()

## Notificación del cliente en turno: { nombre, descripcion, atendidos }.
signal customer_changed(customer: Dictionary)

## Resultado de la entrega, validado por `GlobalManager`.
signal delivery_result(success: bool, message: String)

# --- Catálogo único de rutas de escena --------------------------------------
# Las instancias de ButtonNav resuelven su destino desde el Inspector; estas
# constantes las usa `MainApp` para el arranque del sistema.

const RUTA_MENU: String = "res://src/scenes/main/menu_panel.tscn"
const RUTA_MOSTRADOR: String = "res://src/scenes/simulation/step_1_base.tscn"
const RUTA_PEDIDO: String = "res://src/scenes/order/order_panel.tscn"
const RUTA_CONFIG: String = "res://src/scenes/config/config_panel.tscn"
const RUTA_CREDITOS: String = "res://src/scenes/credits/credits_panel.tscn"


func _ready() -> void:
	print("[event_bus] Canal global de eventos inicializado (Autoload activo).")
