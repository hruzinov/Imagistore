//
//  Created by Evhen Gruzinov on 07.05.2023.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "LibrariesStorage")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

        // Only initialize the schema when building the app with the
        // Debug build configuration.
//        #if DEBUG
//        do {
//            // Use the container to initialize the development schema.
//            try container.initializeCloudKitSchema(options: [])
//        } catch {
//            // Handle any errors.
//        }
//        #endif

        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                debugPrint("Unable to load PersistentStores :\(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
