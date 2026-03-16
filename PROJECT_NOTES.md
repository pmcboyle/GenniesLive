# Gennies Live - Project Notes for Next Agent

## What This Is
A Flutter Progressive Web App (PWA) for Washington & Lee University's "Generals" athletics program. It displays sporting event schedules, facility operations hours, varsity sports info, workout class schedules, and club sport sign-ups — modeled after a Big 10 recreation center portal (inspired by JMU's UREC site).

Reference site for branding/data: https://generalssports.com/

---

## Project Location
`~/Desktop/gennieslive/`

---

## Flutter Setup
- Flutter SDK is installed at: `~/Desktop/flutter/`
- **Always use the explicit path** — PATH export doesn't always persist in Claude sessions:
  ```bash
  ~/Desktop/flutter/bin/flutter <command>
  ```
- Web support is enabled: `flutter config --enable-web`
- Flutter version: 3.41.1 (stable channel, Feb 2026)

## How to Run the App
```bash
# Kill any existing instance on port 8080 first
lsof -ti :8080 | xargs kill -9 2>/dev/null
sleep 1
cd ~/Desktop/gennieslive && ~/Desktop/flutter/bin/flutter run -d chrome --web-port=8080
```
Opens at http://localhost:8080

Run in background with `run_in_background: true` so Claude doesn't block.

## How to Check for Errors
```bash
cd ~/Desktop/gennieslive && ~/Desktop/flutter/bin/flutter analyze
```

## How to Build for Production
```bash
cd ~/Desktop/gennieslive && ~/Desktop/flutter/bin/flutter build web --release
# Output: build/web/
```

---

## Project Structure
```
gennieslive/
├── lib/
│   ├── main.dart                  # ALL UI code lives here (home page + 4 section pages)
│   ├── models/
│   │   └── sporting_event.dart    # SportingEvent data model
│   └── data/
│       └── events_data.dart       # Static schedule data from generalssports.com
├── web/
│   ├── manifest.json              # PWA manifest (name: "Gennies Live", theme: #000399)
│   ├── index.html                 # PWA HTML shell
│   └── icons/                    # App icons (192x192, 512x512)
└── pubspec.yaml
```

---

## App Architecture — CURRENT STATE

The app uses **Navigator-based routing** (NOT tabs). There is a home landing page with navigation cards, and each section is a separate full page pushed onto the stack.

### Pages in main.dart:

| Class | Route | Description |
|---|---|---|
| `HomePage` | `/` (root) | Landing page with hero banner + 4 nav cards + "Next Up" events preview |
| `WorkoutClassesPage` | pushed | Weekly fitness class schedule from IMLeagues calendar |
| `FacilityHoursPage` | pushed | Operating hours for W&L facilities |
| `VarsitySportsPage` | pushed | Upcoming games + sports by category (expandable) |
| `ClubSportsPage` | pushed | List of club sports with Sign Up dialog |

### Home Page Layout:
- **Hero banner** — dark blue gradient, Generals trident logo (watermark + title logo), "GENNIES LIVE" title, "Washington & Lee University Athletics" subtitle
- **EXPLORE section** — 4 tappable `_NavCard` widgets stacked vertically
- **NEXT UP section** — 2 upcoming sporting events preview cards

### Key Helper Classes:
- `_NavCard` — reusable dark blue tappable card with icon, title, description, chevron
- `_UpcomingEventTile` — compact event card for home page preview
- `_SectionHeader` — dark blue full-width section divider (used in VarsitySportsPage)
- `_HoursCard` — facility hours list tile
- `_EventCard` — full event card with Home/Away chip
- `_SportCard` — expandable sport card showing up to 5 games
- `_sportIcon()` — top-level function mapping sport name → IconData

---

## Branding
- **Primary color**: `Color(0xFF000399)` — dark Generals blue
- **Theme**: Material 3, dark blue AppBar
- **Logo**: Generals trident PNG from CDN:
  `https://dxbhsrqyrr690.cloudfront.net/sidearm.nextgen.sites/generalssports.com/images/logos/site/site.png`
  - Used as white-tinted watermark in hero background
  - Used as white logo next to app title in collapsed AppBar
- **Note**: generalssports.com is a JS-rendered SPA — action photos cannot be scraped. User must manually copy image URLs from the browser if they want specific photos.

---

## Data Layer

### Varsity Sports (`lib/data/events_data.dart`)
- All schedule data is **static/hardcoded**
- Manually extracted from generalssports.com schedule pages
- Sports included: Football, Men's Basketball, Women's Basketball, Men's Swimming & Diving, Women's Swimming & Diving, Wrestling, Baseball, Men's Lacrosse, Women's Lacrosse

**Key EventsData methods:**
- `EventsData.getAllEvents()` — all events
- `EventsData.getUpcomingEvents()` — events after today, sorted by date
- `EventsData.getAllSports()` — unique list of sport names
- `EventsData.getEventsBySport(sport)` — events filtered by sport name

### SportingEvent Model (`lib/models/sporting_event.dart`)
Fields: `sport`, `opponent`, `dateTime`, `location`, `isHome`, `result?`
Computed: `formattedDate`, `formattedTime`, `homeAwayText`

### Workout Classes (`WorkoutClassesPage._schedule`)
- Static const list inside `WorkoutClassesPage`
- Extracted from IMLeagues calendar screenshot (February 2026)
- Days: Sun–Sat with classes: Morning Open Swim, Yoga, TRX, Spin, Pilates, Open Dancing, Tone45, Open Swim

### Club Sports (`ClubSportsPage._clubs`)
- Static const list inside `ClubSportsPage`
- 12 clubs: Ultimate Frisbee, Rugby, Club Soccer, Crew/Rowing, Volleyball, Cycling, Rock Climbing, Equestrian, Skiing, Tennis, Golf, Pickleball
- Sign Up button opens dialog → collects name + W&L email → shows SnackBar confirmation (no backend yet)

### Facility Hours (`FacilityHoursPage`)
- Hardcoded in `_HoursCard` widgets
- Facilities: Warner Center, Natatorium, Fitness Center, Outdoor Track, Wilson Field
- **Note**: These are estimated hours — not verified against official W&L rec center hours

---

## What's Done ✅
- Flutter PWA project created and running
- PWA manifest configured (name, theme color, icons)
- Home landing page with hero banner and navigation cards (JMU-style)
- Generals trident logo in hero banner (from CDN)
- Workout Classes page with weekly schedule from IMLeagues
- Facility Hours page
- Varsity Sports page (upcoming events + sports by category)
- Club Sports page with sign-up dialog
- Real varsity schedule data for 9 sports from generalssports.com
- `flutter analyze` returns 0 issues

## What Still Needs to Be Done 📋
- [ ] Verify/update facility hours with real W&L rec center data
- [ ] Add remaining varsity sports (tennis, track & field, cross country, soccer, field hockey, volleyball, golf)
- [ ] Add game results/scores for completed games
- [ ] Search/filter on Varsity Sports events
- [ ] "Today's Classes" highlight on home page
- [ ] Wire up Club Sports sign-up to a real backend (email, Google Form, or API)
- [ ] Add real action photos (user must provide URLs from generalssports.com browser)
- [ ] Deploy to hosting (GitHub Pages, Firebase Hosting, or Netlify)
- [ ] Add PWA push notifications for upcoming events
- [ ] Add varsity facility block scheduling (original requirement — not yet built)
- [ ] More PWA icons / splash screens for iOS/Android install experience

---

## Known Issues / Environment Notes
- `~/.config` was originally owned by root — user fixed with `sudo chown -R paigemcboyle ~/.config`
- `meta` package has a newer version but incompatible with current constraints — not blocking
- Hot reload doesn't work via Claude (no terminal stdin access) — must kill and restart process
- Exit code 137 on background tasks = intentional kill (normal), not an error
- Always use `~/Desktop/flutter/bin/flutter` not just `flutter` — PATH may not be set
- Port 8080 may already be in use — always run `lsof -ti :8080 | xargs kill -9` before launching
