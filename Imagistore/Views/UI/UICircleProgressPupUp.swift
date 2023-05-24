//
//  Created by Evhen Gruzinov on 14.04.2023.
//

import SwiftUI

struct UICircleProgressPupUp: View {
    @Binding var progressText: String
    @Binding var progressValue: Double
    @Binding var progressFinal: Bool

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0), lineWidth: 10)
                if progressFinal {
                    Image(systemName: progressValue == 1 ? "checkmark.circle" :
                            "checkmark.circle.trianglebadge.exclamationmark")
                    .font(Font.system(size: 80))
                } else {
                    Circle()
                        .trim(from: 0, to: progressValue)
                        .stroke(Color.primary, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
            }
            .frame(width: 80, height: 80, alignment: .center)

            Text(progressText)
        }
        .frame(width: 160, height: 160)
        .background {
            RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial)
        }
    }
}

struct CircleProgressPupUp_Previews: PreviewProvider {
    static var previews: some View {
        UICircleProgressPupUp(progressText: .constant("test text"),
                              progressValue: .constant(0.5), progressFinal: .constant(true))
    }
}
