import SwiftUI

// MARK: - App Step

enum AppStep: Equatable {
    case auth
    case otp
    case success
}

// MARK: - Root

struct ContentView: View {
    @State private var step: AppStep = .auth
    @State private var email = ""
    @State private var emailError = false
    @State private var otpDigits: [String] = Array(repeating: "", count: 6)
    @State private var otpError = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            switch step {
            case .auth:
                AuthScreen(
                    email: $email,
                    hasError: $emailError,
                    onContinue: handleContinue,
                    onGoogle: handleGoogle
                )
                .transition(.opacity)

            case .otp:
                OTPScreen(
                    digits: $otpDigits,
                    hasError: $otpError,
                    email: email,
                    onResend: handleResend,
                    onBack: handleBack,
                    onNext: { withAnimation(.easeInOut(duration: 0.4)) { step = .success } }
                )
                .transition(.opacity)

            case .success:
                SuccessScreen(onSignOut: handleSignOut)
                    .transition(.opacity)
            }
        }
        .frame(width: 1200, height: 800)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .strokeBorder(Color.black.opacity(0.75), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.3), value: step)
        .onChange(of: otpDigits) { _, digits in
            guard digits.allSatisfy({ !$0.isEmpty }) else { return }
            // Any 6 digits accepted — advance to success after brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut(duration: 0.4)) { step = .success }
            }
        }
    }

    // MARK: Actions

    private func handleContinue() {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let valid = trimmed.contains("@") && trimmed.contains(".")
        if valid {
            emailError = false
            otpDigits = Array(repeating: "", count: 6)
            otpError = false
            withAnimation { step = .otp }
        } else {
            withAnimation(.easeInOut(duration: 0.2)) { emailError = true }
        }
    }

    private func handleGoogle() {
        // Frontend only — go straight to OTP
        email = "user@google.com"
        emailError = false
        otpDigits = Array(repeating: "", count: 6)
        otpError = false
        withAnimation { step = .otp }
    }

    private func handleResend() {
        withAnimation { otpDigits = Array(repeating: "", count: 6) }
        otpError = false
    }

    private func handleSignOut() {
        email = ""
        otpDigits = Array(repeating: "", count: 6)
        otpError = false
        emailError = false
        withAnimation(.easeInOut(duration: 0.4)) { step = .auth }
    }

    private func handleBack() {
        withAnimation { step = .auth }
        otpDigits = Array(repeating: "", count: 6)
        otpError = false
    }
}

// MARK: - Auth Screen

struct AuthScreen: View {
    @Binding var email: String
    @Binding var hasError: Bool
    let onContinue: () -> Void
    let onGoogle: () -> Void

    @FocusState private var emailFocused: Bool

    var canContinue: Bool { !email.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ZStack {
            // Logo pinned near top-center
            VStack {
                Spacer().frame(height: 124)
                MiniflowLogo()
                Spacer()
            }

            // Form centered
            VStack(spacing: 24) {
                // Heading
                VStack(spacing: 6) {
                    Text("Let's get you started")
                        .font(.geist(24, weight: .regular))
                        .foregroundColor(.black)

                    VStack(spacing: 0) {
                        Text("Talk your way through any app and let")
                        Text("AI take care of the heavy lifting with just a command!")
                    }
                    .font(.geist(16, weight: .regular))
                    .foregroundColor(Color(hex: "737373"))
                    .multilineTextAlignment(.center)
                }

                // Form fields
                VStack(spacing: 30) {
                    // Continue with Google
                    Button(action: onGoogle) {
                        HStack(spacing: 8) {
                            // Google "G" icon
                            GoogleIcon()
                                .frame(width: 18, height: 18)

                            Text("Continue with Google")
                                .font(.geist(14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
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
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                    // OR divider
                    HStack(spacing: 14) {
                        Rectangle()
                            .fill(Color(hex: "E5E5E5"))
                            .frame(height: 1)
                        Text("OR")
                            .font(.geist(14, weight: .medium))
                            .foregroundColor(Color(hex: "A1A1A1"))
                        Rectangle()
                            .fill(Color(hex: "E5E5E5"))
                            .frame(height: 1)
                    }

                    // Email field + Continue
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Email")
                                .font(.geist(14, weight: .regular))
                                .foregroundColor(Color(hex: "171717"))

                            EmailField(
                                email: $email,
                                hasError: hasError,
                                isFocused: _emailFocused,
                                onSubmit: onContinue
                            )
                            .onChange(of: email) { _, _ in
                                if hasError { hasError = false }
                            }
                        }

                        // Continue button
                        Button(action: onContinue) {
                            Text("Continue")
                                .font(.geist(14, weight: .medium))
                                .foregroundColor(Color(hex: "010101"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(canContinue ? Color(hex: "EBEBEB") : Color(hex: "F5F5F5"))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(Color(hex: "F5F5F5"), lineWidth: 1.24)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(!canContinue)
                    }
                }
            }
            .frame(width: 420)
        }
        .onAppear { emailFocused = true }
    }
}

// MARK: - Email Field

struct EmailField: View {
    @Binding var email: String
    let hasError: Bool
    @FocusState var isFocused: Bool
    let onSubmit: () -> Void

    var borderColor: Color {
        if hasError   { return Color(hex: "FF3B30").opacity(0.5) }
        if isFocused  { return Color(hex: "A1A1A1") }
        return Color(hex: "F5F5F5")
    }

    var body: some View {
        HStack(spacing: 8) {
            TextField("Johndoe@piedpiper.com", text: $email)
                .font(.geist(14, weight: .regular))
                .foregroundColor(.black)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .onSubmit(onSubmit)

            HStack(spacing: 4) {
                // Return key hint
                Image(systemName: "arrow.turn.down.left")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "A1A1A1"))
                    .opacity(isFocused && !email.isEmpty ? 1 : 0)

                // Error indicator or clear button
                if hasError {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "FF3B30"))
                        .transition(.scale.combined(with: .opacity))
                } else if !email.isEmpty {
                    Button(action: { email = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "A1A1A1"))
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.15), value: hasError)
            .animation(.easeInOut(duration: 0.15), value: email.isEmpty)
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "FAFAFA"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(borderColor, lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: 0.15), value: isFocused)
        .animation(.easeInOut(duration: 0.15), value: hasError)
    }
}

// MARK: - Google Icon (simplified colored G)

struct GoogleIcon: View {
    var body: some View {
        ZStack {
            Circle().fill(Color.white).frame(width: 18, height: 18)
            Text("G")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "4285F4"))
        }
    }
}

// MARK: - Miniflow Logo

struct MiniflowLogo: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("Miniflow")
                .font(.geist(24, weight: .medium))
                .foregroundColor(.black)
            HStack(spacing: 4) {
                Text("a").font(.system(size: 10, weight: .medium))
                Image(systemName: "bolt.fill").font(.system(size: 7, weight: .bold))
                Text("smallest.ai").font(.system(size: 10, weight: .medium))
                Text("product").font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(Color(hex: "010101"))
        }
    }
}

// MARK: - OTP Screen

struct OTPScreen: View {
    @Binding var digits: [String]
    @Binding var hasError: Bool
    let email: String
    let onResend: () -> Void
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        ZStack(alignment: .top) {

            // 1. Full white window background (matches Figma window bg)
            Color.white

            // 2. App preview card — starts at y=366, 96px side margins
            VStack(spacing: 0) {
                Color.clear.frame(height: 366)
                AppPreviewView()
                    .padding(.horizontal, 96)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // 3. Bottom fade — replicates Figma's Rectangle3 gradient overlay
            //    Starts around y=500, fades bottom to white
            VStack(spacing: 0) {
                Spacer()
                LinearGradient(
                    stops: [
                        .init(color: .clear,          location: 0),
                        .init(color: Color.white.opacity(0.6), location: 0.5),
                        .init(color: Color.white,     location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 220)
                .allowsHitTesting(false)
            }

            // 4. White top section (OTP form area)
            VStack(spacing: 0) {
                otpHeader
                    .frame(maxWidth: .infinity)
                    .frame(height: 366)
                    .background(Color.white)
                Spacer()
            }

            // 5. Back button
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 12, weight: .medium))
                        Text("Back")
                            .font(.geist(13, weight: .regular))
                    }
                    .foregroundColor(Color(hex: "737373"))
                }
                .buttonStyle(.plain)
                .padding(.leading, 48)
                .padding(.top, 48)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var otpHeader: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 69)

            MiniflowLogo()

            Spacer().frame(height: 32)

            VStack(spacing: 6) {
                Text("Let's get you started")
                    .font(.geist(24, weight: .regular))
                    .foregroundColor(.black)
                VStack(spacing: 0) {
                    Text("Talk your way through any app and let")
                    Text("AI take care of the heavy lifting with just a command!")
                }
                .font(.geist(16, weight: .regular))
                .foregroundColor(Color(hex: "737373"))
                .multilineTextAlignment(.center)
            }

            Spacer().frame(height: 24)

            OTPInputView(digits: $digits, hasError: hasError)

            Spacer().frame(height: 16)

            // Next CTA — advances to main app
            Button(action: onResend) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise").font(.system(size: 12))
                    Text("Resend Code").font(.geist(13, weight: .regular))
                }
                .foregroundColor(Color(hex: "737373"))
            }
            .buttonStyle(.plain)

            Spacer().frame(height: 16)

            NextButton(action: onNext)

            Spacer().frame(height: 20)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Next Button

struct NextButton: View {
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text("Next")
                    .font(.geist(14, weight: .medium))
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 11)
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
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .scaleEffect(hovered ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.12), value: hovered)
        .onHover { hovered = $0 }
    }
}

// MARK: - Success Screen → Full Miniflow App

struct SuccessScreen: View {
    let onSignOut: () -> Void
    var body: some View {
        MainAppView(onSignOut: onSignOut)
    }
}
