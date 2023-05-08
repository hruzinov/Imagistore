////
////  Created by Evhen Gruzinov on 14.03.2023.
////
//
//import SwiftUI
//
//class PhotosLibrariesCollection: Codable {
//    var libraries: [UUID]
//    init() {
//        libraries = []
//    }
//}
//
//class PhotosLibrary: Identifiable, Codable, ObservableObject {
//    static var actualLibraryVersion = 1
//    var id: UUID
//    var name: String
//    var libraryVersion: Int
//    var lastChangeDate: Date
//    var photos: [Photo]
//    init(id: UUID, name: String, libraryVersion: Int = actualLibraryVersion,
//         lastChangeDate: Date = Date(), photos: [Photo] = []) {
//        self.id = id
//        self.name = name
//        self.libraryVersion = libraryVersion
//        self.photos = photos
//        self.lastChangeDate = lastChangeDate
//    }


//    func permanentRemove(_ images: [Photo], library: PhotosLibrary, competition: @escaping (Error?) -> Void) {
//        photos = loadLibrary(id: id)!.photos
//        for item in images {
//            if let photoIndex = photos.firstIndex(of: item) {
//                let (completed, error) = removeImageFile(item.id, library: library)
//                if completed {
//                    photos.remove(at: photoIndex)
//                } else {
//                    competition(error)
//                }
//            }
//        }
//        self.objectWillChange.send()
//        let err = saveLibrary(lib: self)
//        competition(err)
//    }
//    func clearBin(_ lib: PhotosLibrary, competition: @escaping (Error?) -> Void) {
//        var forDeletion = [Photo]()
//        for item in photos {
//            if item.status == .deleted,
//               let deletionDate = item.deletionDate,
//               DateTimeFunctions.daysLeft(deletionDate) < 0 {
//                forDeletion.append(item)
//            }
//        }
//        if forDeletion.count > 0 {
//            permanentRemove(forDeletion, library: lib) { error in
//                competition(error)
//            }
//        }
//    }
//    func sortedPhotos(by byArgument: PhotosSortArgument, filter: PhotoStatus) -> [Photo] {
//        photos
//            .sorted(by: { ph1, ph2 in
//                if filter == .deleted, let delDate1 = ph1.deletionDate, let delDate2 = ph2.deletionDate {
//                    return delDate1 < delDate2
//                } else {
//                    switch byArgument {
//                    case .importDate:
//                        return ph1.importDate < ph2.importDate
//                    case .creationDate:
//                        return ph1.creationDate < ph2.creationDate
//                    }
//                }
//            })
//            .filter({ item in
//                item.status == filter
//            })
//    }
//}
////
