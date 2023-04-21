//
//  Created by Evhen Gruzinov on 21.04.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class OnlineFunctions {
    static var applicationSettings = ApplicationSettings()
    
    static func addPhotos(_ imgs: [Photo], lib: PhotosLibrary, competition: @escaping (Error?) -> Void) {
        applicationSettings.load()
        
        if let isOnlineMode = applicationSettings.isOnlineMode, isOnlineMode {
            let db = Firestore.firestore()
            let onlineLibraryRef = db.collection("libraries").document(lib.id.uuidString)
            
            onlineLibraryRef.getDocument(as: DBLibrary.self) { result in
                switch result {
                case .success(let library):
                    var newPhotosArr = library.photos
                    
                    imgs.forEach { ph in
                        db.collection("photos").document(ph.id.uuidString).setData([
                            "id": ph.id.uuidString,
                            "status": ph.status.rawValue,
                            "creationDate": ph.creationDate,
                            "importDate": ph.importDate,
                            "deletionDate": ph.deletionDate as Any,
                            "fileExtention": ph.fileExtention.rawValue,
                            "keywords": ph.keywords
                        ]) { error in
                            if let error {
                                competition(error)
                            }
                        }
                        newPhotosArr.append(ph.id.uuidString)
                    }
                    
                    onlineLibraryRef.setData([
                        "photos": newPhotosArr,
                        "lastChangeDate": Date()
                    ], merge: true) { err in
                        competition(err)
                    }
                    
                case .failure(let error):
                    competition(error)
                }
            }
        }
    }
    
    static func toBin(_ imgs: [Photo], lib: PhotosLibrary, competition: @escaping (Error?) -> Void) {
        applicationSettings.load()
        
        if let isOnlineMode = applicationSettings.isOnlineMode, isOnlineMode {
            let db = Firestore.firestore()
            
            imgs.forEach { ph in
                db.collection("photos").document(ph.id.uuidString).setData(["status": "deleted"], merge: true) { error in
                    if let error { competition(error) }
                }
            }
            db.collection("libraries").document(lib.id.uuidString).setData(["lastChangeDate": Date()], merge: true) { err in
                competition(err)
            }
        }
    }
    static func recoverImages(_ imgs: [Photo], lib: PhotosLibrary, competition: @escaping (Error?) -> Void) {
        applicationSettings.load()
        
        if let isOnlineMode = applicationSettings.isOnlineMode, isOnlineMode {
            let db = Firestore.firestore()
            
            imgs.forEach { ph in
                db.collection("photos").document(ph.id.uuidString).setData(["status": "normal"], merge: true) { error in
                    if let error { competition(error) }
                }
            }
            db.collection("libraries").document(lib.id.uuidString).setData(["lastChangeDate": Date()], merge: true) { err in
                competition(err)
            }
        }
    }
    static func permanentRemove(_ imgs: [Photo], lib: PhotosLibrary, competition: @escaping (Error?) -> Void) {
        applicationSettings.load()
        
        if let isOnlineMode = applicationSettings.isOnlineMode, isOnlineMode {
            let db = Firestore.firestore()
            
            imgs.forEach { ph in
                db.collection("photos").document(ph.id.uuidString).delete()
            }
            let onlineLibraryRef = db.collection("libraries").document(lib.id.uuidString)
            onlineLibraryRef.getDocument(as: DBLibrary.self) { result in
                switch result {
                case .success(let library):
                    var newPhotosArr = library.photos
                    imgs.forEach { ph in
                        if let photoIndex = newPhotosArr.firstIndex(of: ph.id.uuidString) {
                            newPhotosArr.remove(at: photoIndex)
                        }
                    }
                    onlineLibraryRef.setData([
                        "photos": newPhotosArr,
                        "lastChangeDate": Date()
                    ], merge: true) { err in
                        competition(err)
                    }
                    
                    
                case .failure(let error):
                    competition(error)
                }
            }
        }
    }
}
