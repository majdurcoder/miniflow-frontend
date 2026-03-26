import SwiftUI
import AppKit

// MARK: - OTP Input View

struct OTPInputView: View {
    @Binding var digits: [String]
    var hasError: Bool = false

    @State private var focusedBox: Int = 0
    @State private var monitor: Any? = nil

    var body: some View {
        HStack(spacing: 12) {
            // Group 1 — boxes 0-2
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    OTPBox(digit: digits[i], focused: focusedBox == i, error: hasError)
                        .onTapGesture { focusedBox = i }
                }
            }

            // Dot separator
            Circle()
                .fill(Color.black.opacity(0.22))
                .frame(width: 6, height: 6)

            // Group 2 — boxes 3-5
            HStack(spacing: 8) {
                ForEach(3..<6, id: \.self) { i in
                    OTPBox(digit: digits[i], focused: focusedBox == i, error: hasError)
                        .onTapGesture { focusedBox = i }
                }
            }
        }
        .onAppear  { startMonitor() }
        .onDisappear { stopMonitor() }
    }

    // MARK: - Key event monitor

    private func startMonitor() {
        stopMonitor()
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [self] event in
            return handleKey(event)
        }
    }

    private func stopMonitor() {
        if let m = monitor { NSEvent.removeMonitor(m); monitor = nil }
    }

    private func handleKey(_ event: NSEvent) -> NSEvent? {
        let keyCode   = event.keyCode
        let chars     = event.characters ?? ""
        let modifiers = event.modifierFlags

        // Ignore if any real modifier is held (Cmd, Ctrl, Option)
        guard modifiers.intersection([.command, .control, .option]).isEmpty else {
            return event
        }

        // Backspace (keyCode 51)
        if keyCode == 51 {
            if digits[focusedBox].isEmpty && focusedBox > 0 {
                digits[focusedBox - 1] = ""
                focusedBox -= 1
            } else {
                digits[focusedBox] = ""
            }
            return nil
        }

        // Tab (keyCode 48) → next box; Shift+Tab → previous
        if keyCode == 48 {
            if modifiers.contains(.shift) {
                if focusedBox > 0 { focusedBox -= 1 }
            } else {
                if focusedBox < 5 { focusedBox += 1 }
            }
            return nil
        }

        // Digit input
        if let char = chars.first, char.isNumber {
            digits[focusedBox] = String(char)
            if focusedBox < 5 { focusedBox += 1 }
            return nil
        }

        return event   // pass anything else through
    }
}

// MARK: - Single OTP Box

struct OTPBox: View {
    let digit: String
    let focused: Bool
    let error: Bool

    private var border: Color {
        if error   { return Color(hex: "FF3B30").opacity(0.55) }
        if focused { return Color.black.opacity(0.22) }
        return Color(hex: "F0F0F0")
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "FAFAFA"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(border, lineWidth: 1)
                )

            Text(digit.isEmpty ? "0" : digit)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundColor(digit.isEmpty ? Color(hex: "A1A1A1") : .black)
        }
        .frame(width: 40, height: 40)
        .animation(.easeInOut(duration: 0.1), value: focused)
        .animation(.easeInOut(duration: 0.12), value: error)
    }
}
