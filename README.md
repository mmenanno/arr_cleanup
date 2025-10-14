# Arr Cleanup

A modern Rails application for managing and monitoring your Radarr (movies) and Sonarr (TV shows) media libraries. Identify large files, REMUX quality items, and optimize your storage usage with a beautiful, responsive interface.

## Features

### 🎬 Movie Management

- Sync with Radarr to import your entire movie library
- View all movies with sorting (Size, Title, Year, Ignored) and filtering
- Identify REMUX quality movies that can be replaced with smaller versions
- Ignore movies you want to keep as-is
- Real-time sync progress with live updates
- Refresh individual movies from Radarr

### 📺 TV Show Management

- Sync with Sonarr to import all your TV shows
- Browse shows with detailed season and episode information
- Filter by REMUX content
- Sort by size, title, year, or ignored status
- Drill down to individual seasons and episodes
- Track which shows contain REMUX episodes

### 📊 Dashboard

- Real-time sync status with live progress updates
- Library statistics (total movies, shows, storage)
- Quick access to largest movies and shows
- Color-coded gradients for visual organization
- Toggle to include/exclude ignored items in statistics

### ⚙️ Smart Features

- **Live Sync Updates**: Watch real-time progress as your library syncs
- **REMUX Detection**: Automatically identifies high-bitrate REMUX files
- **Ignore System**: Mark items you want to exclude from cleanup
- **Search**: Find specific movies or shows quickly
- **Filtering**: REMUX-only filter, ignored items toggle
- **Sorting**: Multiple sort options with ascending/descending control
- **Responsive Design**: Modern, gradient-based UI that works on all devices

## Tech Stack

- **Ruby on Rails 8.0** - Modern Rails with all the latest features
- **Hotwire (Turbo + Stimulus)** - Real-time updates without JavaScript frameworks
- **Tailwind CSS** - Utility-first styling with custom gradients
- **Solid Queue** - Background job processing
- **Solid Cable** - WebSocket connections for live updates
- **SQLite** - Simple, fast database
- **Pagy** - Efficient pagination

## Setup

### Prerequisites

- Ruby 3.4.5+
- Node.js (for JavaScript bundling)
- Radarr instance with API access
- Sonarr instance with API access

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd arr_cleanup

# Install dependencies
bundle install

# Setup database
bin/rails db:setup

# Start the development server
bin/dev
```

The app will be available at `http://localhost:3000`

### Configuration

1. Navigate to Settings
2. Enter your Radarr URL and API key
3. Enter your Sonarr URL and API key
4. Test connections to verify setup
5. Save settings

### Initial Sync

1. Go to Movies page and click "Sync All"
2. Go to Shows page and click "Sync All"
3. Watch real-time progress on the Dashboard

## Usage

### Finding Large REMUX Files

1. Use the REMUX filter toggle on Movies or Shows pages
2. Sort by Size (descending) to see largest first
3. Review REMUX items for potential optimization
4. Ignore items you want to keep

### Managing Ignored Items

1. Toggle "Show ignored" to view ignored items
2. Sort by "Ignored" to see all ignored items first
3. Click "Unignore" to remove from ignore list
4. Use filters to hide ignored items from view

### Monitoring Syncs

- Dashboard shows live sync progress
- Spinner indicates active syncing
- Progress bar shows completion percentage
- Updates every 5 items for smooth performance

## Development

### Running the App

```bash
# Start all services (web, CSS, background jobs)
bin/dev
```

### Running Tests

```bash
bin/rails test
```

### Database Tasks

```bash
# Clear all sync statuses
bin/rails sync:clear_status

# Clear cable messages
bin/rails cable:clear
```

## Architecture

### Real-Time Updates

The app uses Hotwire (Turbo Streams + Action Cable) for real-time updates:

- **Solid Cable** adapter in development/production for cross-process broadcasting
- **Turbo Streams** for granular DOM updates
- **Stimulus controllers** for interactive UI components

### Background Jobs

- **Solid Queue** processes sync jobs in the background
- Jobs update progress every 5 items for smooth UI updates
- Automatic retry with polynomial backoff on errors

### Design System

**Color Coding:**

- **Indigo/Blue** - Movies and Radarr
- **Purple** - Shows and Sonarr
- **Yellow/Orange** - Storage and system info
- **Red** - REMUX warnings
- **Green** - Success and standard quality

**Gradients:**

- Subtle 5-10% opacity gradients throughout
- Color-coded by service for instant recognition
- Modern, polished aesthetic

## API Integration

### Radarr

- Fetches all movies via `/api/v3/movie`
- Gets movie details and file information
- Detects REMUX quality files

### Sonarr

- Fetches all series via `/api/v3/series`
- Gets episodes via `/api/v3/episode`
- Gets episode files via `/api/v3/episodefile`
- Maps episodes to files for complete information

## License

This project is open source and available under the MIT License.

## Credits

Built with ❤️ using Ruby on Rails, Hotwire, and Tailwind CSS.
