//
//  Created by Evhen Gruzinov on 20.06.2023.
//

import SwiftUI

struct EditTagsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State var newKeyword: String = ""
    @Binding var isChanged: Bool
    @State var photos: FetchedResults<Photo>

    @State var allKeywords: Set<String>

    var library: PhotosLibrary
    var selectedImages: [UUID]

    init(selectedImages: [UUID], photos: FetchedResults<Photo>, library: PhotosLibrary, isChanged: Binding<Bool>) {
        self.selectedImages = selectedImages
        self._photos = State(initialValue: photos)
        self._isChanged = isChanged
        self.library = library

        var keys: Set<String> = []
        for image in photos {
            if let imageKeywords = JSONToSet(image.keywordsJSON) {
                for key in imageKeywords {
                    keys.insert(key)
                }
            }
        }
        self._allKeywords = State(initialValue: keys)
    }

//    var allKeywords: Set<String> {
//        var keys: Set<String> = []
//        for image in photos {
//            if let imageKeywords = JSONToSet(image.keywordsJSON) {
//                for key in imageKeywords {
//                    keys.insert(key)
//                }
//            }
//        }
//        return keys
//    }
    var selectedImagesKeywords: [String: KeywordState] {
        var keysDict: [String: KeywordState] = [:]
        var selectedKeywords: [String] = []

        for selectedImage in selectedImages {
            if let keywords = JSONToSet(photos.first(where: {$0.uuid == selectedImage})?.keywordsJSON) {
                selectedKeywords += keywords
            }
        }
        selectedKeywords = Array(Set(selectedKeywords))

        for key in selectedKeywords {
            var isInAll = true
            for selectedImage in selectedImages {
                if let keywords = photos.first(where: {$0.uuid == selectedImage})?.keywordsJSON {
                    if !keywords.contains(key) {
                        isInAll = false
                        break
                    }
                }
                else {
                    isInAll = false
                    break
                }
            }

            if isInAll {
                keysDict.updateValue(.inAll, forKey: key)
            } else {
                keysDict.updateValue(.partical, forKey: key)
            }
        }

        return keysDict
    }
    var freeKeywords: [String: KeywordState] {
        var keys: [String: KeywordState] = [:]
        let selectedKeywords = selectedImagesKeywords
        for keyword in allKeywords {
            if !selectedKeywords.keys.contains(keyword) {
                keys.updateValue(.none, forKey: keyword)
            }
        }
        return keys
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle").font(.title2)
                }
                .padding(.top, 15)
                .padding(.trailing, 15)
            }
            ScrollView {
                HStack {
                    TextField("New Keyword", text: $newKeyword)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 250)
                    Button {
                        if newKeyword.count > 0 {
                            for selectedImage in selectedImages {
                                let selectedPhoto = photos.first(where: {$0.uuid == selectedImage})
                                if let selectedPhoto {
                                    withAnimation {
                                        if JSONToSet(selectedPhoto.keywordsJSON) == nil {
                                            selectedPhoto.keywordsJSON = setToJSON([])
                                        }
                                        
                                        if newKeyword != "anyKeyword", !JSONToSet(selectedPhoto.keywordsJSON)!.contains(newKeyword) {
                                            var currentSet = JSONToSet(selectedPhoto.keywordsJSON)!
                                            currentSet.insert(newKeyword)
                                            selectedPhoto.keywordsJSON = setToJSON(currentSet)
                                            allKeywords.insert(newKeyword)
                                        }
                                    }
                                }
                            }
                            do {
                                library.lastChange = Date.now
                                try viewContext.save()
                                isChanged = true
                            } catch {
                                debugPrint(error)
                            }
                            newKeyword = ""
                        }
                    } label: {
                        Image(systemName: "plus")
                            .background(Color.white)
                            .foregroundStyle(.black)
                    }.disabled(newKeyword.count == 0)
                }
                TagsCloudUIView(keywords: selectedImagesKeywords, selectedImages: selectedImages, library: library,
                                photos: $photos, isChanged: $isChanged)
                    .padding(.top, 10)
                TagsCloudUIView(keywords: freeKeywords, selectedImages: selectedImages, library: library, photos: $photos, isChanged: $isChanged)
            }
        }
    }
}
