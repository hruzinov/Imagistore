//
//  CircleProgressPupup.swift
//  Gallerystic
//
//  Created by Evhen Gruzinov on 14.04.2023.
//

import SwiftUI

struct CircleProgressPupup: View {
    @Binding var progressText: String
    @Binding var progressValue: Double
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0), lineWidth: 10)
                if progressValue == 1 {
                    Image(systemName: "checkmark")
                        .font(Font.system(size: 80))
                } else {
                    Circle()
                        .trim(from: 0, to: progressValue)
                        .stroke(Color.primary, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
            }
            .frame(width: 100, height: 100)
            
            Text(progressText)
        }
        .frame(width: 160, height: 160)
        .background {
            RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial)
        }
    }
}

struct CircleProgressPupup_Previews: PreviewProvider {
    static var previews: some View {
        CircleProgressPupup(progressText: .constant("test text"), progressValue: .constant(1))
    }
}
