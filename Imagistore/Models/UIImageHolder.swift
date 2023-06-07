////
////  Created by Evhen Gruzinov on 17.04.2023.
////
//
//import SwiftUI
//import CloudKit
//
//class UIImageHolder: ObservableObject {
//    @Published var data: [UUID: UIImage]
//    private var fullsizeArr: [UUID]
//
//    init() {
//        data = [:]
//        fullsizeArr = []
//    }
//
////    func getAllUiImages(_ photos: FetchedResults<Photo>) async -> Bool {
////        photos.forEach { photo in
////            if let uuid = photo.uuid, photo.status == PhotoStatus.normal.rawValue,
////               let data = photo.miniature, let uiImage = UIImage(data: data) {
////                DispatchQueue.main.async {
////                    self.data.updateValue(uiImage, forKey: uuid)
////                }
////            }
////        }
////        return true
////    }
////    func getUiImage(_ photo: Photo) {
////        DispatchQueue.global().async {
////            if let uuid = photo.uuid,
////               let data = photo.miniature, let uiImage = UIImage(data: data) {
////                DispatchQueue.main.async {
////                    self.data.updateValue(uiImage, forKey: uuid)
////                }
////            }
////        }
////    }
//
//}
