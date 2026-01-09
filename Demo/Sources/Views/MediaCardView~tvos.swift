//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// Behavior: h-hug, v-hug
private struct CardTopTrailingView: View {
    let duration: String?
    let type: String?

    var body: some View {
        if let type {
            VStack {
                Image(systemName: type)
                if let duration {
                    Text(duration)
                        .font(.caption2)
                        .scaleEffect(0.7)
                }
            }
            .tint(.white)
            .shadow(color: .black, radius: 5)
            .padding()
        }
    }
}

// Behavior: h-hug, v-hug
private struct CardBottomView: View {
    let title: String?
    let subtitle: String?
    let date: String?

    var body: some View {
        VStack(spacing: 5) {
            if let title {
                Text(title)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 30)
                    .padding(.bottom, subtitle == nil ? 30 : 0)
                    .lineLimit(1)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            if let subtitle {
                Text(subtitle)
                    .foregroundStyle(Color(uiColor: UIColor.lightGray))
                    .font(.caption2)
                    .padding(.horizontal, 50)
                    .padding(.bottom, date == nil ? 30 : 0)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            if let date {
                Text(date)
                    .foregroundStyle(Color(uiColor: UIColor.lightGray))
                    .font(.caption2)
                    .scaleEffect(0.7)
                    .padding(.bottom, 10)
            }
        }
    }
}

// Behavior: h-hug, v-hug
struct MediaCardView: View {
    let size: CGSize
    let title: String?
    let subtitle: String?
    let imageUrl: URL?
    let type: String?
    let duration: String?
    let date: String?

    var body: some View {
        ZStack(alignment: .center) {
            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    EmptyView()
                }
            }
            .overlay {
                LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black]), startPoint: .top, endPoint: .bottom)
            }
            .frame(width: size.width, height: size.height, alignment: .center)

            VStack {
                CardTopTrailingView(duration: duration, type: type)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Spacer()
                CardBottomView(title: title, subtitle: subtitle, date: date)
            }
        }
        .frame(width: size.width, height: size.height, alignment: .center)
    }

    init(
        size: CGSize = .init(width: 570, height: 350),
        title: String?,
        subtitle: String? = nil,
        imageUrl: URL? = nil,
        type: String? = nil,
        duration: String? = nil,
        date: String? = nil
    ) {
        self.size = size
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.type = type
        self.duration = duration
        self.date = date
    }
}
