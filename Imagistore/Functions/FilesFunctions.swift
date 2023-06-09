//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI
import CloudKit

let cloudDatabase = CKContainer(identifier: "iCloud.com.gruzinov.imagistore.photos").privateCloudDatabase

private let documentsDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
private func photosFilePath(_ libID: UUID) -> URL {
    documentsDirectory.appendingPathComponent("fullSizes/\(libID.uuidString)/")
}
private func directoryExistsAtPath(_ path: String) -> Bool {
    var isDirectory: ObjCBool = true
    let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
    return exists && isDirectory.boolValue
}
func fileExistsAtPath(_ path: String) -> Bool {
    FileManager.default.fileExists(atPath: path)
}
func imageFileURL (_ id: UUID, libraryID: UUID) -> URL {
    photosFilePath(libraryID).appendingPathComponent(id.uuidString + ".heic")
}

func checkFileRecord(_ item: Photo) {
    if let recordID = item.fullsizeCloudID {
        cloudDatabase.fetch(withRecordID: CKRecord.ID(recordName: recordID)) { record, error in
            if let error {
                debugPrint(error)
            } else if record == nil, let uuid = item.uuid {
                let imageAsset = CKAsset(fileURL: imageFileURL(uuid, libraryID: item.library.uuid))
                let photoCloudRecord = CKRecord(recordType: "FullSizePhotos")
                photoCloudRecord["library"] = item.library.uuid.uuidString as CKRecordValue
                photoCloudRecord["photo"] = uuid.uuidString as CKRecordValue
                photoCloudRecord["asset"] = imageAsset
                item.fullsizeCloudID = photoCloudRecord.recordID.recordName
                cloudDatabase.save(photoCloudRecord) { _, error in
                    debugPrint(error as Any)
                }
            }
        }
    }
}

func readImageFromFile(_ photo: Photo) -> UIImage? {
    if let uuid = photo.uuid {
        let filepath = photosFilePath(photo.library.uuid).appendingPathComponent(uuid.uuidString + ".heic")
        let uiImage: UIImage? = UIImage(contentsOfFile: filepath.path)
        return uiImage
    }
    return nil
}

func writeImageToFile(_ uuid: UUID, uiImage: UIImage, library: PhotosLibrary) -> Bool {
    let data = uiImage.heic()
    let libraryPath = photosFilePath(library.uuid)

    if let data {
        if !directoryExistsAtPath(libraryPath.path()) {
            do {
                try FileManager().createDirectory(at: libraryPath, withIntermediateDirectories: true)
                print("Created directory for photos")
            } catch {
                print(error)
                return false
            }
        }

        let filepath = libraryPath.appendingPathComponent(uuid.uuidString + ".heic")
        do {
            try data.write(to: filepath)
        } catch {
            print(error)
        }
        print("New image file created in path \(filepath)")
        return true
    }
    return false
}

func removeImageFile(_ photo: Photo, completion: @escaping (Bool, Error?) -> Void) {
    let filepath = photosFilePath(photo.library.uuid).appendingPathComponent(photo.uuid!.uuidString + ".heic")
    do {
        try FileManager.default.removeItem(atPath: filepath.path)
        print("Image file deleted from path \(filepath)")
        completion(true, nil)
    } catch {
        switch error._code {
        case 4:
            print("An obscure image has been deleted")
            completion(true, nil)
        default:
            print(error)
            completion(false, error)
        }
    }
}

func removeFolder(_ library: PhotosLibrary, completion: @escaping (Bool, Error?) throws -> Void) {
    if directoryExistsAtPath(photosFilePath(library.uuid).path) {
        do {
            try FileManager.default.removeItem(at: photosFilePath(library.uuid))
            try completion(true, nil)
        } catch {
            try? completion(false, error)
        }
    } else {
        try? completion(true, nil)
    }
}

func getCloudImage(_ photo: Photo, completion: @escaping (UIImage?, Error?) throws -> Void) {
    if
        let uuid = photo.uuid, !fileExistsAtPath(imageFileURL(uuid, libraryID: photo.library.uuid).path),
        let cloudID = photo.fullsizeCloudID {
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
                        try? completion(uiImage, nil)
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
