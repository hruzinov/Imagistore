//
//  Created by Evhen Gruzinov on 08.04.2023.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case library, albums, settings
}

struct CustomTabBar: View {
    @Binding var selection: Tab
    @EnvironmentObject var sceneSettings: SceneSettings

    var body: some View {
        if sceneSettings.isShowingTabBar {
            HStack {
                Button {
                    withAnimation(.easeInOut) {
                        selection = .library
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "photo.fill").font(.title2)
                        Text("Photos").font(.caption).bold()
                    }
                    .foregroundColor(selection == .library ? .blue : .gray)
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, 10)

                Button {
                    withAnimation(.easeInOut) {
                        selection = .albums
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "sparkles.rectangle.stack").font(.title2)
                        Text("Albums").font(.caption).bold()
                    }
                    .foregroundColor(selection == .albums ? .blue : .gray)
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, 10)

                Button {
                    withAnimation(.easeInOut) {
                        selection = .settings
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "gear").font(.title2)
                        Text("Settings").font(.caption).bold()
                    }
                    .foregroundColor(selection == .settings ? .blue : .gray)
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, 10)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .padding(.vertical, 10)
            .background(.ultraThickMaterial)
        }
    }
}
