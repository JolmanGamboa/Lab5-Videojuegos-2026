# Cafetería Interactiva 2D

**Producción de Videojuegos (Sistemas Interactivos) 2026-2** · Universidad Antonio Nariño

Proyecto integrador desarrollado en Godot 4. El usuario atiende el mostrador de
una cafetería: selecciona productos, elige su tamaño y arma el pedido, que se
calcula de forma centralizada.

## Requisitos

| Componente | Versión / configuración |
| --- | --- |
| Godot Engine | 4.x Standard (sin .NET) |
| Renderizador | `Compatibility` |
| Lenguaje | GDScript 2.0 con tipado estático |

## Ejecución

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/JolmanGamboa/Lab5-Videojuegos-2026.git
   ```
2. Abrir Godot, pulsar **Import** y seleccionar `project.godot`.
3. Ejecutar con `F5`. La escena principal es `res://src/core/main_app.tscn`.

## Arquitectura

```
GUI ──intención──▶ EventBus ──▶ GlobalManager (único dueño del pedido)
                      │                 │
                      │                 └──▶ total_changed / order_updated ──▶ GUI
                      └──▶ MainApp (única autoridad sobre el árbol)
```

| Pantalla | Escena | Función |
| --- | --- | --- |
| Menú | `main/menu_panel.tscn` | Navega con `ButtonNav`; sale con `get_tree().quit()` |
| Mostrador | `simulation/step_1_base.tscn` | Selección de producto y tamaño |
| Pedido actual | `order/order_panel.tscn` | Lista dinámica del pedido; permite quitar productos |
| Configuración | `config/config_panel.tscn` | Parámetros del local; sin script |
| Créditos | `credits/credits_panel.tscn` | Datos del autor; sin script |

## Estructura

```
res://
├── doc/adr/                       # Decisiones de arquitectura
├── src/
│   ├── assets/ui/
│   ├── components/navigation/     # button_nav.tscn / .gd
│   ├── core/                      # event_bus, global_manager, main_app
│   └── scenes/
│       ├── main/                  # menu_panel
│       ├── simulation/            # step_1_base (mostrador)
│       ├── order/                 # order_panel
│       ├── config/
│       └── credits/
├── DEVLOG.md
├── README.md
└── project.godot
```

## Convenciones

Commits en *Conventional Commits* (`init`, `config`, `feat`, `refactor`,
`doc`, `chore`). Archivos y carpetas en `snake_case`.

## Autor

- **Nombre:** Jolman Harley Gamboa Salamanca
- **Código estudiantil:** 12242525509
- **Programa:** Ingeniería de Software
