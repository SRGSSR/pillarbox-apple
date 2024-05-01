//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

// Behavior: h-exp, v-exp
private struct MediaCell: View {
    let media: Media

    var body: some View {
        VStack(alignment: .leading) {
            Text(media.title)
            if let subtitle = media.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// Behavior: h-exp, v-exp
private struct PlaylistSelectionView: View {
    let model: PlaylistViewModel
    @State private var selectedTemplates: Set<Template> = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List(selection: $selectedTemplates) {
                section(title: "Original items", templates: model.templates)
                section(title: "Standard items", templates: model.otherStandardTemplates)
            }
            .environment(\.editMode, .constant(.active))
            .navigationBarTitle("Add a stream to the playlist")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: cancel)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add", action: add)
                        .disabled(selectedTemplates.isEmpty)
                }
            }
        }
        .tracked(name: "selection", levels: ["playlist"])
    }

    @ViewBuilder
    private func section(title: String, templates: [Template]) -> some View {
        if !templates.isEmpty {
            Section(title) {
                ForEach(templates, id: \.self) { template in
                    Text(template.title)
                }
            }
        }
    }

    private func cancel() {
        dismiss()
    }

    private func add() {
        model.add(from: Array(selectedTemplates))
        dismiss()
    }
}

// Behavior: h-exp, v-hug
private struct Toolbar: View {
    @ObservedObject var player: Player
    @ObservedObject var model: PlaylistViewModel

    @State private var isSelectionPlaylistPresented = false

    var body: some View {
        HStack {
            previousButton()
            Spacer()
            managementButtons()
            Spacer()
            nextButton()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $isSelectionPlaylistPresented) {
            PlaylistSelectionView(model: model)
        }
    }

    @ViewBuilder
    private func previousButton() -> some View {
        Button(action: player.returnToPrevious) {
            Image(systemName: "arrow.left")
        }
        .disabled(!player.canReturnToPrevious())
    }

    @ViewBuilder
    private func managementButtons() -> some View {
        HStack(spacing: 30) {
            Button(action: model.shuffle) {
                Image(systemName: "shuffle")
            }
            .disabled(model.isEmpty)
            Button(action: add) {
                Image(systemName: "plus")
            }
            Button(action: model.reload) {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
            .disabled(!model.canReload)
            Button(action: model.trash) {
                Image(systemName: "trash")
            }
            .disabled(model.isEmpty)
        }
    }

    @ViewBuilder
    private func nextButton() -> some View {
        Button(action: player.advanceToNext) {
            Image(systemName: "arrow.right")
        }
        .disabled(!player.canAdvanceToNext())
    }

    private func add() {
        isSelectionPlaylistPresented.toggle()
    }
}

// Behavior: h-exp, v-exp
struct PlaylistView: View {
    let templates: [Template]

    @StateObject private var model = PlaylistViewModel.persisted ?? PlaylistViewModel()
    @State private var layout: PlaybackView.Layout = .minimized

    var body: some View {
        VStack(spacing: 0) {
            PlaybackView(player: model.player, layout: $layout)
                .monoscopic(model.isMonoscopic)
                .supportsPictureInPicture()
#if os(iOS)
            if layout != .maximized {
                Toolbar(player: model.player, model: model)
                List($model.medias, id: \.self, editActions: .all, selection: $model.currentMedia) { $media in
                    MediaCell(media: media)
                }
            }
#endif
        }
        .animation(.defaultLinear, value: layout)
        .onAppear {
            model.templates = templates
            model.play()
        }
        .enabledForInAppPictureInPicture(persisting: model)
        .tracked(name: "playlist")
    }
}

extension PlaylistView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    PlaylistView(templates: [
        URLTemplate.onDemandVideoLocalHLS,
        URLTemplate.shortOnDemandVideoHLS,
        URLTemplate.dvrVideoHLS
    ])
}
