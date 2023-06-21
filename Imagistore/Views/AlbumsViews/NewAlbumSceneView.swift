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
    @State var filterOptions: [[String: Any]] = [[:]]

    @State var newKeywordFilter: String? = nil

    var allKeywords: [String] {
        var allKeywords = [String]()
        photos.forEach { photo in
            if let keywords = photo.keywords {
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
                        ForEach(0..<filterOptions.count, id: \.self) { index in
                            let filter = filterOptions[index]
                            let type = filter["type"] as? String

                            if let type, type == "tagFilter", let keyword = filter["filterBy"] as? String {
                                Text("**Tag \(filter["logicalNot"] as! Bool ? "is not" : "is"):** \(keyword)")
                                    .onAppear {
                                        print(filter)
                                    }
                            }
                        }

                        NavigationLink {
                            SelectTag(allKeywords: allKeywords, selectedKeywords: $selectedKeywords, filterOptions: $filterOptions)
                        } label: {
                            Label("Add keyword", systemImage: "plis")
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
                            newAlbum.photos = [UUID]()
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
                            newAlbum.photos = [UUID]()
                            newAlbum.filterOptions =  filterOptions
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
    @Binding var filterOptions: [[String: Any]]

    @State var logicalNot = false

    var body: some View {
        Form {
            Picker("", selection: $logicalNot) {
                Text("Tag is").tag(false)
                Text("Tag is not").tag(true)
            }.pickerStyle(.segmented)
            ForEach(allKeywords, id: \.self) { keyword in
                if !selectedKeywords.contains(keyword) {
                    Button {
                        filterOptions.append(
                            [
                                "type": "tagFilter",
                                "filterBy": keyword,
                                "logicalNot": logicalNot
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
