//
//  Created by Evhen Gruzinov on 20.06.2023.
//

import SwiftUI

struct TagsCloudUIView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedImage: UUID
    var photos: FetchedResults<Photo>

    @State private var totalHeight = CGFloat.zero
    
    var body: some View {
        VStack {
            if let keywords = photos.first(where: {$0.uuid == selectedImage})?.keywords {
                GeometryReader { geometry in
                    self.generateContent(keywords, in: geometry)
                }
            } else {
                Text("No keywords yet")
            }
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(_ keywords: [String], in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(keywords, id: \.self) { tag in
                self.item(for: tag)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == keywords.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tag == keywords.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }
    
    private func item(for text: String) -> some View {
        HStack {
            Text(text)
                .lineLimit(1)
            Button {
                if let tagIndex = photos.first(where: {$0.uuid == selectedImage})?.keywords?.firstIndex(of: text) {
                    withAnimation {
                        photos.first(where: {$0.uuid == selectedImage})?.keywords?.remove(at: tagIndex)
                        do {
                            try viewContext.save()
                        } catch {
                            debugPrint(error)
                        }
                    }
                }
            } label: {
                Image(systemName: "xmark")
            }
        }
        .padding(.all, 5)
        .font(.body)
        .background(Color.blue)
        .foregroundColor(Color.white)
        .cornerRadius(5)
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
