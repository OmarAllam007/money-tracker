import SwiftUI

@main
struct MoneyTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            AppViewSwitcher()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
