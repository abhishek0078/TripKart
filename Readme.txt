# TripKart

> **A Plugin-Based Travel Booking Platform built with SwiftUI, Swift 6, and Clean Architecture**

---

# 📖 Overview

TripKart is an enterprise-level iOS travel booking platform built using a **Plugin-Based Travel Engine**.

Unlike traditional travel apps where Bus, Flight, Train, and Hotel are implemented as separate features, TripKart is designed around reusable business engines and configurable plugins.

The goal of this project is to demonstrate modern iOS architecture, clean code practices, scalable design patterns, and AI-assisted development.

Current plugins:

* 🚌 Bus
* ✈️ Flight

Future plugins:

* 🚆 Train
* 🏨 Hotel
* 🚖 Cab
* 🚢 Cruise
* ⛴ Ferry
* 🎫 Holiday Packages

The application is designed so that new travel services can be added with minimal changes to the core architecture.

---

# 🚀 Tech Stack

### Language

* Swift 6

### UI Framework

* SwiftUI

### Architecture

* Plugin-Based Travel Engine
* MVVM
* Clean Architecture
* Repository Pattern
* Dependency Injection
* NavigationStack + Coordinator Pattern

### Persistence

* SwiftData
* UserDefaults (Preferences only)

### Concurrency

* Async/Await

### Testing

* Swift Testing
* XCTest

---

# 📁 Project Structure

```
TripKart

├── App
├── Core
├── Domain
├── Data
├── Plugins
├── Features
├── Shared
├── DesignSystem
├── UIFramework
├── Resources
├── Tests
├── docs
└── README.md
```

---

# 📚 Documentation

All project documentation lives inside the **docs/** folder.

```
docs/

├── Volume1_PRD.md
├── Volume2_SoftwareArchitecture.md
├── Volume3_DesignSystem.md
├── Volume4_AIDevelopmentPlaybook.md
├── Volume5_DataArchitecture.md
└── Volume6_ProjectRoadmap.md
```

---

# 📖 Documentation Reading Order

Every developer and AI coding assistant should read the documents in the following order before implementing any feature.

| Order | Document | Purpose                 |
| ----- | -------- | ----------------------- |
| 1     | Volume 1 | Product Requirements    |
| 2     | Volume 2 | Software Architecture   |
| 3     | Volume 3 | Design System           |
| 4     | Volume 4 | AI Development Playbook |
| 5     | Volume 5 | Data Architecture       |
| 6     | Volume 6 | Development Roadmap     |

---

# 🤖 Instructions for AI Coding Assistants

Before generating any code, always read the documentation in the **docs/** directory.

The documentation is the single source of truth.

Never make architectural assumptions.

If there is any conflict between generated code and documentation, **the documentation always wins.**

---

# 🏗 Architecture Overview

```
TripKart

        Plugin Engine

              │

     ┌────────┼─────────┐

     │                  │

 Bus Plugin       Flight Plugin

     │                  │

     └────────┼─────────┘

              │

     Shared Business Engines

              │

 Search Engine

 Booking Engine

 Ticket Engine

 Payment Engine

 Navigation Engine

 Analytics Engine

 Theme Engine

 Storage Engine

 Validation Engine
```

---

# 📦 Core Principles

TripKart follows these architectural principles:

* Plugin-Based Architecture
* Configuration-Driven UI
* Reusable Components
* Clean Architecture
* Single Responsibility Principle
* SOLID
* DRY
* Composition over Inheritance
* SwiftUI First
* Backend Ready

---

# 🎯 Project Goals

The project aims to:

* Demonstrate enterprise SwiftUI architecture
* Showcase scalable plugin-based design
* Minimize duplicated code
* Build reusable UI components
* Keep the application backend-ready
* Allow future travel plugins with minimal effort

---

# 🧩 Plugin Philosophy

TripKart is **NOT** a Bus Booking application.

TripKart is **NOT** a Flight Booking application.

TripKart is a **Travel Platform**.

Every travel service is implemented as a plugin.

Plugins provide only business-specific configuration.

Everything else is shared.

---

# 🛠 Shared Business Engines

The following engines power the application:

* Search Engine
* Booking Engine
* Ticket Engine
* Payment Engine
* Validation Engine
* Session Engine
* Theme Engine
* Analytics Engine
* Navigation Engine
* Cache Engine
* Storage Engine
* Notification Engine

These engines should never be duplicated.

---

# 🎨 Shared UI

The application is built entirely using reusable SwiftUI components.

Examples include:

* Dynamic Forms
* Dynamic Cards
* Bottom Sheets
* Buttons
* Search Fields
* Ticket Views
* Booking Summary
* Payment Components
* Empty States
* Error States
* Toasts
* Loaders

Every new screen should reuse existing components whenever possible.

---

# 📂 Plugin Responsibilities

Every plugin is responsible for providing:

* Search Configuration
* Result Configuration
* Detail Configuration
* Validation Rules
* Fare Rules
* Ticket Metadata
* Analytics Metadata

Plugins do **NOT** handle:

* Navigation
* Payments
* Booking
* Ticket Generation
* Storage

---

# 🚫 Architectural Rules

The following rules are mandatory.

## Always

* Reuse existing components
* Use Dependency Injection
* Use Repository Pattern
* Use Async/Await
* Use ThemeManager
* Use Design Tokens
* Follow MVVM
* Keep Views declarative
* Keep business logic in ViewModels and UseCases
* Prefer composition over inheritance

---

## Never

* Duplicate screens
* Duplicate ViewModels
* Hardcode colors
* Hardcode spacing
* Perform business logic inside Views
* Perform navigation inside Views
* Instantiate repositories directly
* Access persistence directly from UI
* Create plugin-specific UI if a shared component can be configured

---

# 🧱 Feature Development Workflow

Every feature should follow this lifecycle.

```
Planning

↓

Requirements

↓

Design

↓

Architecture

↓

Data Models

↓

ViewModel

↓

Views

↓

Testing

↓

Review

↓

Merge
```

Never skip architecture.

---

# 📋 Definition of Done

A feature is complete only when:

* Architecture rules are followed
* Existing components are reused
* UI supports Light/Dark Mode
* Accessibility is implemented
* Loading states exist
* Error states exist
* Empty states exist
* SwiftUI Preview is available
* Unit tests pass
* Documentation is updated if needed

---

# 📅 Current Development Order

Development should follow this sequence:

1. Foundation
2. Design System
3. UI Framework
4. Core Engines
5. Plugin Engine
6. Authentication
7. Home
8. Search
9. Results
10. Booking
11. Payment
12. Ticket
13. Profile
14. Offers
15. Notifications
16. Settings
17. Offline Support
18. Testing
19. Optimization

---

# 🧪 Dummy Data

The application currently uses local JSON files.

Future migration to REST APIs should require changes **only** in the Repository layer.

The UI and business logic should remain unchanged.

---

# 🔮 Future Roadmap

Planned enhancements include:

* Train Booking
* Hotel Booking
* Cab Booking
* Cruise Booking
* Live APIs
* Real Payment Gateway
* Push Notifications
* AI Travel Assistant
* Dynamic Pricing
* Personalized Recommendations

---

# 🤝 Contributing Guidelines

Before implementing any feature:

1. Read the relevant documentation in **docs/**.
2. Search for an existing reusable component.
3. Reuse before creating.
4. Keep Views simple and declarative.
5. Follow the architecture.
6. Add SwiftUI previews.
7. Add tests for business logic.
8. Update documentation if the architecture changes.

---

# 📌 Final Notes for AI

This repository is designed to be developed collaboratively with AI coding assistants.

Every implementation should prioritize:

* Scalability
* Reusability
* Maintainability
* Testability
* Readability

When in doubt:

1. Read the documentation.
2. Prefer configuration over duplication.
3. Extend the architecture rather than bypassing it.

The objective is not only to build a travel booking application, but to create a reusable, enterprise-grade travel platform that can continue to evolve without requiring architectural rewrites.

