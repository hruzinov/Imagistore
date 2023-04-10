//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI

private let libraryPath = getDocumentsDirectory().appendingPathComponent("library.json")

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
        let newLibrary = PhotosLibrary(libraryVersion: ApplicationSettings.actualLibraryVersion, photos: [])
        saveLibrary(lib: newLibrary)
        return newLibrary
    }
    let library: PhotosLibrary = try! JSONDecoder().decode(PhotosLibrary.self, from: stringData)
    
    // For future versions
//    if library.libraryVersion < ApplicationSettings.actualLibraryVersion {
//        var allOk = true
//
//        switch library.libraryVersion {
//
//        case 1:
//            // SOME CODE
//
//        default:
//            print("Unknown library version: \(String(describing: library.libraryVersion))")
//            allOk = false
//        }
//
//        if allOk {
//            print("Library updated to version \(ApplicationSettings.actualLibraryVersion)")
//            library.libraryVersion = ApplicationSettings.actualLibraryVersion
//            saveLibrary(lib: library)
//        }
//    }
        
    return library
}

func readImageFromFile(id: UUID, fileExtention: PhotoExtention) -> UIImage? {
    let filepath = getDocumentsDirectory().appendingPathComponent(id.uuidString + ".\(fileExtention.rawValue)")
    let uiImage = UIImage(contentsOfFile: filepath.path)
    return uiImage
}

func writeImageToFile(uiImage: UIImage, fileExtention: String) -> UUID? {
    var data: Data?
    if fileExtention == "png" {
        data = uiImage.pngData()
    } else {
        data = uiImage.jpegData(compressionQuality: 1)
    }
    if let data {
        let uuid = UUID()
        let filepath = getDocumentsDirectory().appendingPathComponent(uuid.uuidString + ".\(fileExtention)")
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
