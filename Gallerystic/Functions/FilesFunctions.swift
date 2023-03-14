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
    
    guard let stringData, let library: PhotosLibrary = try? JSONDecoder().decode(PhotosLibrary.self, from: stringData) else {
        let newLibrary = PhotosLibrary(photos: [])
        saveLibrary(lib: newLibrary)
        return newLibrary
    }
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
