import SwiftUI

// MARK: - App Preview  (matches Figma node 393:23935 "Active Product")

struct AppPreviewView: View {
    var body: some View {
        HStack(spacing: 0) {
            SidebarView()
                .frame(width: 218)
            ModalView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "FAFAFA"))
        .clipShape(RoundedRectangle(cornerRadius: 23.5))
        .overlay(
            RoundedRectangle(cornerRadius: 23.5)
                .strokeBorder(Color.black.opacity(0.07), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 4)
    }
}

// MARK: - Sidebar  (exact Figma: pt-23.5 pb-16.8 px-16.8, justify-between)

struct SidebarView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Top section ──────────────────────────
            VStack(alignment: .leading, spacing: 16.8) {

                // Traffic lights + branding
                VStack(alignment: .leading, spacing: 20.1) {
                    HStack(spacing: 4.7) {
                        Circle().fill(Color(hex: "FF5F57")).frame(width: 13.3, height: 13.3)
                        Circle().fill(Color(hex: "FFBD2E")).frame(width: 13.3, height: 13.3)
                        Circle().fill(Color(hex: "28C840")).frame(width: 13.3, height: 13.3)
                    }

                    VStack(alignment: .leading, spacing: 3.4) {
                        Text("Miniflow ™")
                            .font(.geist(15.1, weight: .medium))
                            .foregroundColor(.black)

                        HStack(spacing: 4.2) {
                            Text("by")
                                .font(.geist(6.7, weight: .medium))
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 5.5, weight: .bold))
                            Text("smallest.ai")
                                .font(.geist(6.7, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "010101").opacity(0.55))
                    }
                }

                // Nav items — gap 6.713px
                VStack(alignment: .leading, spacing: 6.7) {
                    SidebarNavItem(icon: "house",     label: "Home",       active: true)
                    SidebarNavItem(icon: "character", label: "Dictionary", active: false)
                    SidebarNavItem(icon: "command",   label: "Shortcuts",  active: false)
                }
            }
            .padding(.horizontal, 16.8)
            .padding(.top, 23.5)

            Spacer()

            // ── Bottom section ───────────────────────
            VStack(alignment: .leading, spacing: 16.8) {

                // Credits card  — bg rgba(0,0,0,0.7), border rgba(255,255,255,0.2)
                VStack(alignment: .leading, spacing: 13.4) {
                    VStack(alignment: .leading, spacing: 3.4) {
                        CreditsRow(value: "$10",  label: "Credits remaining")
                        CreditsRow(value: "100",  label: "Dictation minutes left")
                    }

                    // Manage Credits button
                    Text("Manage Credits")
                        .font(.geist(10.1, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30.2)
                        .background(Color.black.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(11.7)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 13.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 13.4)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.84)
                )

                // User row — two separate pills
                HStack {
                    // Avatar + name pill
                    HStack(spacing: 6.7) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "E8E8E8"))
                            Text("D")
                                .font(.geist(9, weight: .semibold))
                                .foregroundColor(.black.opacity(0.55))
                        }
                        .frame(width: 20.1, height: 20.1)

                        Text("Devansh")
                            .font(.geist(11.7, weight: .medium))
                            .foregroundColor(Color(hex: "737373"))
                    }
                    .padding(10.1)
                    .background(Color(hex: "FAFAFA"))
                    .clipShape(RoundedRectangle(cornerRadius: 10.1))

                    Spacer()

                    // Settings icon pill
                    Image(systemName: "gearshape")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.black.opacity(0.5))
                        .padding(10.1)
                        .background(Color(hex: "FAFAFA"))
                        .clipShape(RoundedRectangle(cornerRadius: 10.1))
                }
            }
            .padding(.horizontal, 16.8)
            .padding(.bottom, 16.8)
        }
        .frame(maxHeight: .infinity)
        .background(Color(hex: "FAFAFA"))
    }
}

struct CreditsRow: View {
    let value: String
    let label: String
    var body: some View {
        HStack(spacing: 3.4) {
            Text(value)
                .font(.geist(11.7, weight: .medium))
                .foregroundColor(.white)
            Text(label)
                .font(.geist(10.1, weight: .regular))
                .foregroundColor(Color(hex: "A1A1A1"))
        }
    }
}

struct SidebarNavItem: View {
    let icon: String
    let label: String
    let active: Bool

    var body: some View {
        HStack(spacing: 6.7) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(active ? .black : Color.black.opacity(0.5))
                .frame(width: 16.8, height: 16.8)
            Text(label)
                .font(.geist(11.75, weight: .medium))
                .foregroundColor(active ? .black : Color.black.opacity(0.6))
            Spacer()
        }
        .padding(10.1)
        .frame(height: 36.9)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(active ? Color.black.opacity(0.05) : Color.clear)
        )
    }
}

// MARK: - Modal  (exact Figma: bg-white, px-100.7, pt-50.35, pb-83.9, gap-26.85, rounded-16.78)

struct ModalView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26.85) {

                    // Greeting — 20.14px regular, black (exact Figma)
                    Text("Welcome to Miniflow, Devansh")
                        .font(.geist(20.1, weight: .regular))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Cards
                    VStack(spacing: 16.8) {
                        HoldFnCard()
                        StatsCard()
                    }

                    // History
                    HistorySection()
                }
                .padding(.horizontal, 100.7)
                .padding(.top, 50.35)
                .padding(.bottom, 83.9)
            }

            // Bottom fade — exact Figma: h-124.197, from transparent to white
            LinearGradient(
                colors: [.clear, .white],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 124.2)
            .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16.8))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        .padding(.vertical, 13.4)
        .padding(.trailing, 13.4)
    }
}

// MARK: - Hold Fn Card  (exact Figma spacing)

struct HoldFnCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 13.4) {
            // "Fn" badge — bg rgba(255,255,255,0.4), px-6.713 py-3.357, rounded-6.713, w-30.427
            ZStack {
                RoundedRectangle(cornerRadius: 6.7)
                    .fill(Color.white.opacity(0.4))
                Text("Fn")
                    .font(.geistMono(13.4))
                    .foregroundColor(.white)
            }
            .frame(width: 30.4, height: 24)

            VStack(alignment: .leading, spacing: 1.7) {
                Text("Hold Fn to start dictating")
                    .font(.geist(13.4, weight: .medium))
                    .foregroundColor(.white)

                Text("Speak Naturally -  Miniflow transcribes and executes your voice commands in any app")
                    .font(.geist(11.7, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20.1)
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
        .clipShape(RoundedRectangle(cornerRadius: 16.8))
        .overlay(
            RoundedRectangle(cornerRadius: 16.8)
                .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.84)
        )
    }
}

// MARK: - Stats Card  (exact Figma: bg #fafafa, p-20.14, rounded-16.78, gap-16.78)

struct StatsCard: View {
    private let stats: [(String, String)] = [
        ("84 WPM",   "Average Speed"),
        ("2,300",    "Words this week"),
        ("24",       "Tools called"),
        ("35 hours", "Saved this week")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(stats.enumerated()), id: \.offset) { i, stat in
                if i > 0 {
                    // Vertical divider — line rotated 90°
                    Rectangle()
                        .fill(Color.black.opacity(0.08))
                        .frame(width: 0.84, height: 26.85)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(stat.0)
                        .font(.geist(13.4, weight: .medium))
                        .foregroundColor(.black)
                    Text(stat.1)
                        .font(.geist(11.7, weight: .regular))
                        .foregroundColor(Color.black.opacity(0.4))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20.1)
        .background(Color(hex: "FAFAFA"))
        .clipShape(RoundedRectangle(cornerRadius: 16.8))
    }
}

// MARK: - History Section

struct HistorySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // "Today" header — px-16.78, py-16.78/17.62, border-b #F3F4F6
            HStack {
                Text("Today")
                    .font(.geist(11.7, weight: .medium))
                    .foregroundColor(Color(hex: "1F2937"))
                Spacer()
            }
            .padding(.horizontal, 16.8)
            .padding(.top, 16.8)
            .padding(.bottom, 17.6)
            .overlay(alignment: .bottom) {
                Color(hex: "F3F4F6").frame(height: 0.84)
            }

            // Row 1 — pink icon (clock), gap-20.14 on row
            HistoryRow(
                iconBg: Color(hex: "FCE7F3"),
                icon: "clock",
                iconColor: Color(hex: "EC4899"),
                command: "Can you open Chrome?",
                time: "02:34 PM"
            )

            // Row 2 — blue icon (message bubble)
            HistoryRow(
                iconBg: Color(hex: "DBEAFE"),
                icon: "bubble.left",
                iconColor: Color(hex: "3B82F6"),
                command: "As an enterprise user >> user is now having no option to add credit, auto recharge, avail coupons",
                time: "02:34 PM"
            )

            // Row 3
            HistoryRow(
                iconBg: Color(hex: "DBEAFE"),
                icon: "bubble.left",
                iconColor: Color(hex: "3B82F6"),
                command: "As an enterprise user >> user is now having no option to add credit, auto recharge, avail coupons",
                time: "02:34 PM"
            )

            // Row 4
            HistoryRow(
                iconBg: Color(hex: "DBEAFE"),
                icon: "bubble.left",
                iconColor: Color(hex: "3B82F6"),
                command: "As an enterprise user >> user is now having no option to add credit, auto recharge, avail coupons",
                time: "02:34 PM"
            )
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10.1))
        .overlay(
            RoundedRectangle(cornerRadius: 10.1)
                .strokeBorder(Color(hex: "F3F4F6"), lineWidth: 0.84)
        )
    }
}

struct HistoryRow: View {
    let iconBg: Color
    let icon: String
    let iconColor: Color
    let command: String
    let time: String

    var body: some View {
        HStack(alignment: .top, spacing: 20.1) {
            // Icon — colored rounded square, p-5.035, rounded-6.713
            ZStack {
                RoundedRectangle(cornerRadius: 6.7)
                    .fill(iconBg)
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(iconColor)
            }
            .frame(width: 23.5, height: 23.5)

            Text(command)
                .font(.geist(13.4, weight: .regular))
                .foregroundColor(Color(hex: "1F2937"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(time)
                .font(.geist(11.7, weight: .regular))
                .foregroundColor(Color(hex: "A1A1A1"))
                .fixedSize()
        }
        .padding(.horizontal, 16.8)
        .padding(.top, 16.8)
        .padding(.bottom, 17.6)
        .overlay(alignment: .bottom) {
            Color(hex: "F3F4F6").frame(height: 0.84)
        }
        .background(Color.white)
    }
}
