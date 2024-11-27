import SwiftUI
import SwiftData

@main
struct RoyVia_PrototypeApp: App {
    // Declare and initialize the shared ModelContainer
//    var sharedModelContainer: ModelContainer = {
//        do {
//            // Define the schema for your models
//            let schema = Schema([
//                RVDBData.self,
//                RVDBVersion.self,
//                RVAreasOfConcern.self,
//                RVHormoneData.self,   // Add your models here
//                RVIngredientData.self
//            ])
//            
//            // Configure the ModelContainer
//            let modelConfiguration = ModelConfiguration(schema: schema)
//            
//            // Initialize and return the ModelContainer
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        //.modelContainer(sharedModelContainer) // Attach the container to the app
    }
}
