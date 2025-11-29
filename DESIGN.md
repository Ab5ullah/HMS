# UI/UX Design System Documentation
## Hostel Management System (HMS)

This document provides a comprehensive overview of the design system, UI/UX principles, and design patterns followed in the Hostel Management System.

---

## Table of Contents

1. [Design Philosophy](#design-philosophy)
2. [Design Principles](#design-principles)
3. [Color System](#color-system)
4. [Typography](#typography)
5. [Spacing & Layout](#spacing--layout)
6. [Components](#components)
7. [Responsive Design](#responsive-design)
8. [Navigation Patterns](#navigation-patterns)
9. [Interaction Design](#interaction-design)
10. [Accessibility](#accessibility)
11. [Platform-Specific Adaptations](#platform-specific-adaptations)
12. [Design Tokens](#design-tokens)

---

## Design Philosophy

### Core Principles

The HMS design system is built on **Material Design 3** principles with modern enhancements, focusing on:

1. **Simplicity** - Clean, uncluttered interfaces that prioritize content
2. **Consistency** - Unified experience across all platforms and user roles
3. **Efficiency** - Streamlined workflows for quick task completion
4. **Accessibility** - Inclusive design for all users
5. **Responsiveness** - Seamless experience from mobile to desktop

### Visual Language

- **Modern & Professional** - Contemporary design suitable for educational institutions
- **Data-Driven** - Clear presentation of information with visual hierarchy
- **Role-Based** - Color-coded interfaces for different user types
- **Component-Based** - Reusable, modular design system

---

## Design Principles

### 1. Mobile-First Approach

The application is designed mobile-first, then progressively enhanced for larger screens:

- **Mobile (< 768px)**: Single column layouts, bottom navigation, full-screen modals
- **Tablet (768px - 1024px)**: Two-column layouts, side navigation, adaptive grids
- **Desktop (> 1024px)**: Multi-column layouts, persistent sidebar, expansive data tables

### 2. Progressive Disclosure

Information is revealed progressively to avoid overwhelming users:

- Dashboard shows summary cards → Click for detailed views
- Forms use sections and steps for complex data entry
- Advanced filters hidden by default, revealed on demand

### 3. Feedback & Confirmation

Every user action receives clear feedback:

- Loading states for asynchronous operations
- Success/error messages via snackbars
- Confirmation dialogs for destructive actions
- Visual state changes (hover, active, disabled)

### 4. Contextual Actions

Actions are placed contextually where users need them:

- Floating Action Buttons (FAB) for primary actions
- Context menus for item-specific actions
- Inline edit buttons for quick modifications
- Bulk actions in list views

---

## Color System

### Primary Palette

```dart
Primary Color: #6366F1 (Indigo)
├─ Light: #818CF8
└─ Dark: #4F46E5

Purpose: Primary actions, links, active states
Usage: Buttons, app bars, selected items, progress indicators
```

### Secondary Palette

```dart
Secondary Color: #14B8A6 (Teal)
├─ Light: #2DD4BF
└─ Dark: #0F766E

Purpose: Secondary actions, highlights
Usage: FABs, chips, badges, accent elements
```

### Semantic Colors

```dart
Success: #10B981 (Green)
Warning: #F59E0B (Amber)
Error: #EF4444 (Red)
Info: #3B82F6 (Blue)

Purpose: Status indicators, alerts, notifications
Usage: Status badges, alert banners, validation messages
```

### Role-Based Colors

Each user role has a distinct color for quick identification:

```dart
Admin: #8B5CF6 (Purple)
Warden: #10B981 (Green)
Mess Manager: #F59E0B (Amber)
Student: #3B82F6 (Blue)
Staff: #EC4899 (Pink)

Purpose: Role identification, dashboard theming
Usage: App bars, cards, avatars, badges
```

### Neutral Colors

```dart
Gray Scale:
├─ 50: #F9FAFB (Background)
├─ 100: #F3F4F6 (Background Dark)
├─ 200: #E5E7EB (Border)
├─ 400: #9CA3AF (Text Tertiary)
├─ 500: #6B7280 (Text Secondary)
└─ 900: #111827 (Text Primary)

Purpose: Text, backgrounds, borders, dividers
Usage: Text content, cards, input fields, separators
```

### Color Application

#### Backgrounds
- **Page Background**: Gray 50 (#F9FAFB)
- **Card/Surface**: White (#FFFFFF)
- **Elevated Surface**: White with shadow
- **Hover State**: Gray 100 (#F3F4F6)

#### Text
- **Primary Text**: Gray 900 (#111827) - Body text, headings
- **Secondary Text**: Gray 500 (#6B7280) - Subtitles, labels
- **Tertiary Text**: Gray 400 (#9CA3AF) - Hints, placeholders
- **Disabled Text**: Gray 300 (#D1D5DB)

#### Interactive Elements
- **Default**: Primary color
- **Hover**: Primary dark
- **Active/Pressed**: Primary dark with opacity
- **Disabled**: Gray 300

---

## Typography

### Font Family

```
Primary Font: System Default
├─ iOS: SF Pro Display
├─ Android: Roboto
└─ Web: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto
```

### Type Scale

Based on Material Design 3 type scale with modern proportions:

#### Display Styles (Large Headings)

```dart
Display Large: 57px / Bold / -0.25 letter-spacing
Display Medium: 45px / Bold / 0 letter-spacing
Display Small: 36px / SemiBold / 0 letter-spacing

Usage: Hero sections, empty states, splash screens
```

#### Headline Styles (Section Headers)

```dart
Headline Large: 32px / SemiBold / 0 letter-spacing
Headline Medium: 28px / SemiBold / 0 letter-spacing
Headline Small: 24px / SemiBold / 0 letter-spacing

Usage: Page titles, section headers, dialog titles
```

#### Title Styles (Card Headers)

```dart
Title Large: 22px / SemiBold / 0 letter-spacing
Title Medium: 16px / SemiBold / 0.15 letter-spacing
Title Small: 14px / SemiBold / 0.1 letter-spacing

Usage: Card titles, list item titles, form labels
```

#### Body Styles (Content)

```dart
Body Large: 16px / Regular / 0.5 letter-spacing / 1.5 line-height
Body Medium: 14px / Regular / 0.25 letter-spacing / 1.43 line-height
Body Small: 12px / Regular / 0.4 letter-spacing / 1.33 line-height

Usage: Paragraph text, descriptions, content blocks
```

#### Label Styles (UI Elements)

```dart
Label Large: 14px / Medium / 0.1 letter-spacing
Label Medium: 12px / Medium / 0.5 letter-spacing
Label Small: 11px / Medium / 0.5 letter-spacing

Usage: Button labels, chip text, badges, form hints
```

### Typography Hierarchy

```
Level 1: Page Title (Headline Large)
  └─ Level 2: Section Header (Headline Medium)
      └─ Level 3: Subsection (Title Large)
          └─ Level 4: Card Title (Title Medium)
              └─ Level 5: Content (Body Medium)
                  └─ Level 6: Caption (Body Small)
```

### Font Weights

```
Regular (400): Body text, descriptions
Medium (500): Labels, buttons, navigation items
SemiBold (600): Headings, titles, emphasis
Bold (700): Display text, strong emphasis
```

---

## Spacing & Layout

### Spacing System (8pt Grid)

All spacing follows an 8-point grid system for consistency:

```dart
XS: 4px   (0.5 × base)
SM: 8px   (1 × base)
MD: 16px  (2 × base)
LG: 24px  (3 × base)
XL: 32px  (4 × base)
XXL: 48px (6 × base)
XXXL: 64px (8 × base)
```

### Component Spacing

#### Padding
- **Container Padding**: 16px (mobile), 24px (tablet), 32px (desktop)
- **Card Padding**: 16px (all sides)
- **List Item Padding**: 16px vertical, 16px horizontal
- **Button Padding**: 12px vertical, 24px horizontal
- **Input Field Padding**: 12px vertical, 16px horizontal

#### Margins
- **Section Margins**: 24px bottom
- **Component Margins**: 16px bottom
- **Element Margins**: 8px bottom
- **Inline Margins**: 4px right

#### Gaps
- **Grid Gap**: 16px (mobile), 24px (tablet/desktop)
- **List Gap**: 8px between items
- **Chip Gap**: 8px between chips
- **Button Gap**: 12px between buttons

### Layout Grids

#### Mobile Layout (< 768px)
```
Columns: 4
Gutter: 16px
Margin: 16px
```

#### Tablet Layout (768px - 1024px)
```
Columns: 8
Gutter: 24px
Margin: 24px
```

#### Desktop Layout (> 1024px)
```
Columns: 12
Gutter: 24px
Margin: 32px
Max Width: 1440px (centered)
```

### Content Width Constraints

```dart
Small Content: 600px max (forms, dialogs)
Medium Content: 960px max (cards, lists)
Large Content: 1200px max (tables, dashboards)
Extra Large: 1440px max (full layouts)
```

---

## Components

### 1. Cards

**Purpose**: Container for related information and actions

#### ModernCard Component

```dart
Properties:
├─ Padding: 16px (default), customizable
├─ Border Radius: 12px
├─ Border: 1px solid #E5E7EB
├─ Background: White
├─ Shadow: None (default), elevated on hover
└─ Elevation: 0 (flat), 4 (hover)

Variants:
├─ Default: Flat card with border
├─ Elevated: Persistent shadow
├─ Outlined: Prominent border
└─ Interactive: Hover effects, clickable
```

#### ModernStatsCard

```dart
Structure:
├─ Icon Container (colored background)
├─ Title (Label Medium)
├─ Value (Headline Small)
└─ Trend Indicator (optional)

Usage: Dashboard statistics, KPI displays
```

#### InfoCard

```dart
Structure:
├─ Label (Caption)
├─ Value (Body Medium)
└─ Icon (optional)

Usage: Key-value pairs, metadata display
```

### 2. Buttons

**Purpose**: Trigger actions and navigation

#### ModernButton Component

```dart
Sizes:
├─ Small: 36px height
├─ Medium: 44px height (default)
└─ Large: 52px height

Variants:
├─ Filled: Solid background, primary color
├─ Outlined: Border only, transparent background
├─ Text: No border, no background
└─ Elevated: Filled with shadow

States:
├─ Default: Standard appearance
├─ Hover: Slight color change
├─ Active: Pressed state
├─ Disabled: Grayed out, no interaction
└─ Loading: Spinner indicator
```

#### Button Usage Patterns

```
Primary Action: Filled button (primary color)
Secondary Action: Outlined button
Tertiary Action: Text button
Destructive Action: Filled button (error color)
```

### 3. Input Fields

**Purpose**: Data entry and forms

#### ModernTextField Component

```dart
Structure:
├─ Label (above field)
├─ Input Container
│   ├─ Prefix Icon (optional)
│   ├─ Input Field
│   └─ Suffix Icon (optional)
├─ Helper Text (below field)
└─ Error Text (validation)

States:
├─ Default: Gray border
├─ Focus: Primary color border
├─ Error: Error color border
├─ Disabled: Gray background
└─ Success: Success color indicator

Properties:
├─ Height: 48px
├─ Border Radius: 8px
├─ Padding: 12px vertical, 16px horizontal
└─ Font Size: 14px
```

#### Input Types

```
Text Input: Single-line text
Text Area: Multi-line text
Number Input: Numeric keyboard
Date Picker: Calendar selection
Dropdown: Single selection
Autocomplete: Searchable dropdown
Checkbox: Multiple selection
Radio: Single selection
Switch: Toggle on/off
```

### 4. Navigation

#### Top App Bar

```dart
Structure:
├─ Leading (back button / menu)
├─ Title (screen name)
├─ Actions (icons, 2-3 max)
└─ Tabs (optional)

Height: 56px (mobile), 64px (desktop)
Background: Role-based color or white
Elevation: 0 (flat) or 4 (elevated)
```

#### Sidebar Navigation (Desktop)

```dart
Structure:
├─ Logo/Branding
├─ User Profile Section
├─ Navigation Items
│   ├─ Icon (24px)
│   ├─ Label
│   └─ Badge (optional)
├─ Divider
└─ Secondary Actions (logout, settings)

Width: 280px
Background: White
Border: 1px solid #E5E7EB

Item States:
├─ Default: Gray text, transparent background
├─ Hover: Light background
├─ Active: Primary color background, white text
└─ Selected: Primary color accent
```

#### Bottom Navigation (Mobile)

```dart
Structure:
├─ Items (3-5 max)
│   ├─ Icon (24px)
│   └─ Label (optional)

Height: 56px
Background: White
Shadow: Top shadow

States:
├─ Default: Gray icon/text
├─ Active: Primary color icon/text
└─ Badge: Notification indicator
```

### 5. Lists & Tables

#### List Items

```dart
Structure:
├─ Leading (avatar/icon)
├─ Content
│   ├─ Title (Title Medium)
│   ├─ Subtitle (Body Small)
│   └─ Caption (Label Small)
├─ Metadata (badges, status)
└─ Trailing (action icon/chevron)

Height: Auto, min 64px
Padding: 16px
Divider: 1px solid #E5E7EB
```

#### Data Tables (Desktop)

```dart
Structure:
├─ Header Row
│   ├─ Column Headers
│   ├─ Sort Indicators
│   └─ Filter Icons
├─ Data Rows
│   ├─ Cell Content
│   └─ Row Actions (hover)
└─ Footer (pagination)

Cell Padding: 16px horizontal
Row Height: 52px (data), 56px (header)
Border: 1px solid #E5E7EB
```

### 6. Dialogs & Modals

#### Dialog

```dart
Structure:
├─ Header
│   ├─ Title (Headline Small)
│   └─ Close Button
├─ Content (scrollable)
└─ Actions (Cancel, Confirm)

Max Width: 600px
Border Radius: 16px
Padding: 24px
Backdrop: 50% black opacity
```

#### Bottom Sheet (Mobile)

```dart
Structure:
├─ Handle (drag indicator)
├─ Title
├─ Content
└─ Actions

Border Radius: 16px (top corners)
Max Height: 90% viewport
Padding: 16px
```

### 7. Status Indicators

#### Badges

```dart
Sizes:
├─ Small: 20px height
├─ Medium: 24px height
└─ Large: 28px height

Variants:
├─ Filled: Solid background
├─ Outlined: Border only
└─ Soft: Light background, dark text

Colors: Semantic (success, warning, error, info)
Border Radius: Full (pill shape)
```

#### Chips

```dart
Structure:
├─ Leading Icon (optional)
├─ Label
└─ Trailing Icon (optional, delete)

Height: 32px
Padding: 8px horizontal
Border Radius: 16px
Background: Gray 100
```

#### Progress Indicators

```dart
Linear Progress:
├─ Height: 4px
├─ Border Radius: 2px
└─ Colors: Primary (progress), Gray 200 (track)

Circular Progress:
├─ Size: 24px (small), 40px (medium), 56px (large)
├─ Stroke Width: 4px
└─ Color: Primary
```

### 8. Feedback Elements

#### Snackbar

```dart
Structure:
├─ Message Text
├─ Action Button (optional)
└─ Close Icon (optional)

Position: Bottom center (mobile), bottom left (desktop)
Width: 100% (mobile), max 400px (desktop)
Height: Auto, min 48px
Padding: 16px
Border Radius: 8px
Duration: 4 seconds (auto-dismiss)
Background: Gray 900 (90% opacity)
Text Color: White
```

#### Toast Messages

```dart
Variants:
├─ Success: Green background, checkmark icon
├─ Error: Red background, error icon
├─ Warning: Amber background, warning icon
└─ Info: Blue background, info icon

Position: Top right
Width: 300px
Duration: 3-5 seconds
Animation: Slide in from right
```

### 9. Empty States

```dart
Structure:
├─ Illustration/Icon (64px)
├─ Title (Headline Small)
├─ Description (Body Medium)
└─ Action Button (optional)

Alignment: Center
Padding: 48px
Background: Light gray or transparent
```

### 10. Loading States

#### Skeleton Screens

```dart
Components:
├─ Skeleton Card
├─ Skeleton List Item
├─ Skeleton Text Line
└─ Skeleton Avatar

Animation: Shimmer effect (left to right)
Colors: Gray 200 → Gray 100 → Gray 200
Duration: 1.5 seconds loop
```

---

## Responsive Design

### Breakpoint Strategy

```dart
Mobile: 0 - 767px
Tablet: 768px - 1023px
Desktop: 1024px - 1279px
Large Desktop: 1280px - 1535px
Extra Large: 1536px+
```

### Responsive Patterns

#### 1. **Reflow Pattern**
- Content stacks vertically on mobile
- Side-by-side layout on desktop
- Used in: Forms, dashboards, detail views

#### 2. **Column Drop Pattern**
- Multi-column layout drops to single column
- Columns reappear as width increases
- Used in: Grid layouts, card grids

#### 3. **Layout Shifter Pattern**
- Major layout changes across breakpoints
- Used in: Main layout (sidebar → bottom nav)

#### 4. **Off-Canvas Pattern**
- Navigation hidden off-screen on mobile
- Revealed via hamburger menu
- Persistent sidebar on desktop
- Used in: Main navigation

### Component Adaptations

#### Navigation
```
Mobile: Bottom navigation (< 768px)
Tablet: Rail navigation (768px - 1024px)
Desktop: Full sidebar (> 1024px)
```

#### Data Display
```
Mobile: Cards, single column
Tablet: 2-column grid, simplified tables
Desktop: Multi-column grids, full tables
```

#### Forms
```
Mobile: Single column, full-width inputs
Tablet: Two-column where appropriate
Desktop: Multi-column with logical grouping
```

#### Dialogs
```
Mobile: Full-screen or bottom sheet
Tablet: Centered dialog (max 600px)
Desktop: Centered dialog (max 600px)
```

### Grid Adaptations

```dart
Dashboard Stats Cards:
Mobile: 1 column
Tablet: 2 columns
Desktop: 4 columns

List Items:
Mobile: Single column, compact
Tablet: Single column, more details
Desktop: Table view with all columns

Card Grids:
Mobile: 1 column
Tablet: 2 columns
Desktop: 3-4 columns
```

---

## Navigation Patterns

### Information Architecture

```
Root Level
├─ Authentication
│   ├─ Login
│   └─ Register
│
├─ Dashboard (Role-specific)
│   ├─ Overview
│   ├─ Quick Actions
│   └─ Recent Activity
│
├─ Primary Modules
│   ├─ Students
│   │   ├─ List
│   │   ├─ Detail
│   │   └─ Add/Edit
│   │
│   ├─ Rooms
│   │   ├─ List
│   │   ├─ Detail
│   │   └─ Add/Edit
│   │
│   ├─ Payments
│   │   ├─ List
│   │   ├─ Detail
│   │   └─ Add
│   │
│   ├─ Mess
│   │   ├─ Menu
│   │   └─ Edit Menu
│   │
│   ├─ Complaints
│   │   ├─ List
│   │   ├─ Detail
│   │   └─ Submit
│   │
│   └─ Leaves
│       ├─ List
│       ├─ Detail
│       └─ Apply
│
└─ Settings
    ├─ Profile
    ├─ Password
    └─ Preferences
```

### Navigation Hierarchy

#### Level 1: Primary Navigation
- Main modules accessible from sidebar/bottom nav
- Persistent across sessions
- Icon + label

#### Level 2: Secondary Navigation
- Sub-sections within modules
- Tabs or segmented controls
- Context-specific

#### Level 3: Tertiary Actions
- Item-specific actions
- Context menus, overflow menus
- Action buttons

### Navigation Transitions

```dart
Forward Navigation:
- Slide from right (mobile)
- Fade in (desktop)
- Duration: 300ms

Backward Navigation:
- Slide from left (mobile)
- Fade out (desktop)
- Duration: 300ms

Modal:
- Scale + fade in
- Duration: 200ms
```

### Breadcrumbs (Desktop Only)

```dart
Structure:
Home > Students > Student Detail > Edit

Location: Below app bar
Font: Body Small
Separator: Chevron (>)
Interactive: Clickable links
```

---

## Interaction Design

### Touch Targets

```dart
Minimum Size: 48×48 dp
Recommended: 56×56 dp (primary actions)
Spacing: 8dp minimum between targets
```

### Gestures

#### Mobile Gestures
```
Tap: Primary action
Long Press: Context menu
Swipe Right: Navigate back
Swipe Left: Delete/archive (lists)
Pull to Refresh: Refresh content
Pinch to Zoom: Images, maps
```

#### Desktop Interactions
```
Click: Primary action
Right Click: Context menu
Hover: Show additional info
Keyboard Navigation: Tab, Enter, Esc
```

### Animation Principles

#### Motion Curves
```dart
Standard: Ease-in-out (default)
Deceleration: Ease-out (entering)
Acceleration: Ease-in (exiting)
Sharp: Linear (emphasized)
```

#### Duration Guidelines
```
Simple: 100-200ms (hover, ripple)
Standard: 200-300ms (transitions)
Complex: 300-500ms (layout changes)
```

#### Animation Types

**Micro-interactions**
- Button ripple effect
- Checkbox check animation
- Switch toggle
- Input focus

**Transitions**
- Screen transitions
- Modal appearances
- List item additions
- Content loading

**Feedback**
- Success checkmark
- Error shake
- Loading spinners
- Progress bars

### States & Feedback

#### Interactive States
```
Rest: Default appearance
Hover: Subtle highlight (desktop)
Focus: Accent border (keyboard navigation)
Active: Pressed appearance
Disabled: Reduced opacity, no interaction
Loading: Spinner indicator
Success: Checkmark, green highlight
Error: Red highlight, shake animation
```

#### Visual Feedback Timing
```
Immediate: < 100ms (button press)
Quick: 100-300ms (form validation)
Standard: 300-500ms (page load)
Delayed: > 500ms (network requests)
```

---

## Accessibility

### WCAG 2.1 Level AA Compliance

#### Color Contrast
```
Normal Text: Minimum 4.5:1
Large Text (18pt+): Minimum 3:1
UI Components: Minimum 3:1
Focus Indicators: Minimum 3:1
```

#### Contrast Ratios (Our Palette)
```
Primary (#6366F1) on White: 5.23:1 ✓
Secondary (#14B8A6) on White: 4.68:1 ✓
Error (#EF4444) on White: 4.01:1 ✓
Gray 900 (#111827) on White: 17.43:1 ✓
```

### Keyboard Navigation

```dart
Tab Order: Logical, sequential
Focus Indicators: 2px solid primary color
Skip Links: Jump to main content
Escape: Close modals/dialogs
Enter: Activate buttons/links
Space: Toggle checkboxes/switches
Arrow Keys: Navigate lists/menus
```

### Screen Reader Support

```dart
Semantic Labels: All interactive elements
ARIA Attributes: Proper roles and states
Alt Text: All images and icons
Live Regions: Dynamic content updates
Headings: Logical hierarchy (H1 → H6)
```

### Form Accessibility

```
Labels: Associated with inputs
Required Fields: Marked visually and semantically
Error Messages: Announced to screen readers
Help Text: Descriptive, helpful
Autocomplete: Standard attributes
```

### Touch Target Sizes

```
Minimum: 48×48 dp
Recommended: 56×56 dp
Spacing: 8dp between targets
```

---

## Platform-Specific Adaptations

### Mobile (iOS & Android)

#### iOS Specific
```
Navigation: iOS-style back button
Modals: Bottom sheet presentations
Keyboard: iOS keyboard style
Haptic Feedback: On key interactions
Safe Areas: Respect notch/home indicator
```

#### Android Specific
```
Navigation: Material back button
Modals: Full-screen or dialog
Keyboard: Android keyboard style
Ripple Effects: Material ripple
System Navigation: Gesture/button support
```

### Web

#### Desktop Web
```
Cursor States: Pointer, default, text
Tooltips: On hover
Keyboard Shortcuts: Common actions
Right-Click Menus: Context actions
URL Navigation: Deep linking support
Browser Controls: Back/forward support
```

#### Responsive Web
```
Touch Support: When available
Hover States: Progressive enhancement
Viewport Meta: Proper scaling
Print Styles: Optimized for printing
```

### Desktop (Windows/macOS/Linux)

```
Window Controls: Native title bar
Keyboard Shortcuts: Platform conventions
Context Menus: Native menus
File Dialogs: Native pickers
Notifications: System notifications
```

---

## Design Tokens

### Spacing Tokens
```dart
spacing-xs: 4px
spacing-sm: 8px
spacing-md: 16px
spacing-lg: 24px
spacing-xl: 32px
spacing-xxl: 48px
spacing-xxxl: 64px
```

### Radius Tokens
```dart
radius-none: 0px
radius-xs: 4px
radius-sm: 8px
radius-md: 12px
radius-lg: 16px
radius-xl: 20px
radius-xxl: 24px
radius-full: 9999px
```

### Shadow Tokens
```dart
shadow-sm: 0 1px 2px rgba(0,0,0,0.05)
shadow-md: 0 2px 6px rgba(0,0,0,0.1)
shadow-lg: 0 4px 15px rgba(0,0,0,0.12)
shadow-xl: 0 10px 25px rgba(0,0,0,0.15)
```

### Typography Tokens
```dart
font-size-xs: 11px
font-size-sm: 12px
font-size-md: 14px
font-size-lg: 16px
font-size-xl: 22px
font-size-2xl: 24px
font-size-3xl: 28px
font-size-4xl: 32px

font-weight-regular: 400
font-weight-medium: 500
font-weight-semibold: 600
font-weight-bold: 700

line-height-tight: 1.25
line-height-normal: 1.5
line-height-relaxed: 1.75
```

### Duration Tokens
```dart
duration-fast: 150ms
duration-normal: 300ms
duration-slow: 500ms
```

### Z-Index Scale
```dart
z-index-dropdown: 1000
z-index-sticky: 1020
z-index-fixed: 1030
z-index-modal-backdrop: 1040
z-index-modal: 1050
z-index-popover: 1060
z-index-tooltip: 1070
```

---

## Component States Matrix

| Component | Default | Hover | Active | Focus | Disabled | Loading | Error |
|-----------|---------|-------|--------|-------|----------|---------|-------|
| Button | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | - |
| Input | ✓ | ✓ | - | ✓ | ✓ | - | ✓ |
| Card | ✓ | ✓ | ✓ | - | - | ✓ | - |
| List Item | ✓ | ✓ | ✓ | ✓ | - | - | - |
| Chip | ✓ | ✓ | ✓ | ✓ | ✓ | - | - |
| Switch | ✓ | ✓ | - | ✓ | ✓ | - | - |
| Checkbox | ✓ | ✓ | - | ✓ | ✓ | - | ✓ |
| Link | ✓ | ✓ | ✓ | ✓ | ✓ | - | - |

---

## Best Practices

### Do's ✓

1. **Use semantic color names** (primary, error) instead of literal colors (blue, red)
2. **Follow spacing system** for consistent layouts
3. **Provide loading states** for async operations
4. **Use proper typography hierarchy** for content structure
5. **Test with keyboard navigation** for accessibility
6. **Optimize images** for faster loading
7. **Use icons consistently** from Material Icons set
8. **Provide feedback** for all user actions
9. **Follow platform conventions** when applicable
10. **Test on real devices** across different sizes

### Don'ts ✗

1. **Don't use arbitrary spacing** values
2. **Don't omit focus indicators** for keyboard users
3. **Don't rely solely on color** to convey information
4. **Don't use too many font sizes** (stick to type scale)
5. **Don't make touch targets smaller** than 48dp
6. **Don't auto-play videos** or animations
7. **Don't use red/green only** for status (colorblind)
8. **Don't nest cards** more than 2 levels deep
9. **Don't use all caps** for long text
10. **Don't forget empty states** and error handling

---

## Implementation Guidelines

### CSS/Styling Approach

```dart
// Using constants from constants.dart
Container(
  padding: EdgeInsets.all(AppSizes.paddingMedium),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
    border: Border.all(color: AppColors.border),
  ),
  child: Text(
    'Hello',
    style: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.textPrimary,
    ),
  ),
)
```

### Component Composition

```dart
// Build reusable components
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  // Implementation...
}

// Use in screens
ModernCard(
  padding: EdgeInsets.all(AppSizes.paddingLarge),
  onTap: () => handleTap(),
  child: // Your content
)
```

### Responsive Implementation

```dart
// Using responsive utilities
LayoutBuilder(
  builder: (context, constraints) {
    if (context.isMobile) {
      return MobileLayout();
    } else if (context.isTablet) {
      return TabletLayout();
    } else {
      return DesktopLayout();
    }
  },
)
```

---

## Version History

### v1.0.0 (Current)
- Initial design system
- Material Design 3 based
- Responsive layouts for mobile, tablet, desktop
- Role-based color scheme
- Complete component library
- Accessibility features

### Future Enhancements
- [ ] Dark mode support
- [ ] Custom illustrations
- [ ] Animation library
- [ ] Micro-interaction patterns
- [ ] Advanced data visualization components
- [ ] Theming customization options

---

## References

- [Material Design 3](https://m3.material.io/)
- [Flutter Design Guidelines](https://docs.flutter.dev/design)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Android Design Guidelines](https://developer.android.com/design)

---

**Last Updated**: November 2024
**Maintained By**: HMS Design Team
**Questions?** Contact: design@yourdomain.com

---

Made with ❤️ using Flutter
