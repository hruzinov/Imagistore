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
        let storage = Firestore.firestore()
        let onlineLibraryRef = storage.collection("libraries").document(lib.id.uuidString)

        onlineLibraryRef.getDocument { document, error in
            if let document, document.exists {
                if let onlineLib = try? document.data(as: DBLibrary.self) {
                    if let lastSyncDate = onlineLib.lastSyncDate,
                       lastSyncDate.timeIntervalSince1970 == lib.lastChangeDate.timeIntervalSince1970 {
                        competition([], [], error)
                        return
                    }

                    let onlinePhotosRef = storage.collection("libraries").document(lib.id.uuidString)
                            .collection("photos")
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
                                    let img = try phDoc.data(as: Photo.self)
                                    onlinePhotosArray.append(img)
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
                            offlinePhotosArray.forEach { img in
                                if let onlinePhoto = onlinePhotosArray.first(where: { $0.id == img.id }) {
                                    let onlinePhotoRef = onlineLibraryRef.collection("photos")
                                            .document(img.id.uuidString)
                                    if onlinePhoto.status != img.status {
                                        if localPriority {
                                            onlinePhotoRef.updateData(
                                                    ["status": img.status, "deletionDate": img.deletionDate]
                                            )
                                        } else {
                                            lib.photos.first(where: { $0.id == img.id })?.status = onlinePhoto.status
                                            lib.photos.first(where: { $0.id == img.id })?.deletionDate
                                                    = onlinePhoto.deletionDate
                                        }
                                    }
                                } else {
                                    listToUpload.append(img)
                                }
                            }
                            // check if cloud photo exist in local
                            onlinePhotosArray.forEach { img in
                                if !offlinePhotosArray.contains(where: { $0.id == img.id }) {
                                    listToDownload.append(img)
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
                    print("WTF")
                }
            } else {
                storage.collection("libraries").document(lib.id.uuidString).setData([
                    "id": lib.id.uuidString,
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

    static func addPhotos(_ images: [Photo], lib: PhotosLibrary, competition: @escaping (Error?) -> Void) {
        applicationSettings.load()

        if applicationSettings.isOnlineMode {
            let storage = Firestore.firestore()
            let onlineLibraryRef = storage.collection("libraries").document(lib.id.uuidString)

            onlineLibraryRef.getDocument(as: DBLibrary.self) { result in
                switch result {
                case .success(let library):
                    var newPhotosArr = library.photos

                    images.forEach { img in
                        onlineLibraryRef.collection("photos").document(img.id.uuidString).setData([
                            "id": img.id.uuidString,
                            "status": img.status.rawValue,
                            "creationDate": img.creationDate,
                            "importDate": img.importDate,
                            "deletionDate": img.deletionDate as Any,
                            "fileExtension": img.fileExtension.rawValue,
                            "keywords": img.keywords
                        ]) { error in
                            if let error {
                                competition(error)
                            }
                        }
                        newPhotosArr.append(onlineLibraryRef.collection("photos").document(img.id.uuidString))
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
    static func toBin(_ images: [Photo], lib: PhotosLibrary, competition: @escaping (Error?) -> Void) {
        applicationSettings.load()

        if applicationSettings.isOnlineMode {
            let storage = Firestore.firestore()
            images.forEach { img in
                let onlinePhotoRef = storage.collection("libraries").document(lib.id.uuidString)
                        .collection("photos").document(img.id.uuidString)
                onlinePhotoRef.updateData(["status": "deleted", "deletionDate": img.deletionDate!]) { error in
                    if let error { competition(error) }
                }
            }
            storage.collection("libraries").document(lib.id.uuidString).updateData(["lastChangeDate": Date()]) { err in
                competition(err)
            }
        }
    }
    static func recoverImages(_ images: [Photo], lib: PhotosLibrary, competition: @escaping (Error?) -> Void) {
        applicationSettings.load()

        if applicationSettings.isOnlineMode {
            let storage = Firestore.firestore()

            images.forEach { img in
                let onlinePhotoRef = storage.collection("libraries").document(lib.id.uuidString)
                        .collection("photos").document(img.id.uuidString)
                onlinePhotoRef.updateData(["status": "normal", "deletionDate": nil]) { error in
                    if let error { competition(error) }
                }
            }
            storage.collection("libraries").document(lib.id.uuidString).updateData(["lastChangeDate": Date()]) { err in
                competition(err)
            }
        }
    }
    static func permanentRemove(_ images: [Photo], lib: PhotosLibrary, competition: @escaping (Error?) -> Void) {
        applicationSettings.load()

        if applicationSettings.isOnlineMode {
            let storage = Firestore.firestore()
            let onlineLibraryRef = storage.collection("libraries").document(lib.id.uuidString)

            var removedRefs = [DocumentReference]()

            images.forEach { img in
                let phRef = onlineLibraryRef.collection("photos").document(img.id.uuidString)
                removedRefs.append(phRef)
                removeOnlineImage(photo: img) { err in
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
