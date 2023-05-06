//
//  Created by Evhen Gruzinov on 20.04.2023.
//

import SwiftUI

struct LibrariesSelectorView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var sceneSettings: SceneSettings
    @Binding var applicationSettings: ApplicationSettings
    @Binding var librariesCollection: PhotosLibrariesCollection?
    @State var librariesArray: [PhotosLibrary] = []
    @Binding var selectedLibrary: PhotosLibrary?
    @State private var isShowingAddLibSheet: Bool = false

    @State var newLibraryName: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                Divider()
                if librariesArray.count > 0 {
                    ForEach(librariesArray) { library in
                        Button(action: {
                            withAnimation {
                                librarySelected(library)
                            }
                        }, label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack(spacing: 5) {
                                        Text(library.name).font(.title2).bold()
                                    }
                                    Text("ID: \(library.id.uuidString)").font(.caption)
                                    Text("Last change: \(DateTimeFunctions.dateToString(library.lastChangeDate))")
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(Color.primary)
                        })
                        .padding(.horizontal, 15)
                        .padding(.vertical, 5)
                        Divider()
                    }
                }
            }
            .onAppear {
                let libsIds = librariesCollection?.libraries
                libsIds?.forEach { id in
                    if let library = loadLibrary(id: id) {
                        librariesArray.append(library)
                    }
                }

                //                if applicationSettings.isOnlineMode, let userUid = applicationSettings.userUid {
                //                    getOnlineLibraries(userUid: userUid)
                //                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingAddLibSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }

                }
            }
            .navigationTitle("Libraries")
        }
        .sheet(isPresented: $isShowingAddLibSheet, content: {
            Form {
                Section("New Library") {
                    TextField("Library name", text: $newLibraryName)
                    Button {
                        let lib = PhotosLibrary(id: UUID(), name: newLibraryName)
                        let err = saveLibrary(lib: lib)
                        if let err {
                            print(err)
                        } else {
                            librariesCollection?.libraries.append(lib.id)
                            librariesArray.append(lib)
                            let err = librariesCollection?.saveLibraryCollection()
                            if let err {
                                print(err)
                            }
                        }
                        isShowingAddLibSheet = false
                    } label: {
                        Text("Create")
                    }.disabled(newLibraryName.count == 0)
                }
                Button(role: .destructive) {
                    isShowingAddLibSheet = false
                } label: {
                    Text("Cancel")
                }
            }
        })
    }

    private func librarySelected(_ library: PhotosLibrary) {
        applicationSettings.lastSelectedLibrary = library.id
        applicationSettings.save()

        selectedLibrary = library
    }
}
