## ADDED Requirements

### Requirement: Application must support persisted theme mode preferences
The system SHALL allow users to choose an application theme mode preference of `light`, `dark`, or `system`, persist that preference locally, and restore it on subsequent launches.

#### Scenario: Persist and restore theme mode
- **WHEN** a user changes the theme mode preference from the Settings page and later relaunches the application
- **THEN** the system SHALL restore and apply the previously selected theme mode instead of resetting to a hard-coded default

### Requirement: Theme mode preference must apply at the application root
The system SHALL apply the active theme mode preference through the root app configuration so that all app surfaces use the selected appearance consistently.

#### Scenario: Apply theme mode globally
- **WHEN** the active theme mode preference changes while the application is running
- **THEN** the root application configuration SHALL update to use the selected theme mode and visible screens SHALL reflect the new appearance without requiring a restart

### Requirement: Settings page must expose theme mode as a general preference
The system SHALL expose theme mode selection within the `General` section of the Settings page as a first-class application preference alongside runtime language selection.

#### Scenario: Change theme mode from General settings
- **WHEN** a user opens the `General` section of the Settings page
- **THEN** the system SHALL present controls for choosing `light`, `dark`, or `system` theme mode and SHALL keep the selected option visibly synchronized with the active preference
