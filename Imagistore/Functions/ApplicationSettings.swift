//
//  Created by Evhen Gruzinov on 08.04.2023.
//

import Foundation

struct ApplicationSettings: Codable {
    var isFirstLaunch: Bool
    var isOnlineMode: Bool
    var lastSelectedLibrary: UUID?

    init(isFirstLaunch: Bool, isOnlineMode: Bool) {
        self.isFirstLaunch = isFirstLaunch
        self.isOnlineMode = isOnlineMode
    }
    init() {
        isFirstLaunch = true
        isOnlineMode = false
    }

    mutating func load() {
        let userDefaults = UserDefaults.standard
        var appSettings: ApplicationSettings?
        if let data = userDefaults.object(forKey: "ApplicationSettings") as? Data,
           let settings = try? JSONDecoder().decode(ApplicationSettings.self, from: data) {
            appSettings = settings
        }

        if let appSettings {
            print("Settings loaded")
            self = appSettings
        } else {
            let settings = ApplicationSettings(isFirstLaunch: true, isOnlineMode: false)
            do {
                let encoded = try JSONEncoder().encode(settings)
                userDefaults.set(encoded, forKey: "ApplicationSettings")
            } catch {
                print(error)
            }
            self = settings
        }
    }
    func save() {
        let userDefaults = UserDefaults.standard
        do {
            let encoded = try JSONEncoder().encode(self)
            userDefaults.set(encoded, forKey: "ApplicationSettings")
        } catch {
            print(error)
        }
    }
}

class SceneSettings: ObservableObject {
    @Published var isShowingTabBar: Bool = true

    @Published var isShowingErrorAlert: Bool = false
    @Published var errorAlertData: String = ""

    @Published var isShowingInfoBar: Bool = false
    @Published var infoBarData: String = ""
    @Published var infoBarProgress: Double = 0
    @Published var infoBarFinal: Bool = false

    @Published var syncProgress: Double = 0
}
