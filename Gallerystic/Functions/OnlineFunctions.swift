//
//  Created by Evhen Gruzinov on 21.04.2023.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

class OnlineFunctions {
    static var applicationSettings = ApplicationSettings()
    
    static func getSyncData(lib: PhotosLibrary, competition: @escaping ([Photo], [Photo], Error?) -> Void) {
        let db = Firestore.firestore()
        let onlineLibraryRef = db.collection("libraries").document(lib.id.uuidString)
        
        onlineLibraryRef.getDocument { document, error in
            if let document, document.exists {
                let onlineLib = try! document.data(as: DBLibrary.self)
                if let lastSyncDate = onlineLib.lastSyncDate, lastSyncDate.timeIntervalSince1970 == lib.lastChangeDate.timeIntervalSince1970 {
                    competition([], [], error)
                    return
                }
                
                let onlinePhotosRef = db.collection("libraries").document(lib.id.uuidString).collection("photos")
                onlinePhotosRef.getDocuments { querySnapshot, error in
                    if let error {
                        competition([], [], error)
                    } else if let querySnapshot {
                        var onlinePhotosArray = [Photo]()
                        let offlinePhotosArray = lib.photos
                        
                        var listToUpload = [Photo]()
                        var listToDownload = [Photo]()
                        
                        let photosDocArr = querySnapshot.documents
                        photosDocArr.forEach { phDoc in
                            do {
                                let ph = try phDoc.data(as: Photo.self)
                                onlinePhotosArray.append(ph)
                            } catch {
                                print(error)
                            }
                        }
                        
                        let localPriority: Bool
                        if onlineLib.lastSyncDate ?? Date() < lib.lastSyncDate ?? Date() {
                            localPriority = true
                        } else {
                            localPriority = false
                        }
                        
                        // check if local photo exist in cloud
                        offlinePhotosArray.forEach { ph in
                            if let onlinePhoto = onlinePhotosArray.first(where: { $0.id == ph.id }) {
                                let onlinePhotoRef = onlineLibraryRef.collection("photos").document(ph.id.uuidString)
                                if onlinePhoto.status != ph.status {
                                    if localPriority {
                                        onlinePhotoRef.updateData(["status": ph.status, "deletionDate": ph.deletionDate])
                                    } else {
                                        lib.photos.first(where: {$0.id == ph.id})?.status = onlinePhoto.status
                                        lib.photos.first(where: {$0.id == ph.id})?.deletionDate = onlinePhoto.deletionDate
                                    }
                                }
                            } else {
                                listToUpload.append(ph)
                            }
                        }
                        // check if cloud photo exist in local
                        onlinePhotosArray.forEach { ph in
                            if !offlinePhotosArray.contains(where: { $0.id == ph.id }) {
                                listToDownload.append(ph)
                            }
                        }
                        
                        if listToUpload.count > 0 || listToDownload.count > 0 {
                            let syncDate = Date()
                            onlineLibraryRef.updateData(["lastSyncDate": syncDate])
                            let err = saveLibrary(lib: lib, changeDate: syncDate)
                            competition(listToUpload, listToDownload, err)
                        } else {
                            competition([], [], nil)
                        }
                        
                        
                    }
                }
            } else {
                db.collection("libraries").document(lib.id.uuidString).setData([
                    "id":lib.id.uuidString,
                    "lastChangeDate": lib.lastChangeDate,
                    "libraryVersion": lib.libraryVersion,
                    "name": lib.name,
                    "photos": [DocumentReference]()
                ]) { error in
                    if let error {
                        competition([], [], error)
                    } else {
                        getSyncData(lib: lib) { toUpload, toDownload, err in
                            competition(toUpload, toDownload, err)
                        }
                    }
                }
            }
        }
    }
    
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
                    }
                    
                    onlineLibraryRef.updateData([
                        "photos": FieldValue.arrayUnion(newPhotosArr),
                        "lastChangeDate": lib.lastChangeDate
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
                onlinePhotoRef.updateData(["status": "deleted", "deletionDate": ph.deletionDate!]) { error in
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
                onlinePhotoRef.updateData(["status": "normal", "deletionDate": nil]) { error in
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
            
            imgs.forEach { ph in
                let phRef = onlineLibraryRef.collection("photos").document(ph.id.uuidString)
                removedRefs.append(phRef)
                removeOnlineImage(photo: ph) { err in
                    if let err {
                        competition(err)
                    }
                }
            }
            
            onlineLibraryRef.updateData([
                "photos": FieldValue.arrayRemove(removedRefs),
                "lastChangeDate": lib.lastChangeDate
            ]) { err in
                competition(err)
            }
        }
    }
}
