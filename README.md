# Consent IQ - Clinical Trial Consent Management System

A responsive Flutter.js application for managing user consent in clinical trials with role-based access control (RBAC).

## Project Overview

Consent IQ is designed to manage the complex workflow of clinical trials with four distinct user roles, each with specific responsibilities:

1. **Administrators** - System-level management
2. **Clinical Study Sponsors** - Study creation and management
3. **Research Centers** - Participant and trial management
4. **Participants** - Consent provision

## Key Features

- **Role-Based Access Control (RBAC)** - Four distinct user roles with specific permissions
- **Clinical Study Management** - Create and manage studies with protocol documents
- **Research Center Management** - Organize and manage trial locations
- **Participant Management** - Track and manage study participants
- **Consent Workflow** - Streamlined consent process for participants
- **Responsive UI** - Built with Flutter.js for cross-platform compatibility

## Project Structure

```
consent-iq/
├── public/              # Static assets
├── src/
│   ├── components/      # Reusable Flutter components
│   ├── pages/           # Page components
│   ├── services/        # Business logic and API services
│   ├── store/           # RBAC policies and state management
│   ├── utils/           # Utility functions
│   └── App.dart         # Main application component
├── pubspec.yaml         # Flutter dependencies
└── package.json         # Node.js dependencies
```

## Setup Instructions

1. Install dependencies:
   ```bash
   npm install
   flutter pub get
   ```

2. Run the development server:
   ```bash
   npm run dev
   ```

3. Build for production:
   ```bash
   npm run build
   ```

## Documentation

- [RBAC Policy Guide](docs/RBAC_POLICY.md)
- [API Documentation](docs/API.md)
- [Component Library](docs/COMPONENTS.md)
