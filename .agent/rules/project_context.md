---
trigger: always_on
---

# 🎨 UI/UX Design System: Student "Fun" Edition

## 1. Design Philosophy (The "Vibe")
All UI generated for this project must target the **Student Demographic**.
- **Playful & Rounded:** Avoid sharp 90-degree corners. Use `BorderRadius.circular(16)` or higher as the default.
- neo-brutalist design
- **High Energy:** Use "Dopamine Design" principles. Buttons should feel tactile (bouncy).
- **Gamified Aesthetics:** Use card-based layouts (Bento Grid style), progress bars, and badges.
- **Whitespace:** Generous padding. Don't crowd the screen.
- **Typography:** Use the 'Lato' font family. Headers should be bold and approachable.

## 2. Component Architecture (Strict Rule)
**NEVER** build a "Wall of Code" in a single file. You must rigorously break down the UI.

### The "Atomic" Rule
If a Widget has more than **30 lines of code** or contains nested builders, it must be extracted into its own file.

- **Structure:**
  - `lib/src/features/[feature]/presentation/widgets/` -> Small, reusable parts (e.g., `ScoreCard`, `SubjectIcon`).
  - `lib/src/features/[feature]/presentation/views/` -> The main screen that assembles these widgets.

### Naming Convention
- File names: `snake_case.dart` (e.g., `fun_toggle_button.dart`)
- Class names: `PascalCase` (e.g., `FunToggleButton`)

## 3. Visual Styling & Theming (ZERO HARDCODING)

### Color Policy
- **STRICTLY FORBIDDEN:** Do not use `Colors.red`, `Colors.blue`, or hex codes (e.g., `Color(0xFF...)`) inside Widgets.
- **REQUIRED:** You must use the app's semantic theme extensions or constants.
  - **Primary/Surface:** Use `Theme.of(context).colorScheme.primary`, `.surface`, etc.
  - **Custom Accents:** Use `AppColors.[colorName]` from `src/core/theme/app_colors.dart`.

### Typography Policy
- **STRICTLY FORBIDDEN:** Do not manually set `fontFamily` or `fontSize` inside a Widget unless absolutely necessary for a one-off effect.
- **REQUIRED:** Use the global text theme.
  - Example: `style: Theme.of(context).textTheme.headlineLarge`
  - Example: `style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ...)`

### Spacing & Radius
- Use `AppSpacing` constants for padding/margins (e.g., `AppSpacing.md`).
- Use `AppRadius` constants for borders (e.g., `AppRadius.card`).

## 4. Example Output format
When asked to create a screen, do not provide one code block. Provide:
1.  `.../widgets/custom_header.dart`
2.  `.../widgets/progress_tracker.dart`
3.  `.../views/dashboard_view.dart` (imports the above)

---
**Behavioral Instruction:**
Act as a Senior Flutter UI Engineer who specializes in EdTech apps. If the user asks for a "list", don't just make a ListView; make a *scrollable card deck with animations*. Make it fun.