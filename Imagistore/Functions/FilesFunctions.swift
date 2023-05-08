//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI

private let documentsDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
private func photosFilePath(_ libID: UUID) -> URL {
    documentsDirectory.appendingPathComponent("fullSizes/\(libID.uuidString)/")
}
fileprivate func directoryExistsAtPath(_ path: String) -> Bool {
    var isDirectory: ObjCBool = true
    let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
    return exists && isDirectory.boolValue
}

func readImageFromFile(_ id: UUID, library: PhotosLibrary, completion: @escaping (UIImage?) -> Void) async {
    let filepath = photosFilePath(library.id).appendingPathComponent(id.uuidString + ".heic")
    let uiImage = UIImage(contentsOfFile: filepath.path)
    if uiImage == nil {print("Image file not found in path: \(filepath)")}
    completion(uiImage)
}
func writeImageToFile(_ uuid: UUID, uiImage: UIImage, library: PhotosLibrary) -> Bool {
    let data = uiImage.heic()
    let libraryPath = photosFilePath(library.id)

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

func removeImageFile(_ id: UUID, library: PhotosLibrary) -> (Bool, Error?) {
    let filepath = photosFilePath(library.id).appendingPathComponent(id.uuidString + ".heic")
    do {
        try FileManager.default.removeItem(atPath: filepath.path)
        print("Image file deleted from path \(filepath)")
        return (true, nil)
    } catch {
        switch error._code {
        case 4:
            print("An obscure image has been deleted")
            return (true, nil)
        default:
            print(error)
            return (false, error)
        }
    }
}
