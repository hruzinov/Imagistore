//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI

fileprivate let librariesStoragePath = getDocumentsDirectory().appendingPathComponent("libraries.json")
fileprivate let photosFilePath = getDocumentsDirectory().appendingPathComponent("photos/")

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
                try stringData.write(to: librariesStoragePath)
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


func saveLibrary(lib: PhotosLibrary) -> Error? {
    let libraryPath = getDocumentsDirectory().appendingPathComponent("/libraries/\(lib.id.uuidString).json")
    do {
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
    
    let stringData = try? String(contentsOf: librariesStoragePath).data(using: .utf8)
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
    let filepath = photosFilePath.appendingPathComponent(id.uuidString + ".heic")
    let uiImage = UIImage(contentsOfFile: filepath.path)
    if uiImage == nil {print("Image file not found in path: \(filepath)")}
    return uiImage
}

func writeImageToFile(uiImage: UIImage) -> UUID? {
    
    let data = uiImage.heic()
    
    if !directoryExistsAtPath(photosFilePath.path()) {
        do {
            try FileManager().createDirectory(at: photosFilePath, withIntermediateDirectories: true)
            print("Created directory for photos")
        } catch {
            print(error)
            return nil
        }
    }
    
    if let data {
        let uuid = UUID()
        let filepath = photosFilePath.appendingPathComponent(uuid.uuidString + ".heic")
        
        do {
            try data.write(to: filepath)
        } catch {
            print(error)
        }

        print("New image file created in path \(filepath)")

        return uuid
    }
    
    return nil
}
func removeImageFile(id: UUID, fileExtention: PhotoExtention) -> (Bool, Error?) {
    let filepath = photosFilePath.appendingPathComponent(id.uuidString + ".heic")
    do {
        try FileManager.default.removeItem(atPath: filepath.path)
        print("Image file deleted from path \(filepath)")
        return (true, nil)
    } catch {
        print(error)
        return (false, error)
    }
}
