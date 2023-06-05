//
//  Created by Evhen Gruzinov on 17.04.2023.
//

import SwiftUI
import CloudKit

class UIImageHolder: ObservableObject {
    @Published var data: [UUID: UIImage]
    private var fullsizeArr: [UUID]

    init() {
        data = [:]
        fullsizeArr = []
    }

    func getAllUiImages(_ photos: FetchedResults<Photo>) async -> Bool {
        photos.forEach { photo in
            if let uuid = photo.uuid, photo.status == PhotoStatus.normal.rawValue,
               let data = photo.miniature, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.data.updateValue(uiImage, forKey: uuid)
                }
            }
        }
        return true
    }
    func getUiImage(_ photo: Photo) {
        if let uuid = photo.uuid,
           let data = photo.miniature, let uiImage = UIImage(data: data) {
            self.data.updateValue(uiImage, forKey: uuid)
        }
    }

    func loadFullImage(_ photo: Photo) async {
        if
            let uuid = photo.uuid, !fileExistsAtPath(imageFileURL(uuid, libraryID: photo.library.uuid).path),
                !fullsizeArr.contains(uuid), let cloudID = photo.fullsizeCloudID {
            Task {
                print("TestDebug — no local file")
                do {
                    let record = try await cloudDatabase.record(for: CKRecord.ID(recordName: cloudID))
                    let photoAsset = record.value(forKey: "asset") as? CKAsset
                    var cloudUiImage: UIImage?
                    if let photoAsset, let photoURL = photoAsset.fileURL {
                        cloudUiImage = UIImage(data: try Data(contentsOf: photoURL))
                        print("TestDebug — loaded UIImage from data")

                        if cloudUiImage == nil {
                            print("Image file not found: \(photo.uuid?.uuidString ?? "No UUID")")
                            print("TestDebug — cloud image is nil")
                        } else if let cloudUiImage, writeImageToFile(uuid, uiImage: cloudUiImage, library: photo.library) {
                            let uiImage = cloudUiImage
                            print("TestDebug — written to file")
                            DispatchQueue.main.async {
                                self.data.updateValue(uiImage, forKey: uuid)
                                self.fullsizeArr.append(uuid)
                            }
                        } else {
                            print("TestDebug — some else")
                        }
                    }

                } catch {
                    print("TestDebug — \(error.localizedDescription)")
                }
            }
        }
    }
}
