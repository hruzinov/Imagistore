//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI

private let libraryPath = getDocumentsDirectory().appendingPathComponent("library.json")
private let nowLibVersion = 1

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func saveLibrary(lib: PhotosLibrary) {
    if let stringData = try? JSONEncoder().encode(lib) {
        try? stringData.write(to: libraryPath)
    }
}

func loadLibrary() -> PhotosLibrary {
    let stringData = try? String(contentsOf: libraryPath).data(using: .utf8)
    
    guard let stringData else {
        let newLibrary = PhotosLibrary(libraryVersion: nowLibVersion, photos: [])
        saveLibrary(lib: newLibrary)
        return newLibrary
    }
    let library: PhotosLibrary = try! JSONDecoder().decode(PhotosLibrary.self, from: stringData)
    
    // For Future versions
//    if library.libraryVersion < nowLibVersion {
//        switch library.libraryVersion {
//        case 1:
//            Some func
//        default:
//            print("Unknown library version: \(String(describing: library.libraryVersion))")
//        }
//
//        saveLibrary(lib: library)
//    }
        
    return library
}

func readImageFromFile(id: UUID) -> UIImage? {
    let filepath = getDocumentsDirectory().appendingPathComponent(id.uuidString + ".jpg")
    let uiImage = UIImage(contentsOfFile: filepath.path)
    return uiImage
}

func writeImageToFile(uiImage: UIImage) -> UUID? {
    if let data = uiImage.jpegData(compressionQuality: 0.8) {
        let uuid = UUID()
        let filepath = getDocumentsDirectory().appendingPathComponent(uuid.uuidString + ".jpg")

        try? data.write(to: filepath)

        return uuid
    }
    return nil
}
func removeImageFile(id: UUID) -> Bool {
    let filepath = getDocumentsDirectory().appendingPathComponent(id.uuidString + ".jpg")
    do {
        try FileManager.default.removeItem(atPath: filepath.path)
        return true
    } catch {
        print(error)
        return false
    }
}
