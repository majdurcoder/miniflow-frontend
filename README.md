# Miniflow — macOS App (SwiftUI)

A pixel-perfect SwiftUI implementation of the **Miniflow** macOS application — a voice-command productivity tool by [smallest.ai](https://smallest.ai).

---

## Screens Implemented

### Onboarding / Auth
| Screen | Description |
|--------|-------------|
| **Welcome** | Logo + "Continue with Google" + email field + Continue button |
| **Email Error** | Red border + error icon for invalid email |
| **OTP Verification** | 6-digit code input (2 groups of 3) with app preview backdrop |
| **OTP Error** | Red-bordered boxes on wrong code |

### Main App (post-login)
| Screen | Description |
|--------|-------------|
| **Home** | Greeting + Hold Fn card + stats + command history |
| **Dictionary** | Word mapping list with add / edit / delete + modal |
| **Shortcuts** | Text shortcut list with add / edit / delete + stacked modal |
| **Settings → Account** | Edit name, read-only email, sign out |
| **Settings → System** | Toggle switches for app, sound, and extras |
| **Settings → Usage** | Credit stats, Add Credits modal, Auto Recharge toggle |
| **Settings → Billing** | Payment method card, invoice filter tabs |

---

## Project Structure

```
Sources/Miniflow/
├── MiniflowApp.swift      # @main entry, window config (1200×800, hidden title bar)
├── ContentView.swift      # Auth flow: Welcome → Email → OTP → Main App
├── OTPInputView.swift     # 6-box OTP input with NSEvent keyboard monitor
├── AppPreviewView.swift   # Mini Miniflow preview shown during onboarding
├── MainAppView.swift      # Full app: sidebar nav + Home / Dictionary / Shortcuts views
├── SettingsView.swift     # Settings modal with 4 tabs
└── Extensions.swift       # Color(hex:), design tokens, font helpers
```

---

## Tech Stack

- **Language**: Swift 5.9
- **Framework**: SwiftUI (macOS 14+)
- **Architecture**: Single-window app, state-driven navigation, `@State` / `@Binding`
- **Build**: Swift Package Manager (`Package.swift`)

---

## Getting Started

### Requirements
- macOS 14 (Sonoma) or later
- Xcode 15+

### Run

1. Clone the repo
   ```bash
   git clone https://github.com/majdurcoder/miniflow-frontend.git
   cd miniflow-frontend
   ```

2. Open in Xcode
   ```
   File → Open → select the folder (Xcode detects Package.swift automatically)
   ```

3. Select scheme **Miniflow** → destination **My Mac** → press **⌘R**

---

## Design System

| Token | Value |
|-------|-------|
| Teal gradient | `#66CDBA` → `#009684` |
| Sidebar background | `#FAFAFA` |
| Sidebar border | `#E5E7EB` |
| Text primary | `#010101` |
| Text secondary | `#737373` |
| Text tertiary | `#A1A1A1` |
| Traffic Red | `#FF5F57` |
| Traffic Yellow | `#FFBD2E` |
| Traffic Green | `#28C840` |
| OTP box bg | `#FAFAFA` / border `#F5F5F5` |
| Error red | `#FF3B30` |

### Typography
| Token | Size | Weight |
|-------|------|--------|
| `text-2xl/medium` | 24px | 500 |
| `text-lg/medium` | 18px | 500 |
| `text-sm/medium` | 14px | 500 |
| `text-sm/regular` | 14px | 400 |
| `text-xs/medium` | 12px | 500 |
| `text-xs/regular` | 12px | 400 |

> The design uses **Geist** / **Geist Mono** by Vercel. The app falls back to SF Pro / system monospaced. To use the real fonts, download from [vercel.com/font](https://vercel.com/font) and add them as bundle resources.

---

## Custom Font (Optional)

1. Download Geist Regular, Medium, and Geist Mono from [vercel.com/font](https://vercel.com/font)
2. Add `.otf` files to the Xcode target
3. In `Extensions.swift`, replace `Font.system(size:weight:)` with `Font.custom("Geist-Regular", size:)` / `Font.custom("Geist-Medium", size:)`

---

## License

MIT
