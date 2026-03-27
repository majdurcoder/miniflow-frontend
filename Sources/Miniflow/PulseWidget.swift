import SwiftUI

struct PulseWidget: View {
    // Toggle these to preview states
    var isTranscribing: Bool = false
    var isRecording: Bool = false

    private let barCount = 10
    private let barWidth: CGFloat = 8
    private let barGap: CGFloat = 4

    var body: some View {
        ZStack {
            // Waveform bars
            HStack(spacing: barGap) {
                ForEach(0..<barCount, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.15))
                        .frame(width: barWidth, height: 4)
                }
            }

            // Transcribing spinner overlay
            if isTranscribing {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.7)
                    )
            }
        }
        .frame(width: 160, height: 50)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.9))
        )
    }
}

#Preview("Idle") {
    PulseWidget()
        .padding()
        .background(Color.gray.opacity(0.3))
}

#Preview("Transcribing") {
    PulseWidget(isTranscribing: true)
        .padding()
        .background(Color.gray.opacity(0.3))
}
