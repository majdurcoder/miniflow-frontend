import SwiftUI

@main
struct MiniflowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 1200, height: 800)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
