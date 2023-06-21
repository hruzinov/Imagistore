//
//  Created by Evhen Gruzinov on 20.06.2023.
//

import SwiftUI

struct EditTagsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State var newKeyword: String = ""
    @State var selectedImage: UUID
    var photos: FetchedResults<Photo>

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
                TagsCloudUIView(selectedImage: $selectedImage, photos: photos)

                HStack {
                    TextField("New Keyword", text: $newKeyword)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 250)
                    Button {
                        if newKeyword.count > 0 {
                            let selectedPhoto = photos.first(where: {$0.uuid == selectedImage})
                            if let selectedPhoto {
                                withAnimation {
                                    if selectedPhoto.keywords == nil {
                                        selectedPhoto.keywords = []
                                    }

                                    if !selectedPhoto.keywords!.contains(newKeyword) {
                                        selectedPhoto.keywords?.append(newKeyword)
                                        do {
                                            try viewContext.save()
                                            newKeyword = ""
                                        } catch {
                                            debugPrint(error)
                                        }
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                            .background(Color.white)
                    }.disabled(newKeyword.count == 0)
                }.padding(.top, 15)
            }
        }
    }
}
