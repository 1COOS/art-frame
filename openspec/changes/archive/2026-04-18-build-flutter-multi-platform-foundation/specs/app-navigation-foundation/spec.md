## ADDED Requirements

### Requirement: Application uses declarative routing as the navigation foundation
The system SHALL define application navigation through declarative routes that support mobile navigation flows and Web URLs from the same route model.

#### Scenario: Resolve a route from an application URL
- **WHEN** the application is opened from a supported route URL on Web or deep-link entry
- **THEN** the router SHALL resolve the matching destination from the declared route table

#### Scenario: Navigate between top-level destinations
- **WHEN** a user selects a primary destination from the application shell
- **THEN** the router SHALL update the active route without requiring manual Navigator stack orchestration in each screen

### Requirement: Navigation supports shell-based persistent UI
The system SHALL support shell-based routing for layouts that keep shared navigation chrome visible while child content changes.

#### Scenario: Keep shell navigation visible during child route changes
- **WHEN** a child destination inside the primary shell becomes active
- **THEN** the shared shell UI SHALL remain mounted while the child content updates

#### Scenario: Support multi-branch navigation structures
- **WHEN** the foundation defines multiple top-level destinations
- **THEN** the routing model SHALL support shell-based branch navigation suitable for bottom navigation, rail navigation, or side navigation

### Requirement: Navigation supports redirect-based application guards
The system SHALL support redirect logic at the router layer for app-level guard conditions such as initialization or future authentication state.

#### Scenario: Apply a redirect before rendering a protected destination
- **WHEN** a route requires a guard decision before display
- **THEN** the router SHALL be able to redirect the user to an alternate route based on application state
