//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProvider
import SRGDataProviderModel
import SwiftUI

#if os(tvOS)
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
    let description: String?
    let date: String?

    var body: some View {
        VStack(spacing: 5) {
            if let title {
                Text(title)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 30)
                    .padding(.bottom, description == nil ? 30 : 0)
                    .lineLimit(1)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            if let description {
                Text(description)
                    .foregroundStyle(Color(uiColor: UIColor.lightGray))
                    .font(.caption2)
                    .padding(.horizontal, 50)
                    .padding(.bottom, date == nil ? 30 : 0)
                    .lineLimit(2)
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
    static let width: CGFloat = 570
    static let height: CGFloat = 350

    let title: String?
    let subtitle: String?
    let image: SRGImage?
    let type: String?
    let duration: String?
    let date: String?

    var body: some View {
        ZStack(alignment: .center) {
            AsyncImage(url: SRGDataProvider.current!.url(for: image, size: .large)) { phase in
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
            .frame(width: Self.width, height: Self.height, alignment: .center)

            VStack {
                CardTopTrailingView(duration: duration, type: type)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Spacer()
                CardBottomView(title: title, description: subtitle, date: date)
            }
        }
        .frame(width: Self.width, height: Self.height, alignment: .center)
    }

    init(
        title: String?,
        subtitle: String? = nil,
        image: SRGImage? = nil,
        type: String? = nil,
        duration: String? = nil,
        date: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.type = type
        self.duration = duration
        self.date = date
    }
}
#endif
