//
//  Created by Evhen Gruzinov on 21.04.2023.
//

import Foundation
import FirebaseStorage
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
                    
                    let storage = Storage.storage()
                    let photosRef = storage.reference().child("photos")
                    
                    imgs.forEach { ph in
                        onlineLibraryRef.collection("photos").document(ph.id.uuidString).setData([
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
                        newPhotosArr.append(onlineLibraryRef.collection("photos").document(ph.id.uuidString))
                        
                        let filename = "\(ph.id.uuidString).heic"
                        let filepath = FileSettings.photosFilePath.appendingPathComponent(filename)
                        let uploadTask = photosRef.child(filename).putFile(from: filepath) { metadata, error in
                            if let error {
                                print(error)
                                competition(error)
                            } else {
                                print(metadata?.name as Any)
                            }
                        }
                    }

                    onlineLibraryRef.updateData([
                        "photos": FieldValue.arrayUnion(newPhotosArr),
                        "lastChangeDate": Date()
                    ]) { err in
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
                let onlinePhotoRef = db.collection("libraries").document(lib.id.uuidString).collection("photos").document(ph.id.uuidString)
                onlinePhotoRef.updateData(["status": "deleted"]) { error in
                    if let error { competition(error) }
                }
            }
            db.collection("libraries").document(lib.id.uuidString).updateData(["lastChangeDate": Date()]) { err in
                competition(err)
            }
        }
    }
    static func recoverImages(_ imgs: [Photo], lib: PhotosLibrary, competition: @escaping (Error?) -> Void) {
        applicationSettings.load()
        
        if let isOnlineMode = applicationSettings.isOnlineMode, isOnlineMode {
            let db = Firestore.firestore()
            
            imgs.forEach { ph in
                let onlinePhotoRef = db.collection("libraries").document(lib.id.uuidString).collection("photos").document(ph.id.uuidString)
                onlinePhotoRef.updateData(["status": "normal"]) { error in
                    if let error { competition(error) }
                }
            }
            db.collection("libraries").document(lib.id.uuidString).updateData(["lastChangeDate": Date()]) { err in
                competition(err)
            }
        }
    }
    static func permanentRemove(_ imgs: [Photo], lib: PhotosLibrary, competition: @escaping (Error?) -> Void) {
        applicationSettings.load()
        
        if let isOnlineMode = applicationSettings.isOnlineMode, isOnlineMode {
            let db = Firestore.firestore()
            let onlineLibraryRef = db.collection("libraries").document(lib.id.uuidString)
            
            var removedRefs = [DocumentReference]()
            let storage = Storage.storage()
            let photosRef = storage.reference().child("photos")
            
            imgs.forEach { ph in
                let phRef = onlineLibraryRef.collection("photos").document(ph.id.uuidString)
                phRef.delete()
                removedRefs.append(phRef)
                
                let filename = "\(ph.id.uuidString).heic"
                let filepath = FileSettings.photosFilePath.appendingPathComponent(filename)
                photosRef.child(filename).delete { error in
                    if let error {
                        print(error)
                        competition(error)
                    } else {
                        print("File \(filename) deleted online")
                    }
                }
            }
            
            onlineLibraryRef.updateData([
                "photos": FieldValue.arrayRemove(removedRefs),
                "lastChangeDate": Date()
            ]) { err in
                competition(err)
            }
        }
    }
}
