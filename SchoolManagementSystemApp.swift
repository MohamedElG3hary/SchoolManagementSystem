import SwiftUI

@main
struct SchoolManagementSystemApp: App {
    let database: DatabaseServiceProtocol = InMemoryDatabaseManager()
    
    var body: some Scene {
        WindowGroup {
            DashboardView(database: database)
        }
    }
}
