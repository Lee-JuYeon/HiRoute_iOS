//
//  PhotoGridCell.swift
//  HiRoute
//
//  Created by Jupond on 3/13/26.
//
import SwiftUI
import Photos

struct PhotoGridCell: View {
    let asset: PHAsset
    let selectionIndex: Int?
    let onTap: () -> Void

    @State private var thumbnail: UIImage? = nil

    var body: some View {
        GeometryReader { geo in
            let cellSize = geo.size.width
            ZStack {
                // Thumbnail
                Group {
                    if let thumbnail = thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Color.getColour(.fill_alternative)
                    }
                }
                .frame(width: cellSize, height: cellSize)
                .clipped()

                // Dim overlay when selected
                if selectionIndex != nil {
                    Color.black.opacity(0.2)
                        .frame(width: cellSize, height: cellSize)
                }

                // Selection badge (top-right)
                VStack {
                    HStack {
                        Spacer()
                        selectionBadge()
                            .padding(6)
                    }
                    Spacer()
                }
                .frame(width: cellSize, height: cellSize)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .onAppear { loadThumbnail() }
    }

    @ViewBuilder
    private func selectionBadge() -> some View {
        if let index = selectionIndex {
            ZStack {
                Circle()
                    .fill(Color.getColour(.label_strong))
                Circle()
                    .stroke(Color.getColour(.background_white), lineWidth: 2)
                Text("\(index)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.getColour(.background_white))
            }
            .frame(width: 26, height: 26)
        } else {
            Circle()
                .stroke(Color.white.opacity(0.7), lineWidth: 2)
                .frame(width: 26, height: 26)
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
    }

    private func loadThumbnail() {
        guard thumbnail == nil else { return }
        let targetSize = CGSize(width: 300, height: 300)
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true

        PHImageManager.default().requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                if let image = image {
                    self.thumbnail = image
                }
            }
        }
    }
}
