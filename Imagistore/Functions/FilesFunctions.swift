//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI

private let librariesFileStoragePath = getDocumentsDirectory().appendingPathComponent("libraries.json")
private let librariesStoragePath = getDocumentsDirectory().appendingPathComponent("libraries/")

private func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    return paths!
}
private func libraryPath(_ lib: UUID) -> URL {
    librariesStoragePath.appendingPathComponent("\(lib.uuidString)/")
}
private func photosFullFilePath(_ lib: UUID) -> URL {
    libraryPath(lib).appendingPathComponent("photos/")
}
private func photosFilePath(_ lib: UUID) -> URL {
    libraryPath(lib).appendingPathComponent("miniatures/")
}

extension PhotosLibrariesCollection {
    func saveLibraryCollection() -> Error? {
        do {
            let stringData = try JSONEncoder().encode(self)
            do {
                try stringData.write(to: librariesFileStoragePath)
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
    let libraryPath = libraryPath(lib.id)
    do {
        try FileManager().createDirectory(at: libraryPath, withIntermediateDirectories: true)
        lib.lastChangeDate = changeDate
        let stringData = try JSONEncoder().encode(lib)
        do {
            try stringData.write(to: libraryPath.appendingPathComponent("library.json"))
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
    let generalLibrariesPath = librariesStoragePath
    try? FileManager().createDirectory(at: generalLibrariesPath, withIntermediateDirectories: true)
    let stringData = try? String(contentsOf: librariesFileStoragePath).data(using: .utf8)
    guard let stringData else {
        let newLibrariesCollection = PhotosLibrariesCollection()
        _ = newLibrariesCollection.saveLibraryCollection()
        return newLibrariesCollection
    }

    var librariesCollection: PhotosLibrariesCollection?

    do {
        librariesCollection = try JSONDecoder().decode(PhotosLibrariesCollection.self, from: stringData)
        return librariesCollection
    } catch {
        print(error)
    }
    return  librariesCollection
}

func loadLibrary(id: UUID) -> PhotosLibrary? {
    let libraryPath = libraryPath(id).appendingPathComponent("library.json")
    let stringData = try? String(contentsOf: libraryPath).data(using: .utf8)
    print("Library loaded in path \(libraryPath)")

    guard let stringData else { return nil }

    var library: PhotosLibrary?

    do {
        library = try JSONDecoder().decode(PhotosLibrary.self, from: stringData)
    } catch {
        print(error)
    }

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

func readImageFromFile(_ id: UUID, library: PhotosLibrary, completion: @escaping (UIImage?) -> Void) async {
    let filepath = photosFilePath(library.id).appendingPathComponent(id.uuidString + ".heic")
    let uiImage = UIImage(contentsOfFile: filepath.path)
    if uiImage == nil {print("Image file not found in path: \(filepath)")}
    completion(uiImage)
}
func readFullImageFromFile(_ id: UUID, library: PhotosLibrary, completion: @escaping (UIImage?) -> Void) async {
    let filepath = photosFullFilePath(library.id).appendingPathComponent(id.uuidString + ".heic")
    let uiImage = UIImage(contentsOfFile: filepath.path)
    if uiImage == nil {print("Image file not found in path: \(filepath)")}
    completion(uiImage)
}

func writeImageToFile(uiImage: UIImage, library: PhotosLibrary) -> UUID? {
    let dataFull = uiImage.heic()

    let size: CGSize
    if uiImage.size.width > uiImage.size.height {
        let coefficient = uiImage.size.width / 512
        size = CGSize(width: 512, height: uiImage.size.height / coefficient)
    } else {
        let coefficient = uiImage.size.height / 512
        size = CGSize(width: uiImage.size.width / coefficient, height: 512)
    }

    let renderer = UIGraphicsImageRenderer(size: size)
    let uiImageMini = renderer.image { (_) in
        uiImage.draw(in: CGRect(origin: .zero, size: size))
    }
    let data = uiImageMini.heic(compressionQuality: 0.7)

    if let data, let dataFull {
        let uuid = UUID()
        let filepath = photosFilePath(library.id).appendingPathComponent(uuid.uuidString + ".heic")
        do {
            try FileManager().createDirectory(at: photosFilePath(library.id), withIntermediateDirectories: true)
            try data.write(to: filepath)
        } catch {
            print(error)
        }
        print("New image miniature file created in path \(filepath)")

        let filepathFull = photosFullFilePath(library.id).appendingPathComponent(uuid.uuidString + ".heic")
        do {
            try FileManager().createDirectory(at: photosFullFilePath(library.id), withIntermediateDirectories: true)
            try dataFull.write(to: filepathFull)
        } catch {
            print(error)
        }
        print("New image file created in path \(filepathFull)")
        return uuid
    }

    return nil
}
func removeImageFile(_ id: UUID, library: PhotosLibrary) -> (Bool, Error?) {
    let filepath = photosFilePath(library.id).appendingPathComponent(id.uuidString + ".heic")
    let filepathFull = photosFullFilePath(library.id).appendingPathComponent(id.uuidString + ".heic")
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
