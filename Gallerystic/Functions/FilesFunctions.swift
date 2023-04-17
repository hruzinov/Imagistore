//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI

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
