//
//  Created by Evhen Gruzinov on 21.08.2023.
//

import SwiftUI

struct SettingsSceneView: View {
    @Binding var goToPhotosLibrary: Bool

    var body: some View {
        NavigationStack {
            List {
                Button {
                    goToPhotosLibrary.toggle()
                } label: {
                    HStack {
                        Text("Libraries Selector")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsSceneView(goToPhotosLibrary: .constant(false))
}
