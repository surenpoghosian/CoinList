# Cryptocurrency Listing

An iOS application built using UIKit that displays a list of cryptocurrencies with essential features like caching, search, infinite scroll, refresh control, and API requests.

## Features

- **Cryptocurrency Listing**: Fetches and displays a list of cryptocurrencies from an API.
- **Search Functionality**: Allows users to search for specific cryptocurrencies within the list.
- **Caching**: The app caches data to provide offline functionality and faster loading.
- **Infinite Scroll**: As the user scrolls, more cryptocurrencies are loaded dynamically.
- **Pull-to-Refresh**: Users can pull down to refresh the cryptocurrency list manually.
- **API Integration**: Fetches real-time data from a cryptocurrency API.

## Screenshots

*(Add screenshots of your app here)*

## Requirements

- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/surenpoghosian/CoinList
   ```

2. Open the project in Xcode:
   ```bash
   cd CoinList
   open CoinList.xcodeproj
   ```

3. Install dependencies (if any).

4. Build and run the project in Xcode.

## API Integration

The app fetches data from a cryptocurrency API (e.g., [awesome-list-rpc-nodes-providers](https://github.com/arddluma/awesome-list-rpc-nodes-providers) or any other API of your choice). Ensure to configure your API key if needed.

## How It Works

- **Caching**: The app stores the fetched cryptocurrency data locally to reduce API requests and enable offline access.
- **Search**: Users can search through the cryptocurrency list using a search bar.
- **Infinite Scroll**: As the user scrolls down, more data is fetched and appended to the list.
- **Pull-to-Refresh**: The list can be refreshed by pulling down from the top, triggering a new API request.
