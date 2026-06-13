//
//  SidebarListView.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

import SwiftUI

/// 범용 사이드바 리스트.
/// `SidebarItem` 준수 아이템을 받아 기본 row(아이콘 + 제목 + 선택 강조)를 그린다.
/// - `onDelete`가 nil이면 long press 삭제 메뉴를 붙이지 않는다.
struct SidebarListView<Item: SidebarItem>: View {

    let sectionTitle: String?
    let items: [Item]
    let selectedID: Item.ID?
    let emptyConfig: SidebarEmptyConfig
    let onSelect: (Item) -> Void
    let onDelete: ((Item) -> Void)?

    init(
        sectionTitle: String? = nil,
        items: [Item],
        selectedID: Item.ID?,
        emptyConfig: SidebarEmptyConfig,
        onSelect: @escaping (Item) -> Void,
        onDelete: ((Item) -> Void)? = nil
    ) {
        self.sectionTitle = sectionTitle
        self.items = items
        self.selectedID = selectedID
        self.emptyConfig = emptyConfig
        self.onSelect = onSelect
        self.onDelete = onDelete
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 2) {
                if items.isEmpty {
                    emptyState
                } else {
                    if let sectionTitle = sectionTitle {
                        Text(sectionTitle)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(Color.getColour(.label_assistive))
                            .padding(.horizontal, 14)
                            .padding(.top, 14)
                            .padding(.bottom, 6)
                    }

                    ForEach(items) { item in
                        rowWithMenu(item)
                    }
                }
            }
            .padding(.bottom, 24)
        }
    }

    // MARK: - Row

    @ViewBuilder
    private func rowWithMenu(_ item: Item) -> some View {
        if let onDelete = onDelete {
            row(item)
                .contextMenu {
                    Button(action: { onDelete(item) }) {
                        Label("삭제", systemImage: "trash")
                    }
                }
        } else {
            row(item)
        }
    }

    private func row(_ item: Item) -> some View {
        let isSelected = (item.id == selectedID)
        return Button(action: { onSelect(item) }) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: item.sidebarIconName)
                    .font(.system(size: 13))
                    .foregroundColor(Color.getColour(.label_neutral))
                    .padding(.top, 1)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.sidebarTitle)
                        .font(.subheadline)
                        .foregroundColor(Color.getColour(.label_normal))
                        .lineLimit(1)
                        .truncationMode(.tail)

                    if let subtitle = item.sidebarSubtitle {
                        Text(subtitle)
                            .font(.caption2)
                            .foregroundColor(Color.getColour(.label_assistive))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? Color.getColour(.fill_alternative) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: emptyConfig.iconName)
                .font(.system(size: 28))
                .foregroundColor(Color.getColour(.label_assistive))
            Text(emptyConfig.title)
                .font(.subheadline)
                .foregroundColor(Color.getColour(.label_neutral))
            Text(emptyConfig.subtitle)
                .font(.caption)
                .foregroundColor(Color.getColour(.label_assistive))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}
