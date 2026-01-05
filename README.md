# Code Vault

Code Vault is a Flutter application that turns your mobile device into a portable, local server for storing and managing code snippets. It allows you to save code snippets, descriptions, and media assets locally on your phone and access them via a REST API from other devices on your local network.

## Features

*   **Local Storage**: Securely store code snippets on your device using a local SQLite database.
*   **Embedded HTTP Server**: Runs a lightweight HTTP server (default port: 8765) directly on the phone.
*   **Remote Management**: Create, read, update, and delete snippets from other devices via API.
*   **Access Control**: Manages connected devices with an approval system to ensure unauthorized devices cannot access your vault.
*   **Media Support**: Attach images to your snippets.
*   **Theming**: Supports Light and Dark modes.

## Getting Started

### Prerequisites

*   Flutter SDK
*   Android/iOS device or emulator

### Installation

1.  Clone the repository.
2.  Run `flutter pub get` to install dependencies.
3.  Run the app on your device using `flutter run`.

## Usage

1.  **Start the Server**: Open the app. The server initializes automatically.
2.  **Connect a Client**: Use the displayed IP address to send requests to the API.
3.  **Grant Permissions**: When a new device attempts to connect, you will see a request in the app to approve or deny access.

## API Endpoints

*   `GET /status`: Check server status and device info.
*   `GET /api/snippets`: List all saved snippets.
*   `POST /api/snippets/create`: Create a new snippet.
*   `POST /api/snippets/update`: Update an existing snippet.
*   `POST /api/snippets/delete?id=<id>`: Delete a snippet.
*   `POST /api/media/upload`: Upload media attachments.

## Tech Stack

*   **Framework**: Flutter
*   **State Management**: Riverpod
*   **Server**: Shelf
*   **Database**: sqlite
