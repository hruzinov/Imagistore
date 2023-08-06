//
//  Created by Evhen Gruzinov on 20.06.2023.
//

import SwiftUI

struct EditTagsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State var newKeyword: String = ""
    @State var selectedImages: [UUID]
    @State var photos: FetchedResults<Photo>
    @Binding var isChanged: Bool

    var allKeywords: [String] {
        var keys: [String] = []
        for image in photos {
            if let imageKeywords = image.keywords {
                keys += imageKeywords
            }
        }
        return Array(Set(keys))
    }
    var selectedImagesKeywords: [String: KeywordState] {
        var keysDict: [String: KeywordState] = [:]
        var selectedKeywords: [String] = []

        for selectedImage in selectedImages {
            if let keywords = photos.first(where: {$0.uuid == selectedImage})?.keywords {
                selectedKeywords += keywords
            }
        }
        selectedKeywords = Array(Set(selectedKeywords))

        for key in selectedKeywords {
            var isInAll = true
            for selectedImage in selectedImages {
                if let keywords = photos.first(where: {$0.uuid == selectedImage})?.keywords {
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
        for keyword in allKeywords {
            if !selectedImagesKeywords.keys.contains(keyword) {
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
                                        if selectedPhoto.keywords == nil {
                                            selectedPhoto.keywords = []
                                        }
                                        
                                        if newKeyword != "anyKeyword", !selectedPhoto.keywords!.contains(newKeyword) {
                                            selectedPhoto.keywords?.append(newKeyword)
                                        }
                                        
                                    }
                                }
                            }
                            do {
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
                    }.disabled(newKeyword.count == 0)
                }
                TagsCloudUIView(keywords: selectedImagesKeywords, selectedImages: selectedImages,
                                photos: $photos, isChanged: $isChanged)
                    .padding(.top, 10)
                TagsCloudUIView(keywords: freeKeywords, selectedImages: selectedImages, photos: $photos, isChanged: $isChanged)
            }
        }
    }
}
