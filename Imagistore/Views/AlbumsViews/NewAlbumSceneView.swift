//
//  Created by Evhen Gruzinov on 03.06.2023.
//

import SwiftUI

struct NewAlbumSceneView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var sceneSettings: SceneSettings
    @State var library: PhotosLibrary
    @State var albumTitle: String = ""
    @State var albumType: AlbumType = .simple
    
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
                            print("In production")
                            // do nothing
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
