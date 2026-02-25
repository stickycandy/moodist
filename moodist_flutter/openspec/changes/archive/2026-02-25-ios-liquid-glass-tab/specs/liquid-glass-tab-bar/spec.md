## ADDED Requirements

### Requirement: Platform-adaptive rendering
The system SHALL render the appropriate Tab Bar style based on the current platform and OS version.

#### Scenario: iOS 26+ device
- **WHEN** the app runs on an iOS device with version 26 or higher
- **THEN** the system SHALL display the Liquid Glass style Tab Bar

#### Scenario: iOS below version 26
- **WHEN** the app runs on an iOS device with version below 26
- **THEN** the system SHALL display the standard CupertinoTabBar

#### Scenario: Android or other platforms
- **WHEN** the app runs on Android or other non-iOS platforms
- **THEN** the system SHALL display the Material 3 NavigationBar

### Requirement: Frosted glass background effect
The Liquid Glass Tab Bar SHALL display a semi-transparent frosted glass background with blur effect.

#### Scenario: Light mode appearance
- **WHEN** the system is in light mode
- **THEN** the Tab Bar background SHALL be white with 70% opacity and 25px blur radius

#### Scenario: Dark mode appearance
- **WHEN** the system is in dark mode
- **THEN** the Tab Bar background SHALL be black with 50% opacity and 30px blur radius

#### Scenario: Content visibility through blur
- **WHEN** content scrolls behind the Tab Bar
- **THEN** the content SHALL be visible through the frosted glass effect with appropriate blur

### Requirement: Floating capsule indicator
The Liquid Glass Tab Bar SHALL display a floating capsule-shaped indicator for the selected tab.

#### Scenario: Indicator position
- **WHEN** a tab is selected
- **THEN** the capsule indicator SHALL be positioned centered under the selected tab icon

#### Scenario: Indicator appearance
- **WHEN** the Tab Bar is rendered
- **THEN** the capsule indicator SHALL have rounded corners (pill shape) and a translucent fill color matching the system accent

### Requirement: Smooth tab switching animation
The Liquid Glass Tab Bar SHALL animate smoothly when switching between tabs.

#### Scenario: Indicator slide animation
- **WHEN** the user taps a different tab
- **THEN** the capsule indicator SHALL animate horizontally to the new position with easeOutCubic curve within 300ms

#### Scenario: Icon scale animation
- **WHEN** a tab becomes selected
- **THEN** the tab icon SHALL scale up by 10% with a smooth animation

#### Scenario: Icon color transition
- **WHEN** a tab selection changes
- **THEN** the icon color SHALL transition from inactive to active color with a fade animation

### Requirement: Tab item configuration
The Liquid Glass Tab Bar SHALL support configurable tab items with icon and label.

#### Scenario: Five tabs displayed
- **WHEN** the Tab Bar is rendered
- **THEN** it SHALL display exactly 5 tabs: Sounds, Presets, Sleep Timer, Pomodoro, Todo

#### Scenario: Tab icon display
- **WHEN** a tab is rendered
- **THEN** it SHALL display the configured icon above the label text

#### Scenario: Tab label display
- **WHEN** a tab is rendered
- **THEN** it SHALL display the localized label below the icon

### Requirement: Safe area handling
The Liquid Glass Tab Bar SHALL properly handle device safe areas.

#### Scenario: Bottom safe area on iPhone with home indicator
- **WHEN** the app runs on an iPhone with a home indicator (Face ID models)
- **THEN** the Tab Bar SHALL extend into the bottom safe area with content properly inset

#### Scenario: Standard iPhone without home indicator
- **WHEN** the app runs on an iPhone without a home indicator
- **THEN** the Tab Bar SHALL be positioned at the bottom edge without extra padding

### Requirement: Version detection caching
The iOS version detection result SHALL be cached to avoid repeated native calls.

#### Scenario: First version check
- **WHEN** the app starts and checks iOS version for the first time
- **THEN** the system SHALL call the native platform channel and cache the result

#### Scenario: Subsequent version checks
- **WHEN** the app checks iOS version after the first call
- **THEN** the system SHALL return the cached value without calling native code
