//
//  HorizontalChipView.swift
//  HiRoute
//
//  Created by Jupond on 11/12/25.
//
import SwiftUI

// MARK: - ObservableObject로 UIHostingController 경계를 넘는 상태 공유
// @State는 뷰 로컬 저장소라 UIHostingController 내부 변경이 바깥으로 전파 안 됨.
// ObservableObject는 Combine 기반 참조 타입이므로 동일 인스턴스를 공유하여 전파 가능.
private class ChipSheetState: ObservableObject {
    @Published var activeChipId: String? = nil
}

struct HorizontalChipView: View {
    private let getList: [HorizontalChipModel]
    private let getOnSelectionChanged: ([String: Set<String>]) -> Void
    @State private var selections: [String: Set<String>] = [:]
    @StateObject private var sheetState = ChipSheetState()

    init(
        setList: [HorizontalChipModel],
        setOnSelectionChanged: @escaping ([String: Set<String>]) -> Void
    ) {
        self.getList = setList
        self.getOnSelectionChanged = setOnSelectionChanged
    }

    private var showSheet: Binding<Bool> {
        Binding(
            get: { sheetState.activeChipId != nil },
            set: { if !$0 { sheetState.activeChipId = nil } }
        )
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(getList) { chip in
                    HorizontalChipCell(
                        item: chip,
                        selectedSubtypes: selections[chip.id] ?? [],
                        onTap: { typeId in
                            sheetState.activeChipId = typeId
                        }
                    )
                }
            }
            .padding(.horizontal, 10)
        }
        .frame(height: 44)
        .padding(.top, 8)
        .topSheet(isOpen: showSheet) {
            if let chipId = sheetState.activeChipId,
               let chip = getList.first(where: { $0.id == chipId }) {
                subtypeSheetContent(chip: chip)
            }
        }
    }

    // MARK: - 탑시트 내용

    @ViewBuilder
    private func subtypeSheetContent(chip: HorizontalChipModel) -> some View {
        let currentSubs = selections[chip.id] ?? []
        let allSelected = currentSubs.count == chip.subtypes.count

        VStack(spacing: 0) {
            Text(chip.text)
                .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
                .font(.system(size: 18, weight: .bold))
                .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))


            Button(action: { toggleAll(typeId: chip.id) }) {
                HStack {
                    Text("전체")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    Spacer()
                    if allSelected {
                        Image(systemName: "checkmark")
                            .foregroundColor(.black)
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
            }
            .buttonStyle(PlainButtonStyle())

            Divider()
                .padding(.horizontal, 16)

            ForEach(chip.subtypes) { sub in
                Button(action: { toggleSubtype(typeId: chip.id, subtypeId: sub.id) }) {
                    HStack {
                        Text(sub.text)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        Spacer()
                        if currentSubs.contains(sub.id) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.black)
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.bottom, 24)
    }

    // MARK: - 토글 로직

    private func toggleAll(typeId: String) {
        guard let chip = getList.first(where: { $0.id == typeId }) else { return }
        let allIds = Set(chip.subtypes.map { $0.id })
        if selections[typeId] == allIds {
            selections.removeValue(forKey: typeId)
        } else {
            selections[typeId] = allIds
        }
        getOnSelectionChanged(selections)
    }

    private func toggleSubtype(typeId: String, subtypeId: String) {
        var subs = selections[typeId] ?? []
        if subs.contains(subtypeId) {
            subs.remove(subtypeId)
        } else {
            subs.insert(subtypeId)
        }

        if subs.isEmpty {
            selections.removeValue(forKey: typeId)
        } else {
            selections[typeId] = subs
        }
        getOnSelectionChanged(selections)
    }
}
