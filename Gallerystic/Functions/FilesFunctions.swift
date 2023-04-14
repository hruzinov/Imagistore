//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI

fileprivate let libraryPath = getDocumentsDirectory().appendingPathComponent("library.json")
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


func saveLibrary(lib: PhotosLibrary) -> Error? {
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

func loadLibrary() -> PhotosLibrary {
    let stringData = try? String(contentsOf: libraryPath).data(using: .utf8)
    print("Library loaded in path \(libraryPath)")
    
    guard let stringData else {
        let newLibrary = PhotosLibrary(libraryVersion: ApplicationSettings.actualLibraryVersion, photos: [])
        _ = saveLibrary(lib: newLibrary)
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
    let filepath = photosFilePath.appendingPathComponent(id.uuidString + ".\(fileExtention.rawValue)")
    let uiImage = UIImage(contentsOfFile: filepath.path)
    if uiImage == nil {print("Image file not found in path: \(filepath)")}
    return uiImage
}

func readCompressedImageFromFile(id: UUID, fileExtention: PhotoExtention) -> UIImage? {
    let filepath = photosFilePath.appendingPathComponent(id.uuidString + ".\(fileExtention.rawValue)")
    let uiImage = downsample(imageAt: filepath)
    if uiImage == nil {print("Image file not found in path: \(filepath)")}
    return uiImage
}

func writeImageToFile(uiImage: UIImage, fileExtention: String) -> UUID? {
    
    var data: Data?
    if fileExtention == "png" {
        data = uiImage.pngData()
    } else {
        data = uiImage.jpegData(compressionQuality: 1)
    }
    
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
        let filepath = photosFilePath.appendingPathComponent(uuid.uuidString + ".\(fileExtention)")
        try? data.write(to: filepath)
        
        print("New image file created in path \(filepath)")

        return uuid
    }
    
    return nil
}
func removeImageFile(id: UUID, fileExtention: PhotoExtention) -> (Bool, Error?) {
    let filepath = photosFilePath.appendingPathComponent(id.uuidString + ".\(fileExtention)")
    do {
        try FileManager.default.removeItem(atPath: filepath.path)
        print("Image file deleted from path \(filepath)")
        return (true, nil)
    } catch {
        print(error)
        return (false, error)
    }
}

func downsample(imageAt imageURL: URL,
                to pointSize: CGSize = UIScreen.main.bounds.size,
                scale: CGFloat = UIScreen.main.scale) -> UIImage? {
    
    // Create an CGImageSource that represent an image
    let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else {
        return nil
    }
    
    // Calculate the desired dimension
    let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
    
    // Perform downsampling
    let downsampleOptions = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
    ] as [CFString : Any] as CFDictionary
    guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
        return nil
    }
    
    // Return the downsampled image as UIImage
    return UIImage(cgImage: downsampledImage)
}
