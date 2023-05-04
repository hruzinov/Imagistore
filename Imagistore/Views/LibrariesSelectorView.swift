//
//  Created by Evhen Gruzinov on 20.04.2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct LibrariesSelectorView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var sceneSettings: SceneSettings
    @Binding var applicationSettings: ApplicationSettings
    @Binding var librariesCollection: PhotosLibrariesCollection?
    @State var librariesArray: [PhotosLibrary] = []
    @State private var libraryAvailable: [UUID: LibraryAvailable] = [:]
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
                                            switch libraryAvailable[library.id] {
                                            case .offline:
                                                Image(systemName: "externaldrive")
                                            case .online:
                                                Image(systemName: "cloud")
                                            case .both:
                                                Image(systemName: "externaldrive.badge.icloud")
                                            case .none:
                                                Image(systemName: "exclamationmark.circle")
                                            }
                                        }
                                        Text("ID: \(library.id.uuidString)").font(.caption)
                                        Text("Last change: \(DateTimeFunctions.dateToString(library.lastChangeDate))").font(.caption)
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
                        libraryAvailable[id] = .offline
                    }
                }

                if applicationSettings.isOnlineMode, let userUid = applicationSettings.userUid {
                    getOnlineLibraries(userUid: userUid)
                }
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
                            libraryAvailable[lib.id] = .offline
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

    private func getOnlineLibraries(userUid: String) {
        let db = Firestore.firestore()
        let onlineLibrariesRef = db.collection("users").document(userUid)

        onlineLibrariesRef.getDocument(as: DBUser.self) { result in
            switch result {
            case .success(let user):
                let onlineLibrariesCollection = PhotosLibrariesCollection()
                user.libraries.forEach { str in
                    if let uuid = UUID(uuidString: str) {
                        onlineLibrariesCollection.libraries.append(uuid)
                    }
                }

                onlineLibrariesCollection.libraries.forEach({ id in
                    if libraryAvailable[id] != nil {
                        libraryAvailable[id] = .both
                    } else {
                        let onlineLibraryRef = db.collection("libraries").document(id.uuidString)

                        onlineLibraryRef.getDocument(as: DBLibrary.self) { result in
                            switch result {
                            case .success(let library):
                                if let uuid = UUID(uuidString: library.id) {
                                    let locLibrary = PhotosLibrary(id: uuid, name: library.name, libraryVersion: library.libraryVersion, lastChangeDate: library.lastChangeDate,
                                                                   photos: [])
                                    librariesArray.append(locLibrary)
                                    libraryAvailable[id] = .online
                                }
                            case .failure(let error):
                                debugPrint(error)
                            }
                        }
                    }
                })

            case .failure(let error):
                print(error)
            }
        }
    }
    private func librarySelected(_ library: PhotosLibrary) {
        if libraryAvailable[library.id] == .offline {
            if applicationSettings.isOnlineMode, let userUid = applicationSettings.userUid {
                let db = Firestore.firestore()
                let onlineUserRef = db.collection("users").document(userUid)
                onlineUserRef.updateData(["libraries": FieldValue.arrayUnion([library.id.uuidString])])
            }
        } else if libraryAvailable[library.id] == .online {
            librariesCollection?.libraries.append(library.id)
            _ = librariesCollection?.saveLibraryCollection()
            _ = saveLibrary(lib: library)
        }

        applicationSettings.lastSelectedLibrary = library.id
        applicationSettings.save()

        selectedLibrary = library
    }

    private enum LibraryAvailable {
        case online
        case offline
        case both
    }
}
