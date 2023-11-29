//
//  Created by Evhen Gruzinov on 20.04.2023.
//

import SwiftUI

struct LibrariesSelectorView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var sceneSettings: SceneSettings

    @FetchRequest(sortDescriptors: [SortDescriptor(\.lastChange, order: .reverse)])
    var librariesCollection: FetchedResults<PhotosLibrary>

    @Binding var applicationSettings: ApplicationSettings
    @Binding var selectedLibrary: PhotosLibrary?

    @State private var isShowingAddLibAlert: Bool = false
    @State private var isShowingWrongNameAlert: Bool = false
    @State private var editStage: EditingStages = .creating
    @State private var editingLibrary: PhotosLibrary?

    @State var newLibraryName: String = ""

    var body: some View {
        NavigationStack {
            List {
                if librariesCollection.count > 0 {
                    ForEach(librariesCollection) { library in
                        Button(action: {
                            withAnimation {
                                librarySelected(library)
                            }
                        }, label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack(spacing: 5) {
                                        Text(library.name ?? "*No name*")
                                                .font(.title2).bold()
                                                .multilineTextAlignment(.leading)
                                    }
                                    Text("Photos: \(library.photosIDs.count)").font(.caption)

                                    #if DEBUG
                                    Text("ID: \(library.uuid.uuidString)").font(.caption)
                                    #endif

                                    Text("Last change: \(DateTimeFunctions.dateToString(library.lastChange))")
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(Color.primary)
                        })
                        .swipeActions(allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                library.deleteLibrary(in: viewContext) { error in
                                    if let error {
                                        DispatchQueue.main.async {
                                            sceneSettings.errorAlertData = error.localizedDescription
                                            sceneSettings.isShowingErrorAlert.toggle()
                                        }
                                    }
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                newLibraryName = library.name ?? "Library"
                                editingLibrary = library
                                editStage = .editing
                                isShowingAddLibAlert.toggle()
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Libraries")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        editStage = .creating
                        isShowingAddLibAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .frame( maxWidth: .infinity)
            .listStyle(GroupedListStyle())

            .alert("\(editStage.rawValue.capitalized) library", isPresented: $isShowingAddLibAlert) {
                        TextField("Library name", text: $newLibraryName)
                        Button {
                            if newLibraryName.count > 0 {
                                switch editStage {
                                case .creating:
                                    withAnimation {
                                        let newLib = PhotosLibrary(context: viewContext)
                                        newLib.uuid = UUID()
                                        newLib.name = newLibraryName
                                        newLib.photosIDs = []
                                        newLib.lastChange = Date()
                                        newLib.version = Int16(PhotosLibrary.actualLibraryVersion)

                                        do {
                                            try viewContext.save()
                                        } catch {
                                            let nsError = error as NSError
                                            debugPrint("Unable to save context: \(nsError), \(nsError.userInfo)")
                                        }
                                        newLibraryName = ""
                                    }
                                case .editing:
                                    withAnimation {
                                        if editingLibrary != nil {
                                            editingLibrary?.name = newLibraryName
                                        }
                                        do {
                                            try viewContext.save()
                                        } catch {
                                            let nsError = error as NSError
                                            debugPrint("Unable to save context: \(nsError), \(nsError.userInfo)")
                                        }
                                        newLibraryName = ""
                                    }
                                }
                            } else {
                                isShowingWrongNameAlert.toggle()
                            }
                        } label: {
                            Text("Save")
                        }
                    Button(role: .cancel) {
                        newLibraryName = ""
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
            }
            .alert("Wrong library name", isPresented: $isShowingWrongNameAlert) {
                Text("The library name must contain at least 1 character")
                Button {
                    isShowingAddLibAlert.toggle()
                } label: {
                    Text("Ok")
                }

            }
        }
    }

    private func librarySelected(_ library: PhotosLibrary) {
        selectedLibrary = library
    }
    private enum EditingStages: String {
        case creating, editing
    }
}
