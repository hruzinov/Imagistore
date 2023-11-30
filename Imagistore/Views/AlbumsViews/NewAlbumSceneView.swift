//
//  Created by Evhen Gruzinov on 03.06.2023.
//

import SwiftUI

struct NewAlbumSceneView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var sceneSettings: SceneSettings

    var photos: FetchedResults<Photo>

    @State var library: PhotosLibrary
    @State var albumTitle: String = ""
    @State var albumType: AlbumType = .simple
    @State var filterOptions: [[String: String]] = []

    @State var newKeywordFilter: String? = nil
    @State var filterMode: String = "AND"
    @State var isAnyKeywordSelected = false

    var allKeywords: [String] {
        var allKeywords = [String]()
        photos.forEach { photo in
            if let keywords = JSONToSet(photo.keywordsJSON) {
                keywords.forEach { tag in
                    if !allKeywords.contains(tag) {
                        allKeywords.append(tag)
                    }
                }
            }
        }
        return allKeywords.sorted { $0 < $1 }
    }
    @State var selectedKeywords: [String] = []

    var body: some View {
        NavigationStack {
            Form {
                TextField("Album title", text: $albumTitle).padding(0)
                Section("Album type") {
                    Picker("Album type", selection: $albumType) {
                        ForEach(AlbumType.allCases) { type in
                            Text(type.rawValue.capitalized)
                        }
                    }.pickerStyle(.segmented)

                    if albumType == .smart {
                        List {
                            ForEach(0..<filterOptions.count, id: \.self) { index in
                                let filter = filterOptions[index]
                                let type = filter["type"]
                                
                                if let type, type == "tagFilter", let keyword = filter["filterBy"] {
                                    if keyword == "anyKeyword" {
                                        Text(filter["logicalNot"] == "true" ? "Not contain keywords" : "Contain any keyword")
                                            .swipeActions {
                                                Button(role: .destructive) {
                                                    withAnimation {
                                                        filterOptions.remove(at: index)
                                                        isAnyKeywordSelected = false
                                                    }
                                                } label: {
                                                    Image(systemName: "trash")
                                                }
                                            }
                                            .onAppear {
                                                isAnyKeywordSelected = true
                                            }
                                    } else if !isAnyKeywordSelected {
                                        Text("Keyword \(filter["logicalNot"] == "true" ? "is not" : "is"): \(keyword)")
                                            .swipeActions {
                                                Button(role: .destructive) {
                                                    filterOptions.remove(at: index)
                                                } label: {
                                                    Image(systemName: "trash")
                                                }
                                            }
                                    }
                                }
                            }
                        }

                        if !isAnyKeywordSelected {
                            if filterOptions.count > 1 {
                                Picker("Filtering mode:", selection: $filterMode) {
                                    Text("AND").tag("AND")
                                    Text("OR").tag("OR")
                                }.pickerStyle(.menu)
                            }

                            NavigationLink {
                                SelectTag(allKeywords: allKeywords, selectedKeywords: $selectedKeywords, filterOptions: $filterOptions)
                            } label: {
                                Label("Add keyword", systemImage: "plus")
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        switch albumType {
                        case .simple:
                            let newAlbum = Album(context: viewContext)
                            newAlbum.uuid = UUID()
                            newAlbum.library = library.uuid
                            newAlbum.photosSet = setToJSON(Set<String>())!
                            newAlbum.title = albumTitle
                            newAlbum.creationDate = Date()

                            if library.albums == nil {
                                library.albums = []
                            }

                            library.albums?.append(newAlbum.uuid)

                            do {
                                try viewContext.save()
                                dismiss()
                            } catch {
                                sceneSettings.errorAlertData = error.localizedDescription
                                sceneSettings.isShowingErrorAlert.toggle()
                            }

                        case .smart:
                            let newAlbum = Album(context: viewContext)
                            newAlbum.uuid = UUID()
                            newAlbum.library = library.uuid
                            newAlbum.title = albumTitle
                            newAlbum.creationDate = Date()
                            newAlbum.photosSet = setToJSON(Set<String>())!
                            newAlbum.filterOptionsSet = optionsToJSON(filterOptions)
                            newAlbum.filterMode = filterMode
                            do {
                                try viewContext.save()
                                dismiss()
                            } catch {
                                sceneSettings.errorAlertData = error.localizedDescription
                                sceneSettings.isShowingErrorAlert.toggle()
                            }
                        }
                    } label: {
                        Text("Create")
                    }.disabled(albumTitle.count == 0)
                }
            }
        }
        .onAppear {
            sceneSettings.isShowingTabBar = false
        }
        .onDisappear {
            sceneSettings.isShowingTabBar = true
        }
    }
}

private struct SelectTag: View {
    @Environment(\.dismiss) private var dismiss
    @State var allKeywords: [String]
    @Binding var selectedKeywords: [String]
    @Binding var filterOptions: [[String: String]]

    @State var logicalNot = false

    var body: some View {
        Form {
            Picker("", selection: $logicalNot) {
                Text("Keyword is").tag(false)
                Text("Keyword is not").tag(true)
            }.pickerStyle(.segmented)

            Button {
                filterOptions.append(
                    [
                        "type": "tagFilter",
                        "filterBy": "anyKeyword",
                        "logicalNot": logicalNot ? "true" : "false"
                    ]
                )
                selectedKeywords.append("Any keyword")
                dismiss()
            } label: {
                Text("Any keyword")
            }

            ForEach(allKeywords, id: \.self) { keyword in
                if !selectedKeywords.contains(keyword) {
                    Button {
                        filterOptions.append(
                            [
                                "type": "tagFilter",
                                "filterBy": keyword,
                                "logicalNot": logicalNot ? "true" : "false"
                            ]
                        )
                        selectedKeywords.append(keyword)
                        dismiss()
                    } label: {
                        Text(keyword)
                    }
                }
            }
        }
    }
}
