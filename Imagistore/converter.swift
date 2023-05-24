//
//  converter.swift
//  Imagistore
//
//  Created by Evhen Gruzinov on 13.05.2023.
//

import Foundation
import CoreData

//oldPhotosToNew(library: photosLibrary, context: viewContext)

//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI

class PhotoOLD: Identifiable, Codable {
    var id: UUID
    var status: PhotoStatusOLD
    var creationDate: Date
    var importDate: Date
    var deletionDate: Date?
    var fileExtension: String
    var keywords: [String]

    init(id: UUID, status: PhotoStatusOLD, creationDate: Date, importDate: Date, deletionDate: Date? = nil, fileExtension: String, keywords: [String]) {
        self.id = id
        self.status = status
        self.creationDate = creationDate
        self.importDate = importDate
        self.deletionDate = deletionDate
        self.fileExtension = fileExtension
        self.keywords = keywords
    }

    static func == (lhs: PhotoOLD, rhs: PhotoOLD) -> Bool {
        lhs.id == rhs.id
    }
}

extension PhotoOLD: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}

enum PhotoStatusOLD: String, Codable {
    case normal, deleted
}

enum PhotoExtention: String, Codable {
    case jpg
    case png
}

class PhotosLibrariesCollection: Codable {
    var libraries: [UUID]
    init() {
        libraries = []
    }
}

class PhotosLibraryOLD: Identifiable, Codable, ObservableObject {
    static var actualLibraryVersion = 1
    var id: UUID
    var name: String
    var libraryVersion: Int
    var lastChangeDate: Date
    var photos: [PhotoOLD]

    init(id: UUID, name: String, libraryVersion: Int = actualLibraryVersion,
         lastChangeDate: Date = Date(), photos: [PhotoOLD] = []) {
        self.id = id
        self.name = name
        self.libraryVersion = libraryVersion
        self.photos = photos
        self.lastChangeDate = lastChangeDate
    }
}
