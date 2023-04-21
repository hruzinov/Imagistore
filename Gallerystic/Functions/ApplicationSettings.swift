//
//  Created by Evhen Gruzinov on 08.04.2023.
//

import Foundation


struct ApplicationSettings: Codable {
    var isFirstLaunch: Bool
    var isOnlineMode: Bool?
    var userUid: String?
    var lastSelectedLibrary: UUID?
    
    init(isFirstLaunch: Bool, isOnlineMode: Bool? = nil) {
        self.isFirstLaunch = isFirstLaunch
        self.isOnlineMode = isOnlineMode
    }
    init() {
        self.isFirstLaunch = true
        self.isOnlineMode = nil
    }
    
    mutating func load() {
        let userDefaults = UserDefaults.standard
        var appSettings: ApplicationSettings? = nil
        if let data = userDefaults.object(forKey: "ApplicationSettings") as? Data,
           let settings = try? JSONDecoder().decode(ApplicationSettings.self, from: data) {
            appSettings = settings
        }
        
        if let appSettings {
            print("Settings loaded")
            self = appSettings
        } else {
            let settings = ApplicationSettings(isFirstLaunch: true, isOnlineMode: nil)
            if let encoded = try? JSONEncoder().encode(settings) {
                userDefaults.set(encoded, forKey: "ApplicationSettings")
            }
            self = settings
        }
    }
    func save() {
        let userDefaults = UserDefaults.standard
        if let encoded = try? JSONEncoder().encode(self) {
            userDefaults.set(encoded, forKey: "ApplicationSettings")
        }
    }
}

class DispayingSettings: ObservableObject {
    @Published var isShowingTabBar: Bool = true
    
    @Published var isShowingErrorAlert: Bool = false
    @Published var errorAlertData: String = ""
    
    @Published var isShowingInfoBar: Bool = false
    @Published var infoBarData: String = ""
    @Published var infoBarProgress: Double = 0
    @Published var infoBarFinal: Bool = false
}
