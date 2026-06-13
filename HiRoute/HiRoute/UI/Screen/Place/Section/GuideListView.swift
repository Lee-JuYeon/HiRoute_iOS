//
//  GuideListView.swift
//  HiRoute
//
//  Created by Jupond on 4/7/26.
//
import SwiftUI

struct GuideListView: View {
    let guides: [GuideItem]

    @EnvironmentObject private var audioPlayerVM: AudioPlayerVM
    @State private var selectedPriceItem: PriceModel?
    @State private var showPriceSheet = false

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(guides) { guide in
                    guideSection(guide)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showPriceSheet) {
            if let item = selectedPriceItem {
                PriceDetailSheet(priceItem: item)
            }
        }
    }

    @ViewBuilder
    private func guideSection(_ guide: GuideItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                if let icon = guide.icon {
                    Text(icon)
                }
                Text(guide.title)
                    .font(.headline)
                    .fontWeight(.bold)
            }

            // Blocks
            ForEach(Array(guide.blocks.enumerated()), id: \.offset) { _, block in
                contentBlockRenderer(block, guideTitle: guide.title)
            }
        }
    }

    @ViewBuilder
    private func contentBlockRenderer(_ block: ContentBlock, guideTitle: String) -> some View {
        switch block {
        case .text(let body):
            Text(body)
                .font(.body)
                .foregroundColor(.secondary)

        case .image(let url, let caption):
            VStack(alignment: .leading, spacing: 4) {
                ServerImageView(setImageURL: url)
                    .aspectRatio(16/9, contentMode: .fit)
                    .cornerRadius(8)
                if let caption = caption {
                    Text(caption).font(.caption).foregroundColor(.secondary)
                }
            }

        case .audio(let url, let duration, _):
            Button(action: {
                audioPlayerVM.play(url: url, title: guideTitle)
            }) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 32))
                    VStack(alignment: .leading) {
                        Text("재생")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(formatDuration(duration))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)

        case .list(let items):
            VStack(spacing: 0) {
                ForEach(items) { item in
                    HStack {
                        Text(item.label)
                            .font(.subheadline)
                        Spacer()
                        if let value = item.value {
                            Text(value)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    if item.id != items.last?.id {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)

        case .price(let items):
            VStack(spacing: 0) {
                ForEach(items) { item in
                    Button(action: {
                        selectedPriceItem = item
                        showPriceSheet = true
                    }) {
                        HStack {
                            Text(item.label)
                                .font(.subheadline)
                            if let percent = item.discountPercent {
                                Text("✺\(percent)%")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            Spacer()
                            Text(item.displayPrice)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                    if item.id != items.last?.id {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
