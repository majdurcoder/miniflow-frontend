import SwiftUI

// MARK: - Tab

enum AppTab { case home, dictionary, shortcuts }

// MARK: - Data Models

struct DictionaryEntry: Identifiable {
    var id = UUID()
    var misspelling: String
    var correction: String
}

struct ShortcutEntry: Identifiable {
    var id = UUID()
    var trigger: String
    var expansion: String
}

struct HistoryEntry: Identifiable {
    let id = UUID()
    let iconBg: Color
    let iconName: String
    let iconColor: Color
    let command: String
    let time: String
}

// MARK: - Modal State

enum ModalMode { case none, addDict, editDict(DictionaryEntry), addShortcut, editShortcut(ShortcutEntry) }

// MARK: - Main App View

struct MainAppView: View {
    @State private var selectedTab: AppTab = .home
    @State private var dictEntries: [DictionaryEntry] = [
        DictionaryEntry(misspelling: "Samir",    correction: "Sameer"),
        DictionaryEntry(misspelling: "Devanche", correction: "Devansh")
    ]
    @State private var shortcuts: [ShortcutEntry] = [
        ShortcutEntry(trigger: "My email address", expansion: "rounak@smallest.ai"),
        ShortcutEntry(trigger: "smallest.ai",      expansion: "https://smallest.ai/")
    ]
    // Dictionary/Shortcut modal
    @State private var modal: ModalMode = .none
    @State private var modalLeft  = ""
    @State private var modalRight = ""

    // Settings modal
    @State private var showSettings    = false
    @State private var settingsTab: SettingsTab = .account
    // Add Credits — lifted to top level so overlay covers full screen
    @State private var showAddCredits  = false
    // Low credits state — true when user is running low
    @State private var isLowCredits    = false

    let onSignOut: () -> Void

    var isShowingDictModal: Bool {
        if case .none = modal { return false }
        return true
    }

    var isShowingAnyModal: Bool { isShowingDictModal || showSettings || showAddCredits }

    var body: some View {
        ZStack {
            // ── App chrome ──────────────────────────────────────
            HStack(spacing: 0) {
                AppSidebar(
                    selectedTab: $selectedTab,
                    isLowCredits: isLowCredits,
                    onSignOut: onSignOut,
                    onManageCredits: { settingsTab = .usage;   showSettings = true },
                    onOpenSettings:  { settingsTab = .account; showSettings = true },
                    onAddCredits:    { showAddCredits = true }
                )
                    .frame(width: 260)

                ZStack {
                    Color.white
                    switch selectedTab {
                    case .home:
                        HomeView(isLowCredits: isLowCredits)
                            .transition(.opacity)
                    case .dictionary:
                        DictionaryView(
                            entries: $dictEntries,
                            onAdd:  { openModal(.addDict) },
                            onEdit: { openModal(.editDict($0)) },
                            onDelete: { e in dictEntries.removeAll { $0.id == e.id } }
                        ).transition(.opacity)
                    case .shortcuts:
                        ShortcutsView(
                            shortcuts: $shortcuts,
                            onAdd:  { openModal(.addShortcut) },
                            onEdit: { openModal(.editShortcut($0)) },
                            onDelete: { s in shortcuts.removeAll { $0.id == s.id } }
                        ).transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
            }
            .blur(radius: isShowingAnyModal ? 3 : 0)

            // ── Dictionary / Shortcut modal ──────────────────────
            if isShowingDictModal {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { closeModal() }
                    .transition(.opacity)

                modalView
                    .transition(.scale(scale: 0.96).combined(with: .opacity))
            }

            // ── Settings modal ───────────────────────────────────
            if showSettings {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { showSettings = false }
                    .transition(.opacity)

                SettingsModal(
                    selectedTab: $settingsTab,
                    onClose: { showSettings = false },
                    onAddCredits: { showAddCredits = true },
                    onSignOut: {
                        showSettings = false
                        onSignOut()
                    }
                )
                .transition(.scale(scale: 0.96).combined(with: .opacity))
            }

            // ── Add Credits — full-screen overlay ────────────────
            if showAddCredits {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { showAddCredits = false }
                    .transition(.opacity)

                AddCreditsModal(onClose: { showAddCredits = false })
                    .transition(.scale(scale: 0.96).combined(with: .opacity))
            }

            // ── Low credits demo toggle (dev helper, top-right) ──
            VStack {
                HStack {
                    Spacer()
                    Button(action: { withAnimation { isLowCredits.toggle() } }) {
                        Label(isLowCredits ? "Normal Credits" : "Simulate Low Credits",
                              systemImage: isLowCredits ? "checkmark.circle" : "exclamationmark.triangle")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(isLowCredits ? Color(hex: "009684") : Color(hex: "737373"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "F5F5F5"))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 10)
                    .padding(.trailing, 14)
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.2), value: isShowingDictModal)
        .animation(.easeInOut(duration: 0.2), value: showSettings)
        .animation(.easeInOut(duration: 0.2), value: showAddCredits)
    }

    // MARK: - Modal content

    @ViewBuilder
    private var modalView: some View {
        switch modal {
        case .addDict:
            WordModal(title: "Add new word to dictionary", leftPlaceholder: "Misspelling", rightPlaceholder: "Correct Spelling", leftValue: $modalLeft, rightValue: $modalRight, onCancel: closeModal, onConfirm: saveDictEntry)
        case .editDict:
            WordModal(title: "Edit dictionary entry", leftPlaceholder: "Misspelling", rightPlaceholder: "Correct Spelling", leftValue: $modalLeft, rightValue: $modalRight, onCancel: closeModal, onConfirm: saveDictEntry)
        case .addShortcut:
            ShortcutModal(title: "Add a new shortcut", shortcut: $modalLeft, expansion: $modalRight, onCancel: closeModal, onConfirm: saveShortcut)
        case .editShortcut:
            ShortcutModal(title: "Edit shortcut", shortcut: $modalLeft, expansion: $modalRight, onCancel: closeModal, onConfirm: saveShortcut)
        case .none:
            EmptyView()
        }
    }

    // MARK: - Actions

    private func openModal(_ mode: ModalMode) {
        switch mode {
        case .editDict(let e):   modalLeft = e.misspelling; modalRight = e.correction
        case .editShortcut(let s): modalLeft = s.trigger;  modalRight = s.expansion
        default: modalLeft = ""; modalRight = ""
        }
        modal = mode
    }

    private func closeModal() { modal = .none }

    private func saveDictEntry() {
        guard !modalLeft.isEmpty, !modalRight.isEmpty else { return }
        if case .editDict(let e) = modal, let i = dictEntries.firstIndex(where: { $0.id == e.id }) {
            dictEntries[i].misspelling = modalLeft
            dictEntries[i].correction  = modalRight
        } else {
            dictEntries.append(DictionaryEntry(misspelling: modalLeft, correction: modalRight))
        }
        closeModal()
    }

    private func saveShortcut() {
        guard !modalLeft.isEmpty, !modalRight.isEmpty else { return }
        if case .editShortcut(let s) = modal, let i = shortcuts.firstIndex(where: { $0.id == s.id }) {
            shortcuts[i].trigger   = modalLeft
            shortcuts[i].expansion = modalRight
        } else {
            shortcuts.append(ShortcutEntry(trigger: modalLeft, expansion: modalRight))
        }
        closeModal()
    }
}

// MARK: - Normal Credits Card

struct NormalCreditsCard: View {
    let onManageCredits: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("$10").font(.system(size: 12, weight: .semibold)).foregroundColor(.white)
                    Text("Credits remaining").font(.system(size: 11, weight: .regular)).foregroundColor(Color(hex: "A1A1A1"))
                }
                HStack(spacing: 6) {
                    Text("100").font(.system(size: 12, weight: .semibold)).foregroundColor(.white)
                    Text("Dictation minutes left").font(.system(size: 11, weight: .regular)).foregroundColor(Color(hex: "A1A1A1"))
                }
            }
            Button(action: onManageCredits) {
                Text("Manage Credits")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color.black.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Low Credits Warning Card
// Figma: bg-rgba(0,0,0,0.6), border rgba(255,255,255,0.2), rounded-16, p-12
// Decorative pink glow blob at bottom-left

struct LowCreditsCard: View {
    let onAddCredits: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Decorative pinkish glow (Figma: imgEllipse1 at bottom-left offset)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "FF6B8A").opacity(0.55), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 62
                    )
                )
                .frame(width: 125, height: 125)
                .offset(x: -47, y: 88)
                .blur(radius: 8)

            // Card content
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    // "You're running low." — 14px medium white
                    Text("You're running low.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)

                // Mixed-color description
                    let desc = Text("You have ").foregroundColor(.white.opacity(0.5))
                        + Text("$2.00 ").foregroundColor(.white)
                        + Text("or ").foregroundColor(.white.opacity(0.5))
                        + Text("23 mins").foregroundColor(.white)
                        + Text(" remaining.\n").foregroundColor(.white.opacity(0.5))
                        + Text("Add more to keep building.").foregroundColor(.white.opacity(0.5))
                    desc
                        .font(.system(size: 12, weight: .regular))
                        .lineSpacing(2)
                }

                // "Add Credits" button — bg rgba(0,0,0,0.2), h-36, rounded-12, 12px Inter medium
                Button(action: onAddCredits) {
                    Text("Add Credits")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.black.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
        )
        .clipped()
    }
}

// MARK: - Sidebar

struct AppSidebar: View {
    @Binding var selectedTab: AppTab
    var isLowCredits: Bool = false
    let onSignOut: () -> Void
    let onManageCredits: () -> Void
    let onOpenSettings: () -> Void
    let onAddCredits: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Top ──────────────────────────────────
            VStack(alignment: .leading, spacing: 0) {
                // Traffic lights + branding
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 6) {
                        Circle().fill(Color(hex: "FF5F57")).frame(width: 13, height: 13)
                        Circle().fill(Color(hex: "FFBD2E")).frame(width: 13, height: 13)
                        Circle().fill(Color(hex: "28C840")).frame(width: 13, height: 13)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Miniflow ™")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        HStack(spacing: 3) {
                            Text("by")
                                .font(.system(size: 9, weight: .medium))
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 7, weight: .bold))
                            Text("smallest.ai")
                                .font(.system(size: 9, weight: .medium))
                        }
                        .foregroundColor(Color.black.opacity(0.4))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 24)

                // Nav items
                VStack(spacing: 4) {
                    SidebarTab(icon: "house",     label: "Home",       tab: .home,       selected: selectedTab) { selectedTab = .home }
                    SidebarTab(icon: "character", label: "Dictionary", tab: .dictionary, selected: selectedTab) { selectedTab = .dictionary }
                    SidebarTab(icon: "command",   label: "Shortcuts",  tab: .shortcuts,  selected: selectedTab) { selectedTab = .shortcuts }
                }
                .padding(.horizontal, 20)
            }

            Spacer()

            // ── Bottom ───────────────────────────────
            VStack(alignment: .leading, spacing: 20) {

                // Credits card — normal or low-credits warning
                if isLowCredits {
                    LowCreditsCard(onAddCredits: onAddCredits)
                } else {
                    NormalCreditsCard(onManageCredits: onManageCredits)
                }

                // User row
                HStack(spacing: 0) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(hex: "E0E0E0"))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text("D")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.black.opacity(0.6))
                            )
                        Text("Devansh")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "737373"))
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(Color(hex: "F5F5F5"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    Spacer()

                    Button(action: onOpenSettings) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.black.opacity(0.5))
                            .padding(10)
                            .background(Color(hex: "F5F5F5"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .help("Settings")
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxHeight: .infinity)
        .background(Color(hex: "FAFAFA"))
        .overlay(alignment: .trailing) {
            Color.black.opacity(0.06).frame(width: 1)
        }
    }
}

struct SidebarTab: View {
    let icon: String
    let label: String
    let tab: AppTab
    let selected: AppTab
    let action: () -> Void

    var isActive: Bool { selected == tab }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: isActive ? .medium : .regular))
                    .foregroundColor(isActive ? .black : Color.black.opacity(0.45))
                    .frame(width: 20, height: 20)

                Text(label)
                    .font(.system(size: 14, weight: isActive ? .medium : .regular))
                    .foregroundColor(isActive ? .black : Color.black.opacity(0.55))

                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isActive ? Color.black.opacity(0.06) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Home View

struct HomeView: View {
    var isLowCredits: Bool = false

    private let history: [HistoryEntry] = [
        HistoryEntry(iconBg: Color(hex: "FCE7F3"), iconName: "command",     iconColor: Color(hex: "EC4899"), command: "Can you open Chrome?", time: "02:34 PM"),
        HistoryEntry(iconBg: Color(hex: "DBEAFE"), iconName: "bubble.left", iconColor: Color(hex: "3B82F6"), command: "As an enterprise user >> user is now having no option to add credit, auto recharge, avail coupons and add payment method which earlier we had", time: "02:34 PM"),
        HistoryEntry(iconBg: Color(hex: "DBEAFE"), iconName: "bubble.left", iconColor: Color(hex: "3B82F6"), command: "As an enterprise user >> user is now having no option to add credit, auto recharge, avail coupons and add payment method which earlier we had", time: "02:34 PM"),
        HistoryEntry(iconBg: Color(hex: "DBEAFE"), iconName: "bubble.left", iconColor: Color(hex: "3B82F6"), command: "As an enterprise user >> user is now having no option to add credit, auto recharge, avail coupons and add payment method which earlier we had", time: "02:34 PM")
    ]

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning, Devansh"
        case 12..<18: return "Good afternoon, Devansh"
        case 18..<23: return "Good evening, Devansh"
        default:      return "Good night, Devansh"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {

                // Time-based greeting when low on credits; welcome otherwise
                Text(isLowCredits ? greeting : "Welcome to Miniflow, Devansh")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(.black)

                VStack(spacing: 16) {
                    // Hold Fn card
                    HomeFnCard()

                    // Stats
                    HomeStatsCard()
                }

                // History
                VStack(alignment: .leading, spacing: 16) {
                    Text("Today")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "1F2937"))

                    VStack(spacing: 0) {
                        ForEach(history) { entry in
                            HomeHistoryRow(entry: entry)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color(hex: "F3F4F6"), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 120)
            .padding(.top, 60)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct HomeFnCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.35))
                Text("Fn")
                    .font(.system(size: 15, weight: .regular, design: .monospaced))
                    .foregroundColor(.white)
            }
            .frame(width: 36, height: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text("Hold Fn to start dictating")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text("Speak Naturally -  Miniflow transcribes and executes your voice commands in any app")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "66CDBA"), location: 0.0),
                    .init(color: Color(hex: "009684"), location: 1.0)
                ],
                startPoint: UnitPoint(x: 0.95, y: 0.05),
                endPoint: UnitPoint(x: 0.05, y: 0.95)
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
        )
    }
}

struct HomeStatsCard: View {
    private let stats = [("84 WPM","Average Speed"), ("2,300","Words this week"), ("24","Tools called"), ("35 hours","Saved this week")]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(stats.enumerated()), id: \.offset) { i, s in
                if i > 0 { Color.black.opacity(0.08).frame(width: 1, height: 32) }
                VStack(alignment: .leading, spacing: 4) {
                    Text(s.0).font(.system(size: 15, weight: .semibold)).foregroundColor(.black)
                    Text(s.1).font(.system(size: 12, weight: .regular)).foregroundColor(.black.opacity(0.4))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
        }
        .background(Color(hex: "FAFAFA"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct HomeHistoryRow: View {
    let entry: HistoryEntry

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(entry.iconBg)
                Image(systemName: entry.iconName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(entry.iconColor)
            }
            .frame(width: 28, height: 28)

            Text(entry.command)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(hex: "1F2937"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(entry.time)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color(hex: "A1A1A1"))
                .fixedSize()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(Color.white)
        .overlay(alignment: .bottom) {
            Color(hex: "F3F4F6").frame(height: 1)
        }
    }
}

// MARK: - Dictionary View

struct DictionaryView: View {
    @Binding var entries: [DictionaryEntry]
    let onAdd: () -> Void
    let onEdit: (DictionaryEntry) -> Void
    let onDelete: (DictionaryEntry) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                HStack {
                    Text("Dictionary").font(.system(size: 28, weight: .regular)).foregroundColor(.black)
                    Spacer()
                    AddNewButton(action: onAdd)
                }

                InfoCard(
                    icon: "a.magnify",
                    title: "Your words, always spelled right",
                    subtitle: "MiniFlow learns your unique words and names as you speak, or add them yourself. From client names to industry jargon, MiniFlow gets every word right."
                )

                VStack(spacing: 12) {
                    ForEach(entries) { entry in
                        MappingRow(
                            source: entry.misspelling,
                            target: entry.correction,
                            onEdit:   { onEdit(entry) },
                            onDelete: { onDelete(entry) }
                        )
                    }
                }
            }
            .padding(.horizontal, 120)
            .padding(.top, 60)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Shortcuts View

struct ShortcutsView: View {
    @Binding var shortcuts: [ShortcutEntry]
    let onAdd: () -> Void
    let onEdit: (ShortcutEntry) -> Void
    let onDelete: (ShortcutEntry) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                HStack {
                    Text("Shortcuts").font(.system(size: 28, weight: .regular)).foregroundColor(.black)
                    Spacer()
                    AddNewButton(action: onAdd)
                }

                InfoCard(
                    icon: "command.square",
                    title: "Say it once. Use it forever",
                    subtitle: "Save your most-used text as shortcuts, links, intros, sign-offs, addresses and speak them into any app in seconds. No retyping, no hunting through old messages."
                )

                VStack(spacing: 12) {
                    ForEach(shortcuts) { s in
                        MappingRow(
                            source: s.trigger,
                            target: s.expansion,
                            onEdit:   { onEdit(s) },
                            onDelete: { onDelete(s) }
                        )
                    }
                }
            }
            .padding(.horizontal, 120)
            .padding(.top, 60)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Shared Components

struct AddNewButton: View {
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .semibold))
                Text("Add New")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: "66CDBA"), location: 0.0),
                        .init(color: Color(hex: "009684"), location: 1.0)
                    ],
                    startPoint: UnitPoint(x: 0.95, y: 0.05),
                    endPoint: UnitPoint(x: 0.05, y: 0.95)
                )
                .opacity(hovered ? 0.88 : 1.0)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .scaleEffect(hovered ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.12), value: hovered)
        .onHover { hovered = $0 }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.3))
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "66CDBA"), location: 0.0),
                    .init(color: Color(hex: "009684"), location: 1.0)
                ],
                startPoint: UnitPoint(x: 0.95, y: 0.05),
                endPoint: UnitPoint(x: 0.05, y: 0.95)
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.white.opacity(0.18), lineWidth: 1))
    }
}

struct MappingRow: View {
    let source: String
    let target: String
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var hovered = false

    var body: some View {
        HStack(spacing: 12) {
            Text(source)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(hex: "1F2937"))

            Image(systemName: "arrow.right")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.black.opacity(0.35))

            Text(target)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(hex: "1F2937"))

            Spacer()

            if hovered {
                HStack(spacing: 8) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 13))
                            .foregroundColor(Color.black.opacity(0.45))
                    }
                    .buttonStyle(.plain)

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "EF4444").opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color(hex: "F0F0F0"), lineWidth: 1)
        )
        .onHover { hovered = $0 }
        .animation(.easeInOut(duration: 0.15), value: hovered)
    }
}

// MARK: - Word / Shortcut Modal

struct WordModal: View {
    let title: String
    let leftPlaceholder: String
    let rightPlaceholder: String
    @Binding var leftValue: String
    @Binding var rightValue: String
    let onCancel: () -> Void
    let onConfirm: () -> Void

    @FocusState private var focusLeft: Bool

    var canSave: Bool { !leftValue.trimmingCharacters(in: .whitespaces).isEmpty && !rightValue.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.black.opacity(0.4))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 20)

            // Inputs
            HStack(spacing: 12) {
                ModalTextField(placeholder: leftPlaceholder, text: $leftValue)
                    .focused($focusLeft)

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.black.opacity(0.35))

                ModalTextField(placeholder: rightPlaceholder, text: $rightValue)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)

            // Footer
            HStack {
                Spacer()
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "374151"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(Color(hex: "F5F5F5"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)

                Button(action: onConfirm) {
                    Text("Add New")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(
                            canSave ?
                            LinearGradient(colors: [Color(hex: "66CDBA"), Color(hex: "009684")], startPoint: .topTrailing, endPoint: .bottomLeading) :
                            LinearGradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .disabled(!canSave)
                .keyboardShortcut(.return, modifiers: [])
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 32, x: 0, y: 8)
        .frame(width: 540)
        .onAppear { focusLeft = true }
    }
}

// MARK: - Shortcut Modal (stacked layout with multi-line expansion)

struct ShortcutModal: View {
    let title: String
    @Binding var shortcut: String
    @Binding var expansion: String
    let onCancel: () -> Void
    let onConfirm: () -> Void

    @FocusState private var focusShortcut: Bool

    var canSave: Bool {
        !shortcut.trimmingCharacters(in: .whitespaces).isEmpty &&
        !expansion.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack(alignment: .top) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.black.opacity(0.45))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 28)
            .padding(.top, 28)
            .padding(.bottom, 24)

            // Shortcut field (single line)
            TextField("Shortcut", text: $shortcut)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.black)
                .textFieldStyle(.plain)
                .focused($focusShortcut)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "F9F9F9"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    focusShortcut ? Color(hex: "009684").opacity(0.5) : Color(hex: "E8E8E8"),
                                    lineWidth: 1
                                )
                        )
                )
                .padding(.horizontal, 28)
                .animation(.easeInOut(duration: 0.15), value: focusShortcut)

            Spacer().frame(height: 12)

            // Expansion field (multi-line)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "F9F9F9"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color(hex: "E8E8E8"), lineWidth: 1)
                    )

                if expansion.isEmpty {
                    Text("Expansion")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color(hex: "A1A1A1"))
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                }

                TextEditor(text: $expansion)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.black)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
            }
            .frame(height: 140)
            .padding(.horizontal, 28)

            Spacer().frame(height: 24)

            // Footer buttons
            HStack(spacing: 10) {
                Spacer()

                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "374151"))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 11)
                        .background(Color(hex: "F0F0F0"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)

                Button(action: onConfirm) {
                    Text("Add New")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 11)
                        .background(
                            canSave
                            ? LinearGradient(colors: [Color(hex: "66CDBA"), Color(hex: "009684")], startPoint: .topTrailing, endPoint: .bottomLeading)
                            : LinearGradient(colors: [Color.gray.opacity(0.35), Color.gray.opacity(0.35)], startPoint: .top, endPoint: .bottom)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(!canSave)
                .keyboardShortcut(.return, modifiers: [.command])
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 28)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.12), radius: 40, x: 0, y: 12)
        .frame(width: 560)
        .onAppear { focusShortcut = true }
    }
}

// MARK: - Modal Text Field

struct ModalTextField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState private var focused: Bool

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(.black)
            .textFieldStyle(.plain)
            .focused($focused)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "FAFAFA"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(focused ? Color(hex: "009684").opacity(0.5) : Color(hex: "E5E5E5"), lineWidth: 1)
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: focused)
    }
}
