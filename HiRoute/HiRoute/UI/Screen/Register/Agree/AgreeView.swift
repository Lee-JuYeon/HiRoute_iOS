//
//  AgreeView.swift
//  HiRoute
//
//  Created by Jupond on 2/12/26.
//

import SwiftUI
import Combine


struct AgreeView: View {

    @State private var isAllAgreed = false
    @State private var agreementStates: [String: Bool] = [:]
    @State private var selectedTermItem: AgreeModel?
    @State private var termsItems: [AgreeModel] = []
    @State private var isLoadingTerms = true
    @State private var termsCancellable: AnyCancellable?
    @EnvironmentObject private var naviVM : NavigationVM
    @EnvironmentObject private var userVM : UserVM

    // [2026-05-27 Phase A.10] PIPA 28조의8 — 국외 이전 동의 필수 추가.
    // 서버의 /api/terms/active에 "overseas_transfer" 타입 term 등록 필요.
    // 미등록 시 fallback에서 사용.
    private static let requiredTypes: Set<String> = ["service", "privacy", "location", "overseas_transfer"]

    private var requiredItems: [AgreeModel] {
        termsItems.filter { $0.isRequired }
    }

    private var allRequiredItemsAgreed: Bool {
        requiredItems.allSatisfy { agreementStates[$0.id] == true }
    }

    // 전체 동의 토글 (필수항목만)
    private func toggleAllAgreement() {
        let newState = !isAllAgreed
        isAllAgreed = newState

        for item in requiredItems {
            agreementStates[item.id] = newState
        }
    }

    // 개별 항목 토글
    private func toggleIndividualAgreement(_ itemId: String) {
        agreementStates[itemId]?.toggle()
        updateAllAgreementState()
    }

    // 전체 동의 상태 업데이트
    private func updateAllAgreementState() {
        isAllAgreed = allRequiredItemsAgreed
    }

    // MARK: - 서버에서 약관 목록 로드

    private func loadTerms() {
        let publisher: AnyPublisher<APIResponse<[TermActiveItem]>, Error> =
            APIClient.shared.get(path: "/api/terms/active")

        termsCancellable = publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                isLoadingTerms = false
                if case .failure = completion {
                    setFallbackTerms()
                }
            }, receiveValue: { response in
                let items = response.data.map { term in
                    AgreeModel(
                        id: term.type,
                        serverId: term.id,
                        title: term.title,
                        isRequired: AgreeView.requiredTypes.contains(term.type)
                    )
                }
                termsItems = items
                var states: [String: Bool] = [:]
                for item in items {
                    states[item.id] = false
                }
                agreementStates = states
            })
    }

    private func setFallbackTerms() {
        termsItems = [
            AgreeModel(id: "service", serverId: 1, title: "서비스 이용약관", isRequired: true),
            AgreeModel(id: "privacy", serverId: 2, title: "개인정보 수집 및 이용 동의", isRequired: true),
            AgreeModel(id: "location", serverId: 3, title: "위치기반 서비스 이용약관", isRequired: true),
            // [2026-05-27 Phase A.10] PIPA 28조의8 — 국외 이전 동의 의무.
            AgreeModel(id: "overseas_transfer", serverId: 6, title: "개인정보 국외 이전 동의 (Cloudflare, 미국)", isRequired: true),
            AgreeModel(id: "marketing", serverId: 4, title: "마케팅 정보 수신 동의", isRequired: false),
            AgreeModel(id: "push", serverId: 5, title: "푸시 알림 수신 동의", isRequired: false)
        ]
        var states: [String: Bool] = [:]
        for item in termsItems {
            states[item.id] = false
        }
        agreementStates = states
    }

    @ViewBuilder
    private func termsItemRow(_ item: AgreeModel) -> some View {
        HStack(spacing: 12) {
            CheckBox(
                isChecked: .constant(agreementStates[item.id] ?? false),
                onToggle: {
                    toggleIndividualAgreement(item.id)
                }
            )

            HStack(spacing: 4) {
                if item.isRequired {
                    Text("(필수)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                }

                Text(item.title)
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_strong))
            }

            Spacer()

            // 상세보기 버튼 (서버에 약관이 있는 경우만)
            if item.serverId > 0 {
                Button("보기") {
                    selectedTermItem = item
                }
                .font(.system(size: 12))
                .foregroundColor(Color.getColour(.label_alternative))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.getColour(.label_alternative), lineWidth: 1)
                )
            }
        }
        .padding(.vertical, 8)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // 헤더
            VStack(alignment: .leading, spacing: 8) {
                Text("서비스 이용을 위해")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.getColour(.label_strong))

                Text("약관에 동의해주세요")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.getColour(.label_strong))

                Text("필수 약관에 모두 동의하셔야 서비스를 이용할 수 있습니다.")
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_alternative))
                    .padding(.top, 4)
            }

            if isLoadingTerms {
                Spacer()
                HStack { Spacer(); ProgressView(); Spacer() }
                Spacer()
            } else {
                // 전체 동의
                VStack(spacing: 16) {
                    Button(action: {
                        toggleAllAgreement()
                    }) {
                        HStack(spacing: 12) {
                            CheckBox(
                                isChecked: .constant(isAllAgreed)
                            )
                            .allowsHitTesting(false)

                            Text("필수 약관에 모두 동의")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.getColour(.label_strong))

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.getColour(.label_alternative))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // 개별 약관 항목들
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(termsItems, id: \.id) { item in
                        termsItemRow(item)

                        if item.id != termsItems.last?.id {
                            Divider()
                                .padding(.leading, 44)
                        }
                    }
                }

                Spacer()

                // 동의 완료 버튼
                Button("동의하고 계속하기") {
                    userVM.setAgreements(agreementStates)
                    // 동의한 약관 서버 전송
                    let agreedTermIds = termsItems
                        .filter { agreementStates[$0.id] == true }
                        .map { $0.serverId }
                    userVM.submitTermConsents(agreedTermIds)
                    naviVM.registerTabIndex = 1
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(
                    allRequiredItemsAgreed ?
                    Color.getColour(.label_strong) : Color.gray
                )
                .cornerRadius(8)
                .disabled(!allRequiredItemsAgreed)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.getColour(.background_yellow_white))
        .onAppear {
            loadTerms()
        }
        .fullScreenCover(item: $selectedTermItem) { item in
            switch item.id {
            case "service":
                TermsOfUseView(
                    termTitle: item.title,
                    termId: item.serverId,
                    onDismiss: { selectedTermItem = nil }
                )
            case "privacy":
                PrivacyPolicyView(
                    termTitle: item.title,
                    termId: item.serverId,
                    onDismiss: { selectedTermItem = nil }
                )
            case "location":
                TermsOfService(
                    termTitle: item.title,
                    termId: item.serverId,
                    onDismiss: { selectedTermItem = nil }
                )
            default:
                TermDetailView(
                    termTitle: item.title,
                    termId: item.serverId,
                    onDismiss: { selectedTermItem = nil }
                )
            }
        }
    }
}
