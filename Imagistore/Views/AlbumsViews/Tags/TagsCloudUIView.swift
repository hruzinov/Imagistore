//
//  Created by Evhen Gruzinov on 20.06.2023.
//

import SwiftUI

struct TagsCloudUIView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var keywords: [String: KeywordState]
    var selectedImages: [UUID]
    var library: PhotosLibrary
    @Binding var photos: FetchedResults<Photo>
    @Binding var isChanged: Bool

    @State private var totalHeight = CGFloat.zero
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(keywords, in: photos, geometry: geometry)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: totalHeight)
    }
    
    private func generateContent(_ keywords: [String: KeywordState], in photos: FetchedResults<Photo>, geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        let sortedKeywords = keywords.sorted { k1, k2 in
            k1.key < k2.key
        }

        return ZStack(alignment: .topLeading) {
            ForEach(sortedKeywords, id: \.key) { tag, state in
                if tag != "anyKeyword" {
                    self.item(for: tag, state: state)
                        .padding([.horizontal, .vertical], 4)
                        .alignmentGuide(.leading, computeValue: { d in
                            if (abs(width - d.width) > geometry.size.width)
                            {
                                width = 0
                                height -= d.height
                            }
                            let result = width
                            if tag == sortedKeywords.last!.key {
                                width = 0 //last item
                            } else {
                                width -= d.width
                            }
                            return result
                        })
                        .alignmentGuide(.top, computeValue: {d in
                            let result = height
                            if tag == sortedKeywords.last!.key {
                                height = 0 // last item
                            }
                            return result
                        })
                }
            }
        }.background(viewHeightReader($totalHeight))
    }
    
    private func item(for text: String, state: KeywordState) -> some View {
        var color: Color {
            switch state {
            case .inAll:
                return Color.green
            case .partical:
                return Color.yellow
            case .none:
                return Color.gray
            }
        }

        return HStack {
            if state == .none || state == .partical {
                Button {
                    for selectedImage in selectedImages {
                        if photos.first(where: {$0.uuid == selectedImage})?.keywordsJSON == nil {
                            photos.first(where: {$0.uuid == selectedImage})?.keywordsJSON = setToJSON([])
                        }
                        var tagsSet = JSONToSet(photos.first(where: {$0.uuid == selectedImage})?.keywordsJSON)!
                        tagsSet.insert(text)
                        photos.first(where: {$0.uuid == selectedImage})?.keywordsJSON = setToJSON(tagsSet)
                    }
                    withAnimation {
                        do {
                            library.lastChange = Date.now
                            try viewContext.save()
                            isChanged = true
                        } catch {
                            debugPrint(error)
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }

            Text(text)
                .lineLimit(1)

            if state == .inAll || state == .partical {
                Button {
                    for selectedImage in selectedImages {
                        var tagsSet = JSONToSet(photos.first(where: {$0.uuid == selectedImage})?.keywordsJSON)!
                        if tagsSet.contains(text) {
                            tagsSet.remove(text)
                            photos.first(where: {$0.uuid == selectedImage})?.keywordsJSON = setToJSON(tagsSet)
                        }
                    }
                    withAnimation {
                        do {
                            library.lastChange = Date.now
                            try viewContext.save()
                            isChanged = true
                        } catch {
                            debugPrint(error)
                        }
                    }
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .padding(.all, 5)
        .font(.body)
        .background(color)
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
