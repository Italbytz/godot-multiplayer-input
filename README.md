# Godot Multiplayer Input (`godot-multiplayer-input`)

> **Godot 4 Addon for Local Multiplayer & Controller Management**  
> **Organization:** [Italbytz](https://github.com/Italbytz)  
> **Compatibility:** Godot Engine 4.x (GDScript)

---

## 🚀 Übersicht

`MultiplayerInput` ist ein wiederverwendbares Godot 4 Addon zur standardisierten Verwaltung von 1 bis 4 lokalen Spielern über Gamepads und geteilte Tastaturlayouts.

### Hauptmerkmale:
- **Automatische Slot-Zuordnung (P1..P4):**
  - Erkennt angeschlossene Gamepads (`Input.get_connected_joypads()`) und weist sie chronologisch zu (Device 0 $\to$ P1, Device 1 $\to$ P2, etc.).
  - Fehlende Gamepads werden automatisch durch geteilte Tastaturschemata ergänzt:
    - **P1:** `WASD` + `Space` / `E` / `Q`
    - **P2:** `Pfeiltasten` + `Enter` / `Shift`
    - **P3:** `IJKL` + `U` / `O`
- **Controller-Hotplugging:** Reagiert nahtlos auf das Ein- und Ausstecken von Gamepads zur Laufzeit (`joy_connection_changed`).
- **Deadzone-Filterung & D-Pad-Synthese:** Glättet unpräzise Analogsticks und schaltet automatisch auf das Steuerkreuz (D-Pad) um, falls der Stick in Neutralstellung verharrt.
- **Genre-Agnostische Aktions-Aliase:** Ermöglicht das Abfragen semantischer Aktionen (`"primary"` / `"jump"` / `"fire"` / `"gas"` oder `"secondary"` / `"nitro"` / `"bomb"`), ohne projektspezifische InputMaps duplizieren zu müssen.

---

## 📦 Installation & Einbindung

### Option 1: Als Submodul in dein Godot-Projekt
```bash
git submodule add https://github.com/Italbytz/godot-multiplayer-input.git addons/multiplayer_input
```

### Option 2: Als Autoload aktivieren
In `Project Settings -> Autoload`:
- Pfad: `res://addons/multiplayer_input/multiplayer_input_manager.gd`
- Name: `MultiplayerInput`

---

## 🕹️ Verwendung im Spielcode

```gdscript
extends CharacterBody2D

@export var player_index: int = 0 # 0 = P1, 1 = P2, ...

func _physics_process(delta: float) -> void:
    # 1. Analoger Richtungsvektor (-1.0 bis +1.0)
    var move_dir = MultiplayerInput.get_move_vector(player_index)
    velocity = move_dir * SPEED
    move_and_slide()
    
    # 2. Standard-Aktionen abfragen
    if MultiplayerInput.is_action_just_pressed(player_index, "primary"):
        jump()
        
    if MultiplayerInput.is_action_just_pressed(player_index, "secondary"):
        use_nitro_or_bomb()
```

---

## 🧪 CI/CD & Headless Testing

Das Addon verfügt über eine eigenständige Testsuite:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless -s test_addon.gd
```

---

## 📄 Lizenz

MIT License – Copyright (c) 2026 [Italbytz](https://github.com/Italbytz)

