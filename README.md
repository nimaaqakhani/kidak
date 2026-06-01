
# 🌡️ Flutter BLE Thermometer Dashboard

A modern, production-ready application developed with **Flutter** to scan, connect, and monitor real-time temperature data from hardware gadgets using the **Bluetooth Low Energy (BLE)** protocol. This project features a highly optimized structure built on **Clean Architecture principles**, **SOLID core design**, and managed via the **BLoC (Business Logic Component)** pattern.

---

## ✨ Features

* **Smart BLE Scanning:** Automated background scanning of nearby Bluetooth devices with intelligent loading states and real-time list updates.
* **BLoC State Management:** Absolute decoupling of the business logic layer from the user interface presentation layer.
* **SOLID Clean Architecture:** Strict adherence to the Single Responsibility Principle (SRP) by breaking down a massive screen into highly isolated, maintainable widgets.
* **Modern Dark UI:** Sleek, production-ready interface boasting dynamic gradients, glowing neon accents, and immersive visual haptics.
* **Graceful Error Handling:** Proactive management of core hardware states (e.g., Bluetooth radio turned off) matched with interactive retry views.

---

## 🛠️ Tech Stack

| Technology / Library | Role in Project |
| :--- | :--- |
| **Flutter SDK** | Multi-platform framework for native UI rendering |
| **Flutter BLoC** | Reactive state management and event-driven architecture |
| **FlutterBluePlus** | Low-level hardware abstraction layer for BLE communication |
| **Dart** | Object-oriented, strongly-typed primary programming language |

---

## 📐 Clean Architecture & SOLID Blueprint

The project is structured according to **Clean Architecture** to separate concerns, enforce testability, and decouple external hardware frameworks from the core UI.

```text
 ┌────────────────────────────────────────────────────────────────────────┐
 │                           PRESENTATION LAYER                           │
 │                                                                        │
 │   [UI Shell]                                                           │
 │   └── TemperatureScreen (Stateful Orchestrator & Lifecycle Manager)    │
 │                                                                        │
 │   [Atomic SOLID Widgets]                                               │
 │   ├── ScanListView        ──► (SRP: Dedicated to Device Discovery)     │
 │   ├── DashboardView       ──► (SRP: Dedicated to Gauge & Disconnect)   │
 │   └── StatusViews         ──► (SRP: Dedicated to Loading/Error UI)     │
 └───────────────────────────────────┬────────────────────────────────────┘
                                     │
                    Listens to States / Dispatches Events
                                     ▼
 ┌────────────────────────────────────────────────────────────────────────┐
 │                              DOMAIN LAYER                              │
 │                                                                        │
 │   [Business Logic Component]                                           │
 │   └── TemperatureBloc     ──► (Processes logic, transitions states)    │
 │                                                                        │
 │   [Contracts & Models]                                                 │
 │   ├── TemperatureEvents   ──► (User Intents: Connect, Disconnect)      │
 │   └── TemperatureStates   ──► (UI Blueprints: Reading, Error, Loading) │
 └───────────────────────────────────┬────────────────────────────────────┘
                                     │
                         Interacts via Streams/APIs
                                     ▼
 ┌────────────────────────────────────────────────────────────────────────┐
 │                               DATA LAYER                               │
 │                                                                        │
 │   [Hardware & External Drivers]                                        │
 │   └── FlutterBluePlus Framework ──► (Low-level Core BLE Bluetooth API) │
 └────────────────────────────────────────────────────────────────────────┘
```

### Unidirectional Data Flow (Reactive Loop):
1. **User Action:** User interacts with `ScanListView` and triggers a connection request.
2. **Event Trigger:** `ScanListView` emits a callback up to the Shell, which fires `ConnectGadgetEvent()` into the `TemperatureBloc`.
3. **Business Logic Evaluation:** `TemperatureBloc` talks to the **Data Layer** (`FlutterBluePlus`), safely stops the active scan, hooks onto the hardware stream, and mutates state.
4. **Targeted UI Update:** `BlocBuilder` receives `TemperatureConnected` or `TemperatureReading` and updates **only** the `DashboardView` without repainting the entire viewport tree.

---

## 📂 Project Structure

The structure maps perfectly to our architectural layers, keeping features encapsulated and intuitive:

```text
lib/
│
├── bloc/                           # ──► [DOMAIN/LOGIC LAYER]
│   ├── temperature_bloc.dart       # Coordinates BLE streams & maps events
│   ├── temperature_event.dart      # Strict definitions of user interactions
│   └── temperature_state.dart      # Finite state machines powering the UI
│
└── screens/                        # ──► [PRESENTATION LAYER]
    ├── temperature_screen.dart     # Parent orchestrator holding the BlocBuilder
    └── widgets/                    # Sub-components isolated by Single Responsibility
        ├── dashboard_view.dart     # Renders the isolated circular temperature monitor
        ├── scan_list_view.dart     # Handles device discovery layouts and triggers
        └── status_views.dart       # Lightweight widgets for Loading & Error feedback
```

---

## 🧩 Architectural Refactoring Benefits

* **Single Responsibility Principle (SRP):** The monolithic view has been split into dedicated standalone atomic components. Changing the visual aspect of the circular gauge or changing the layout of the BLE card happens independently in their own files without compromising other UI nodes.
* **Aggressive Rendering Optimization:** By refactoring visual blocks into independent `StatelessWidgets`, Flutter optimizes its internal layout element tree. When the temperature telemetry fluctuates rapidly via BLE, **only** the micro-nodes inside `DashboardView` undergo repainting. This lowers background CPU processing and heavily extends the mobile device's battery life.
* **Decoupled Business Rules:** The UI layer remains oblivious to how Bluetooth devices handshake or pipe bytes; it only acts as a reactive reflection of the emitted BLoC states.

---

## 🚀 Getting Started

Follow these steps to build and spin up the project locally:

**1. Clone the repository:**
```bash
git clone [https://github.com/nimaaqakhani/kidak.git](https://github.com/nimaaqakhani/kidak.git)
cd kidak
```

**2. Fetch Flutter dependencies:**
```bash
flutter pub get
```

**3. Run the application:**
```bash
flutter run
```
چ