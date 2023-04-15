//
//  Created by Evhen Gruzinov on 08.04.2023.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case library, albums
}

struct CustomTabBar: View {
    @Binding var selection: Tab
    @EnvironmentObject var dispayingSettings: DispayingSettings
    
    var body: some View {
        if dispayingSettings.isShowingTabBar {
            HStack {
                Button {
                    withAnimation(.easeInOut) {
                        selection = .library
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: "photo.artframe").font(.title2)
                        Text("Library").font(.caption)
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
                        Text("Albums").font(.caption)
                    }
                    .foregroundColor(selection == .albums ? .blue : .gray)
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
