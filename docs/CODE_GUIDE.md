# Code guide

Start with the [README](../README.md) for the live demo and local setup.

## Repository map

| Location | Responsibility |
| --- | --- |
| `index.html` | Accessible app shell, navigation, forms, and shared dialogs. |
| `src/js/app.js` | Browser controller: view rendering, events, routing, and persistence. |
| `src/js/model.js` | Rental commands and state validation; independent of the DOM. |
| `src/js/catalog.js` | Sample movie records with stable IDs and poster paths. |
| `src/css/styles.css` | Theme tokens, components, and responsive layouts. |
| `assets/` | Browser demo logo and poster files. |
| `tests/model.test.js` | Rental lifecycle and data integrity tests. |
| `.github/workflows/pages.yml` | Test and publish only the browser frontend. |
| `source/OGNETFLIX/` | Original Java/JSP application; see its [source guide](../source/README.md). |

The browser demo and original Java application are separate implementations. They do not share accounts, storage, or a database. Keep that distinction when explaining or extending either version.

## Recommended reading order

1. Read `catalog.js` to see what a movie record contains.
2. Read `initial`, `activeRental`, `transition`, and `validate` in `model.js`.
3. Read `act` and `save` in `app.js` to see how a UI command reaches the model and storage.
4. Follow `navigate` → `render` → the selected view function.
5. Read the tests as examples of successful and rejected commands.

## State and command flow

The saved state has `version`, `movies`, `members`, and `rentals`. Member queues store movie IDs. Rentals reference movie and member IDs rather than copying those records.

A button or form calls `act(type, fields)`. That controller supplies the selected member, demo role, and generated ID. `transition` clones the current state, checks the command, and returns a proposed new state. `save` validates it, writes local storage, and only then replaces the in-memory state. A rejected command or failed write preserves the previous state.

Search text, genre filter, route, selected member, and workspace are temporary UI choices. Reloading restores collection data, but starts in the member workspace. The local-storage key remains `polo-ognetflix-demo-v1`; reorganizing source files does not reset existing demo data.

## Rental rules

| Command | Effect and constraints |
| --- | --- |
| `member-add` | Demo admin creates an independent local profile. |
| `queue-add` | Adds an active movie; rejects duplicates and the current at-home title. |
| `queue-remove` / `queue-move` | Removes or reorders queued movie IDs. |
| `dispatch` | Demo admin sends the first active queued title if the member has no movie at home. |
| `watch` | The owning member changes a mailed rental to watched. |
| `return` | Demo admin returns a watched rental and dispatches the next eligible queued title. |
| `movie-toggle` | Changes availability without deleting queue or history references. |
| `movie-save` | Adds or updates catalog metadata after validating required fields and poster URLs. |

`mailed` and `watched` both count as at home. `returned` remains in history. Inactive queued movies stay in place while dispatch skips them. The archived Java implementation has its own behavior; read its methods rather than assuming every detail matches the browser adaptation.

## Where to make changes

- **Movie metadata:** edit `catalog.js`. Preserve IDs that saved queues and rentals may reference. Existing visitors retain their saved catalog until they reset their own demo.
- **Rental behavior:** edit `model.js`, then update the relevant lifecycle tests.
- **Page content or actions:** edit the corresponding view and delegated event handler in `app.js`.
- **Layout and colors:** edit `styles.css`; responsive rules are at the end.
- **Navigation or dialogs:** edit `index.html` and the matching controller functions together.
- **Saved-state shape:** plan an explicit migration and version strategy before changing `version` or required fields. Do not silently discard saved data.

## Checks before publishing

Run `npm test`, then `npm start` and open `http://localhost:8080`. Try queueing two titles, dispatching one as administrator, marking it watched as member, and returning it as administrator. Confirm the second dispatches, the first appears in History, and refreshing retains the records. Also check search, movie details, and the layout on a narrow screen.

The deployment job copies `index.html`, `src/`, and `assets/` into `_site`. If you add a new runtime folder, include it in that workflow. Documentation, tests, and the original server sources are not deployed to Pages.

## Commenting convention

Explain ownership, constraints, side effects, or the reason for a decision. Avoid comments that repeat an obvious assignment. Keep domain rules in the model and browser behavior in the controller. The workspace switch is a local demonstration and must not be described as real authentication.
