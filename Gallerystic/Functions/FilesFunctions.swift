//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI
import FirebaseStorage

class FileSettings {
    static let librariesStoragePath = getDocumentsDirectory().appendingPathComponent("libraries.json")
    static let photosFullFilePath = getDocumentsDirectory().appendingPathComponent("photos/")
    static let photosFilePath = getDocumentsDirectory().appendingPathComponent("miniatures/")
}


fileprivate func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

fileprivate func directoryExistsAtPath(_ path: String) -> Bool {
    var isDirectory: ObjCBool = true
    let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
    return exists && isDirectory.boolValue
}

extension PhotosLibrariesCollection {
    func saveLibraryCollection() -> Error? {
        do {
            let stringData = try JSONEncoder().encode(self)
            do {
                try stringData.write(to: FileSettings.librariesStoragePath)
                print("Libraries collection saved")
            } catch {
                print(error)
                return error
            }
        } catch {
            print(error)
            return error
        }
        return nil
    }
}


func saveLibrary(lib: PhotosLibrary, changeDate: Date = Date()) -> Error? {
    let libraryPath = getDocumentsDirectory().appendingPathComponent("/libraries/\(lib.id.uuidString).json")
    do {
        
        lib.lastChangeDate = changeDate
        let stringData = try JSONEncoder().encode(lib)
        do {
            try stringData.write(to: libraryPath)
            print("Library saved")
        } catch {
            print(error)
            return error
        }
    } catch {
        print(error)
        return error
    }
    return nil
}

func loadLibrariesCollection() -> PhotosLibrariesCollection? {
    let generalLibrariesPath = getDocumentsDirectory().appendingPathComponent("/libraries/")
    if !directoryExistsAtPath(generalLibrariesPath.path()) {
        do {
            try FileManager().createDirectory(at: generalLibrariesPath, withIntermediateDirectories: true)
            print("Created directory for libraries")
        } catch {
            print(error)
            return nil
        }
    }
    
    let stringData = try? String(contentsOf: FileSettings.librariesStoragePath).data(using: .utf8)
    guard let stringData else {
        let newLibrariesCollection = PhotosLibrariesCollection()
        _ = newLibrariesCollection.saveLibraryCollection()
        return newLibrariesCollection
    }
    
    let librariesCollection = try! JSONDecoder().decode(PhotosLibrariesCollection.self, from: stringData)
    
    return librariesCollection
}

func loadLibrary(id: UUID) -> PhotosLibrary? {
    let libraryPath = getDocumentsDirectory().appendingPathComponent("/libraries/\(id.uuidString).json")
    let stringData = try? String(contentsOf: libraryPath).data(using: .utf8)
    print("Library loaded in path \(libraryPath)")
    
    guard let stringData else { return nil }
    let library: PhotosLibrary = try! JSONDecoder().decode(PhotosLibrary.self, from: stringData)
    
//    if library.libraryVersion < PhotosLibrary.actualLibraryVersion {
//        var allOk = true
//
//        switch library.libraryVersion {
//
//        case 1:
//            ///
//
//        default:
//            print("Unknown library version: \(String(describing: library.libraryVersion))")
//            allOk = false
//        }
//
//        if allOk {
//            print("Library updated to version \(PhotosLibrary.actualLibraryVersion)")
//            library.libraryVersion = PhotosLibrary.actualLibraryVersion
//            _ = saveLibrary(lib: library)
//        }
//    }
        
    return library
}

func readImageFromFile(id: UUID) -> UIImage? {
    let filepath = FileSettings.photosFilePath.appendingPathComponent(id.uuidString + ".heic")
    let uiImage = UIImage(contentsOfFile: filepath.path)
    if uiImage == nil {print("Image file not found in path: \(filepath)")}
    return uiImage
}
func readFullImageFromFile(id: UUID) -> UIImage? {
    let filepath = FileSettings.photosFullFilePath.appendingPathComponent(id.uuidString + ".heic")
    let uiImage = UIImage(contentsOfFile: filepath.path)
    if uiImage == nil {print("Image file not found in path: \(filepath)")}
    return uiImage
}

func writeImageToFile(uiImage: UIImage) -> UUID? {
    
    let dataFull = uiImage.heic()
    
    let size: CGSize
    if uiImage.size.width > uiImage.size.height {
        let coef = uiImage.size.width / 512
        size = CGSize(width: 512, height: uiImage.size.height / coef)
    } else {
        let coef = uiImage.size.height / 512
        size = CGSize(width: uiImage.size.width / coef, height: 512)
    }
    
    let renderer = UIGraphicsImageRenderer(size: size)
    let uiImageMini = renderer.image { (context) in
        uiImage.draw(in: CGRect(origin: .zero, size: size))
    }
    let data = uiImageMini.heic(compressionQuality: 0.7)
    
    if !directoryExistsAtPath(FileSettings.photosFilePath.path()) {
        do {
            try FileManager().createDirectory(at: FileSettings.photosFilePath, withIntermediateDirectories: true)
            print("Created directory for photos")
        } catch {
            print(error)
            return nil
        }
    }
    if !directoryExistsAtPath(FileSettings.photosFullFilePath.path()) {
        do {
            try FileManager().createDirectory(at: FileSettings.photosFullFilePath, withIntermediateDirectories: true)
            print("Created directory for full size photos")
        } catch {
            print(error)
            return nil
        }
    }

    if let data, let dataFull {
        let uuid = UUID()
        
        let filepath = FileSettings.photosFilePath.appendingPathComponent(uuid.uuidString + ".heic")
        do {
            try data.write(to: filepath)
        } catch {
            print(error)
        }
        print("New image miniature file created in path \(filepath)")
        
        let filepathFull = FileSettings.photosFullFilePath.appendingPathComponent(uuid.uuidString + ".heic")
        do {
            try dataFull.write(to: filepathFull)
        } catch {
            print(error)
        }
        print("New image file created in path \(filepathFull)")
        return uuid
    }

    
    return nil
}
func removeImageFile(id: UUID, fileExtention: PhotoExtention) -> (Bool, Error?) {
    let filepath = FileSettings.photosFilePath.appendingPathComponent(id.uuidString + ".heic")
    let filepathFull = FileSettings.photosFullFilePath.appendingPathComponent(id.uuidString + ".heic")
    do {
        try FileManager.default.removeItem(atPath: filepath.path)
        try FileManager.default.removeItem(atPath: filepathFull.path)
        print("Image file deleted from path \(filepath)")
        return (true, nil)
    } catch {
        print(error)
        return (false, error)
    }
}


// Cloud functions

extension OnlineFunctions {
    static func uploadImage(photo ph: Photo, competition: @escaping (StorageUploadTask?, Error?) -> Void) {
        let storage = Storage.storage()
        let photosFullRef = storage.reference().child("photos")
        let photosRef = storage.reference().child("miniatures")
        
        let filename = "\(ph.id.uuidString).heic"
        let filepath = FileSettings.photosFilePath.appendingPathComponent(filename)
        let filepathFull = FileSettings.photosFullFilePath.appendingPathComponent(filename)
        let uploadTask = photosRef.child(filename).putFile(from: filepath) { metadata, error in
            if let error {
                print(error)
                competition(nil, error)
            } else {
                print("\(String(describing: metadata?.name)) (miniature)")
            }
        }
        let uploadFullTask = photosFullRef.child(filename).putFile(from: filepathFull) { metadata, error in
            if let error {
                print(error)
                competition(nil, error)
            }
            else {
                print("\(String(describing: metadata?.name))")
//                competition(nil)
            }
            
        }
        competition(uploadFullTask, nil)
        
    }
    static func downloadImage(id: UUID, fullSize: Bool, competition: @escaping (StorageDownloadTask?, Error?) -> Void) {
        let storage = Storage.storage()
        let photosRef: StorageReference
        let filepath: URL
        
        let filename = "\(id.uuidString).heic"
        
        if fullSize {
            photosRef = storage.reference().child("photos/\(filename)")
            filepath = FileSettings.photosFullFilePath.appendingPathComponent(filename)
        } else {
            photosRef = storage.reference().child("miniatures/\(filename)")
            filepath = FileSettings.photosFilePath.appendingPathComponent(filename)
        }
        
        let downloadTask = photosRef.write(toFile: filepath) { url, error in
            if let error {
                print(error)
                competition(nil, error)
            } else {
                print("Image downloaded to \(String(describing: url))")
            }
        }
        competition(downloadTask, nil)
    }
    static func removeOnlineImage(photo ph: Photo, competition: @escaping (Error?) -> Void) {
        let storage = Storage.storage()
        
        let photosFullRef = storage.reference().child("photos")
        let photosRef = storage.reference().child("miniatures")
        
        let filename = "\(ph.id.uuidString).heic"
        photosRef.child(filename).delete { error in
            if let error {
                print(error)
                competition(error)
            } else {
                print("File \(filename) (miniature) deleted online")
            }
        }
        photosFullRef.child(filename).delete { error in
            if let error {
                print(error)
                competition(error)
            } else {
                print("File \(filename) deleted online")
            }
        }
        competition(nil)
    }
}
