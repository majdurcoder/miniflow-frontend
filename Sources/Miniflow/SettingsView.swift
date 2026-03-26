import SwiftUI

// MARK: - Settings Tab

enum SettingsTab: CaseIterable {
    case account, system, usage, billing

    var label: String {
        switch self {
        case .account: return "Account"
        case .system:  return "System"
        case .usage:   return "Usage"
        case .billing: return "Billing & Invoices"
        }
    }
    var icon: String {
        switch self {
        case .account: return "person.circle"
        case .system:  return "gearshape"
        case .usage:   return "arrow.clockwise.circle"
        case .billing: return "doc.text"
        }
    }
}

// MARK: - Settings Modal

// Outer: bg-#fafafa, border-#e5e7eb, rounded-28, pr-12
// Right panel: bg-white, rounded-20, flex-1, overflow-clip

struct SettingsModal: View {
    @Binding var selectedTab: SettingsTab
    let onClose: () -> Void
    let onAddCredits: () -> Void
    let onSignOut: () -> Void

    var body: some View {
        HStack(spacing: 0) {

            // ── Left sidebar  260px ────────────────────────────
            VStack(alignment: .leading, spacing: 20) {

                // Header block
                VStack(alignment: .leading, spacing: 4) {
                    Text("Settings")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "737373"))          

                    Text("Everything regarding your organisation can be found here.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(hex: "A1A1A1"))           // lighter gray
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Divider
                Color(hex: "E5E7EB").frame(height: 1)

                // Nav items  gap-4
                VStack(spacing: 4) {
                    ForEach(SettingsTab.allCases, id: \.label) { tab in
                        SettingsNavItem(tab: tab, isActive: selectedTab == tab) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 28)
            .frame(width: 260, alignment: .topLeading)
            .frame(maxHeight: .infinity, alignment: .topLeading)
            .background(Color(hex: "FAFAFA"))

            // ── Right white modal  flex-1, rounded-20, overflow-clip ──
            VStack(spacing: 0) {

                // Modal header
                HStack {
                    Text(selectedTab.label)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(hex: "010101"))

                    Spacer()

                    // X close button  36×36  rounded-12
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "737373"))
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)

                // Tab content — no divider, content starts right after header
                Group {
                    switch selectedTab {
                    case .account: AccountTab(onSignOut: onSignOut)
                    case .system:  SystemTab()
                    case .usage:   UsageTab(onAddCredits: onAddCredits)
                    case .billing: BillingTab()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .id(selectedTab)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.15), value: selectedTab)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            // 12px inset from top, right, bottom — butts against sidebar on the left
            .padding(.top, 12)
            .padding(.trailing, 12)
            .padding(.bottom, 12)
        }
        .frame(width: 880, height: 600)
        .background(Color(hex: "FAFAFA"))
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .strokeBorder(Color(hex: "E5E7EB"), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 48, x: 0, y: 16)
    }
}

// MARK: - Sidebar nav item

struct SettingsNavItem: View {
    let tab: SettingsTab
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: tab.icon)
                    .font(.system(size: 16, weight: isActive ? .medium : .regular))
                    .foregroundColor(isActive ? Color(hex: "010101") : Color(hex: "737373"))
                    .frame(width: 20, height: 20)

                Text(tab.label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isActive ? Color(hex: "010101") : Color(hex: "737373"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? Color(hex: "F5F5F5") : Color(hex: "FAFAFA"))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Account Tab

struct AccountTab: View {
    @State private var firstName = "Devansh"
    @State private var lastName  = "Pawan"
    let email = "ash@smallest.ai"
    let onSignOut: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // First Name
                    AccountFormRow(label: "First Name") {
                        AccountTextField(text: $firstName)
                    }
                    Divider().padding(.horizontal, 24)

                    // Last Name
                    AccountFormRow(label: "Last Name") {
                        AccountTextField(text: $lastName)
                    }
                    Divider().padding(.horizontal, 24)

                    // Owner Email (read-only)
                    AccountFormRow(label: "Owner Email") {
                        HStack {
                            Text(email)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "374151"))
                            Spacer()
                            Image(systemName: "link")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "A1A1A1"))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "F5F5F5"))
                                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color(hex: "E5E5E5"), lineWidth: 1))
                        )
                    }
                }
            }

            Spacer()

            // Footer
            HStack(spacing: 12) {
                SettingsOutlineButton(label: "Sign out") { onSignOut() }
                SettingsOutlineButton(label: "Delete account") {}
                Spacer()
                SettingsGrayButton(label: "Save") {}
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .padding(.top, 4)
    }
}

struct AccountFormRow<F: View>: View {
    let label: String
    @ViewBuilder let field: () -> F

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(hex: "374151"))
                .frame(width: 130, alignment: .leading)
            field()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
    }
}

struct AccountTextField: View {
    @Binding var text: String
    @FocusState private var focused: Bool

    var body: some View {
        TextField("", text: $text)
            .font(.system(size: 14))
            .foregroundColor(Color(hex: "374151"))
            .textFieldStyle(.plain)
            .focused($focused)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "F9F9F9"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(focused ? Color(hex: "009684").opacity(0.5) : Color(hex: "EBEBEB"), lineWidth: 1)
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: focused)
    }
}

// MARK: - System Tab

struct SystemTab: View {
    @State private var launchAtLogin       = false
    @State private var showInDock          = false
    @State private var dictationSounds     = false
    @State private var muteMusicListen     = false
    @State private var variableRecognition = false
    @State private var fileTagging         = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                SystemSectionLabel(title: "App settings").padding(.horizontal, 24).padding(.top, 20)
                SystemToggleRow(label: "Launch app at login",   isOn: $launchAtLogin)
                SystemToggleRow(label: "Show app in dock",       isOn: $showInDock)

                SystemSectionLabel(title: "Sound").padding(.horizontal, 24).padding(.top, 20)
                SystemToggleRow(label: "Dictation & notification sounds", isOn: $dictationSounds)
                SystemToggleRow(label: "Mute music while listening",      isOn: $muteMusicListen)

                SystemSectionLabel(title: "Extras").padding(.horizontal, 24).padding(.top, 20)
                SystemToggleRow(label: "Variable recognition (VS Code Cursor, Windsurf)", isOn: $variableRecognition)
                SystemToggleRow(label: "File tagging in chat",  isOn: $fileTagging)
            }
        }
    }
}

struct SystemSectionLabel: View {
    let title: String
    var body: some View {
        
        Text(title)
            .font(.system(size: 12, weight: .regular))
            .foregroundColor(Color(hex: "A1A1A1"))
            .padding(.bottom, 2)
    }
}

struct SystemToggleRow: View {
    let label: String
    @Binding var isOn: Bool
    var body: some View {
        HStack {
            
            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(hex: "010101"))
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .tint(Color(hex: "009684"))
                .labelsHidden()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Color(hex: "F3F4F6").frame(height: 1).padding(.horizontal, 24)
        }
    }
}

// MARK: - Usage Tab

struct UsageTab: View {
    let onAddCredits: () -> Void
    @State private var autoRecharge = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {

                // Stat cards
                HStack(spacing: 24) {
                    UsageStatCard(value: "$12",       label: "Credits Available",          detail: "These credits include your command actions and voice dictation minutes.")
                    UsageStatCard(value: "1500 mins", label: "Minutes of audio Available", detail: "These minutes can be used for voice dictation.")
                }
                .frame(height: 140)

                // Add Credits row
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Add Credits")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "010101"))
                        Text("Designed for teams managing large-scale production workloads.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "A1A1A1"))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(width: 264, alignment: .leading)
                    Spacer()
                    Button(action: onAddCredits) {
                        Text("Add Credits")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "010101"))
                            .padding(.horizontal, 16)
                            .frame(height: 36)
                            .background(Color(hex: "F5F5F5"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 64)

                // Auto Recharge row
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Auto Recharge")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "010101"))
                        Text("Enable to never get stalled because of credit lack.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "A1A1A1"))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(width: 235, alignment: .leading)
                    Spacer()
                    Toggle("", isOn: $autoRecharge)
                        .toggleStyle(.switch)
                        .tint(Color(hex: "009684"))
                        .labelsHidden()
                }
                .frame(height: 64)
            }
            .padding(.horizontal, 24)
            .padding(.top, 4)
            .padding(.bottom, 24)
        }
    }
}

struct UsageStatCard: View {
    let value: String
    let label: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text(value)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.black)

            VStack(alignment: .leading, spacing: 4) {
                // 14px regular #737373
                Text(label)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: "737373"))
                // 12px regular #a1a1a1
                Text(detail)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(hex: "A1A1A1"))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(hex: "FAFAFA"))
        .clipShape(RoundedRectangle(cornerRadius: 20))   // rounded-20, not 12
    }
}

// MARK: - Add Credits Modal

struct AddCreditsModal: View {
    let onClose: () -> Void
    @State private var amount = ""
    @State private var coupon = ""
    @State private var selectedPreset: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add Credits").font(.system(size: 16, weight: .semibold)).foregroundColor(.black)
                    Text("Set up payment method or redeem coupons\nto add credits to your organisation")
                        .font(.system(size: 12, weight: .regular)).foregroundColor(Color(hex: "737373"))
                }
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark").font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.black.opacity(0.45))
                        .frame(width: 24, height: 24).background(Color(hex: "F5F5F5")).clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(20)

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("Credits to Add").font(.system(size: 13, weight: .semibold)).foregroundColor(.black)

                HStack {
                    Text("USD").font(.system(size: 13, weight: .medium)).foregroundColor(Color(hex: "9CA3AF"))
                    TextField("0.00", text: $amount).font(.system(size: 14)).textFieldStyle(.plain)
                    Image(systemName: "dollarsign.circle").foregroundColor(Color(hex: "9CA3AF"))
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "F9F9F9")).overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color(hex: "E5E5E5"), lineWidth: 1)))

                HStack(spacing: 10) {
                    ForEach(["$20", "$50", "$100"], id: \.self) { p in
                        Button(action: { selectedPreset = p; amount = String(p.dropFirst()) }) {
                            Text(p).font(.system(size: 13, weight: .medium)).foregroundColor(.black)
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(selectedPreset == p ? Color(hex: "E8E8E8") : Color(hex: "F5F5F5"))
                                .clipShape(RoundedRectangle(cornerRadius: 9))
                                .overlay(RoundedRectangle(cornerRadius: 9).strokeBorder(Color(hex: "E5E5E5"), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack(spacing: 12) {
                    Color(hex: "E5E5E5").frame(height: 1)
                    Text("OR").font(.system(size: 12, weight: .medium)).foregroundColor(Color(hex: "9CA3AF"))
                    Color(hex: "E5E5E5").frame(height: 1)
                }

                Text("Coupon code").font(.system(size: 13, weight: .semibold)).foregroundColor(.black)

                HStack {
                    TextField("XCI90 QSWER", text: $coupon).font(.system(size: 14)).textFieldStyle(.plain)
                    Image(systemName: "ticket").foregroundColor(Color(hex: "9CA3AF"))
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "F9F9F9")).overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color(hex: "E5E5E5"), lineWidth: 1)))
            }
            .padding(.horizontal, 20).padding(.vertical, 16)

            Divider()

            HStack {
                Image(systemName: "minus").font(.system(size: 14)).foregroundColor(Color(hex: "9CA3AF"))
                Spacer()
                Button(action: {}) {
                    Text("Add Payment Method").font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                        .padding(.horizontal, 18).padding(.vertical, 11)
                        .background(LinearGradient(colors: [Color(hex: "66CDBA"), Color(hex: "009684")], startPoint: .topTrailing, endPoint: .bottomLeading))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20).padding(.vertical, 14)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.18), radius: 40, x: 0, y: 12)
        .frame(width: 360)
    }
}

// MARK: - Billing Tab


struct BillingTab: View {
    @State private var filter = "All"

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Payment Method + Card
            HStack(alignment: .top, spacing: 0) {
                // Left: description + button (justify-between, self-stretch)
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Payment Method")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "010101"))
                        Text("Charges for credits, auto recharge, and invoices will be billed to your main card.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "A1A1A1"))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    // "Add Payment Method" button — bg-#f5f5f5, h-40, rounded-12
                    Button(action: {}) {
                        Text("Add Payment Method")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "010101"))
                            .padding(.horizontal, 16)
                            .frame(height: 40)
                            .background(Color(hex: "F5F5F5"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                .frame(width: 258)

                Spacer()

                // Right: Card mockup  bg-#fafafa, border-#f5f5f5, rounded-17, 245×138
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "FAFAFA"))
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color(hex: "F5F5F5"), lineWidth: 1))

                    VStack(alignment: .leading, spacing: 0) {
                        // Card number top
                        Text("XXXX XXXX XXXX XXXX")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(hex: "E5E5E5"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 19)
                            .padding(.top, 22)

                        Spacer()

                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("EXPIRY")
                                    .font(.system(size: 5.65, weight: .medium, design: .monospaced))
                                    .foregroundColor(Color(hex: "E5E5E5"))
                                Text("09/21")
                                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                                    .foregroundColor(Color(hex: "E5E5E5"))
                            }
                            .padding(.leading, 19)
                            Spacer()
                            // + button centered
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(hex: "E5E5E5"))
                                .frame(width: 25, height: 25)
                                .background(Color(hex: "F5F5F5"))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .padding(.trailing, 19)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("CARDHOLDER")
                                .font(.system(size: 5.65, weight: .medium, design: .monospaced))
                                .foregroundColor(Color(hex: "E5E5E5"))
                            Text("Aditya Induraj")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(Color(hex: "E5E5E5"))
                        }
                        .padding(.leading, 19)
                        .padding(.bottom, 16)
                    }
                }
                .frame(width: 245, height: 138)
            }
            .frame(height: 138)
            .padding(.horizontal, 24)
            .padding(.top, 20)

            // Divider
            Color(hex: "F3F4F6").frame(height: 1).padding(.top, 20)

            // Invoice filter tabs
            HStack(spacing: 8) {
                ForEach(["All", "Pending", "Paid"], id: \.self) { f in
                    Button(action: { filter = f }) {
                        Text(f)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(filter == f ? Color(hex: "010101") : Color(hex: "737373"))
                            .padding(.horizontal, 16)
                            .frame(height: 40)
                            .background(filter == f ? Color(hex: "F5F5F5") : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                    // Vertical divider between items
                    if f != "Paid" {
                        Color(hex: "E5E7EB").frame(width: 1, height: 16)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Spacer()
        }
    }
}

// MARK: - Shared buttons

struct SettingsOutlineButton: View {
    let label: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "374151"))
                .padding(.horizontal, 16).frame(height: 36)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color(hex: "D1D5DB"), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct SettingsGrayButton: View {
    let label: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "010101"))
                .padding(.horizontal, 16).frame(height: 36)
                .background(Color(hex: "F5F5F5"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
