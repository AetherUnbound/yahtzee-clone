# Copilot Instructions - Yahtzee Clone

## Build, Test, and Lint

### Frontend (Root)
```bash
npm run dev          # Start frontend dev server (port 5173)
npm run build        # Build for production (TypeScript check + Vite build)
npm run lint         # Run ESLint
npm run preview      # Preview production build
```

### Backend (Server)
```bash
cd server
npm run dev          # Start with nodemon (auto-restart)
npm start            # Start server (port 3001)
npm test             # Run test server
```

### Full Stack Development
1. Start backend: `cd server && npm run dev`
2. Start frontend: `npm run dev` (in root)
3. Backend runs on port 3001, frontend on 5173

## Architecture

### Dual Game Engine Design
This codebase implements **two completely separate game engines** for local and remote play:

- **Local Game Engine** (`src/game/LocalGameEngine.ts`)
  - In-memory only, zero backend dependencies
  - Implements the `GameEngine` interface
  - Used for 1-6 player local games

- **Remote Game Engine** (`server/game/RemoteGameEngine.js`)
  - Database-backed game state
  - Implements the `GameEngine` interface (JS version)
  - Used for online multiplayer with invite links

**Shared Game Logic**: Both engines use identical scoring and validation rules from `gameLogic.ts` (TS) and `gameLogic.js` (JS port). When modifying game rules, update both versions to maintain parity.

### Frontend-Backend Split
- **Frontend**: React 19 + TypeScript + Vite (in `src/`)
- **Backend**: Node.js + Express + SQLite (in `server/`)
- **Communication**: REST API with 1-second polling for game state sync
- **Type Safety**: TypeScript types in `src/types.ts`, JSDoc types in `server/types.js`

### Database Schema
SQLite with three tables:
- `games` - Game state as JSON blob
- `players` - Player names and indices per game
- `score_cards` - Individual category scores per player

**Important**: Player IDs in the database are auto-incremented integers, while frontend uses 0-based indices. Always map between these carefully.

## Key Conventions

### Game State Management
- Frontend polls backend every 1 second via `GET /api/games/:gameId`
- Only the active player can perform actions (enforced on both client and server)
- Game state persists across page refreshes (stored in database for remote games)
- Use `gameStarted` flag to differentiate setup vs. active gameplay

### Yahtzee Bonus & Joker Rules
Complex scoring priority when a subsequent Yahtzee is rolled (after first Yahtzee scored):
1. Score in upper section box matching dice value (if available)
2. Score in Three of a Kind or Four of a Kind (if available)
3. Score in other lower section categories (Full House, Straights, Chance)
4. Fallback to upper section (scored as zero if full)
Always awards 100 bonus points regardless of where it's scored.

### Score Calculation
- **Upper Section Bonus**: Automatically awarded when upper section total ≥ 63 (adds 35 points)
- **Yahtzee Bonus**: Track in `scoreCard.yahtzeeBonus` field (can accumulate multiple bonuses)
- **Total Score**: Sum of all categories + upper bonus + Yahtzee bonus

### Game Numbering
Remote games track `gameNumber` in state. When using "Play Again":
- Increment `gameNumber` in the new game state
- Preserve player names and order
- Reset all scores and game state

### API Error Handling
Backend returns structured errors:
```javascript
{ error: "Human-readable message", gameState: currentState }
```
Frontend displays these in a dismissible notification UI at the top of the screen.

### Development Test Features
Hidden keyboard shortcuts (preserved for debugging, not documented to users):
- Force all dice to 2s for Yahtzee testing
- Quick fill most categories for end-game testing
These are intentional and should not be removed.

## File Organization

```
src/
├── App.tsx                    # Main React component, all UI and state
├── types.ts                   # TypeScript type definitions (canonical)
├── game/
│   ├── GameEngine.ts          # Interface definition
│   ├── LocalGameEngine.ts     # In-memory game engine
│   ├── RemoteGameEngine.ts    # API client for remote games
│   └── gameLogic.ts           # Shared game rules (TypeScript)

server/
├── server.js                  # Express server, API endpoints
├── config.js                  # Server configuration (port, DB path)
├── database/
│   └── DatabaseManager.js     # SQLite operations, schema management
├── game/
│   ├── GameEngine.js          # Interface definition (JS)
│   ├── RemoteGameEngine.js    # Database-backed game engine
│   └── gameLogic.js           # Shared game rules (JavaScript port)
└── types.js                   # JSDoc type definitions
```

## Common Patterns

### Adding a New API Endpoint
1. Add route in `server/server.js`
2. Use try-catch with proper error responses
3. Call `RemoteGameEngine` methods (don't manipulate DB directly)
4. Add corresponding method in `src/game/RemoteGameEngine.ts` for frontend

### Modifying Game Rules
1. Update `src/game/gameLogic.ts` (TypeScript version)
2. Update `server/game/gameLogic.js` (JavaScript version)
3. Ensure both local and remote engines use the updated logic
4. Test in both local and remote modes

### UI State Updates
All UI state lives in `App.tsx` with React hooks. The component is large but intentionally monolithic for game state coherence. When adding features:
- Use `useCallback` for functions passed to child elements
- Keep local and remote game modes clearly separated in logic
- Update both the setup screen and the game screen as needed

## TypeScript & Linting

- **Strict mode disabled** - Uses relaxed TypeScript config
- **ESLint rules**: React Hooks rules enabled, React Refresh rules for HMR
- **No test runner** - No Jest/Vitest configured, manual testing only
- Fix lint errors before committing: `npm run lint`

## Database Maintenance

Automatic cleanup runs daily at midnight (local time) to remove games older than 7 days. Cleanup also runs on server startup.

Manual cleanup: `POST /api/games/cleanup`
