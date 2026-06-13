//
//  MyPageView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI
import Combine

struct MyPageView: View {

    @EnvironmentObject private var navigationVM: NavigationVM
    @EnvironmentObject private var userVM: UserVM
    @State private var showLogoutSheet: Bool = false
    @State private var selectedPolicyItem: LegalPolicyItem?
    @State private var policyTermsByType: [String: TermActiveItem] = [:]
    @State private var isLoadingPolicyTerms: Bool = false
    @State private var policyTermsCancellable: AnyCancellable?
    @State private var showRecovery: Bool = false
    @State private var showDeleteAccountSheet: Bool = false
    @State private var deleteAccountInProgress: Bool = false
    @State private var deleteAccountMessage: String? = nil

    private struct LegalPolicyItem: Identifiable {
        let id: String
        let title: String
        let serverId: Int
    }

    private func loadPolicyTerms() {
        guard !isLoadingPolicyTerms else { return }
        isLoadingPolicyTerms = true

        let publisher: AnyPublisher<APIResponse<[TermActiveItem]>, Error> =
            APIClient.shared.get(path: "/api/terms/active")

        policyTermsCancellable = publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                isLoadingPolicyTerms = false
                if case .failure(let error) = completion {
                    print("MyPageView // loadPolicyTerms failed: \(error.localizedDescription)")
                }
            }, receiveValue: { response in
                var next: [String: TermActiveItem] = [:]
                for term in response.data {
                    next[term.type] = term
                }
                policyTermsByType = next
                print("MyPageView // loadPolicyTerms success: \(next.keys.sorted())")
            })
    }

    private func openPolicy(type: String, fallbackTitle: String) {
        guard let term = policyTermsByType[type] else {
            print("MyPageView // policy term missing: \(type)")
            return
        }
        selectedPolicyItem = LegalPolicyItem(id: type, title: term.title.isEmpty ? fallbackTitle : term.title, serverId: term.id)
    }

    // MARK: - Auth Section

    @ViewBuilder
    private func notLoggedInSection() -> some View {
        VStack(spacing: 16) {
            Text("로그인하고 더 많은 기능을 사용해보세요")
                .font(.system(size: 16))
                .foregroundColor(Color.getColour(.label_normal))
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                GoogleLoginButton()
                AppleLoginButton()
                // LineLoginButton() // 임시 비활성화
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Color.getColour(.background_white))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func loggedInSection(_ user: UserModel) -> some View {
        VStack(spacing: 12) {
            // 아바타 (이름 이니셜 원형 배지)
            let initial = String(user.name.prefix(1)).uppercased()
            Text(initial)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color.getColour(.background_white))
                .frame(width: 56, height: 56)
                .background(Color.getColour(.label_strong))
                .clipShape(Circle())

            // 이름
            Text(user.name)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.getColour(.label_strong))

            // 국적, 성별
            HStack(spacing: 8) {
                Text(user.nationality)
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_alternative))
                Text("·")
                    .foregroundColor(Color.getColour(.label_alternative))
                Text(user.gender == .male ? "남성" : "여성")
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_alternative))
            }

            // 프로필 편집 (향후 구현)
            Text("프로필 편집")
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_alternative))
                .padding(.top, 4)

            // 로그아웃 버튼
            StrokeTextButton(text: "로그아웃") {
                showLogoutSheet = true
            }
            .padding(.horizontal, 48)
            .padding(.top, 8)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Color.getColour(.background_white))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    // MARK: - Menu Section

    @ViewBuilder
    private func menuSection() -> some View {
        VStack(spacing: 0) {
            menuRow(title: "내가 작성한 리뷰", icon: "pencil.circle") {
                navigationVM.navigateTo(setDestination: .myReviews)
            }

            Divider().padding(.leading, 16)

            menuRow(title: "내가 북마크한 곳", icon: "bookmark.circle") {
                navigationVM.navigateTo(setDestination: .myBookmarks)
            }

            Divider().padding(.leading, 16)

            menuRow(title: "도움돼요 누른 리뷰", icon: "hand.thumbsup.circle") {
                navigationVM.navigateTo(setDestination: .myUsefuls)
            }

            Divider().padding(.leading, 16)

            // [2026-05-26 Phase 3] 최근 7일 내 삭제된 데이터 복구.
            menuRow(title: "최근 삭제 데이터", icon: "trash.circle") {
                showRecovery = true
            }

            Divider().padding(.leading, 16)

            // [2026-05-27 Phase A.6] Apple App Store §3.1.5(a) — 앱 내 계정 삭제 필수.
            // 로그인 상태일 때만 노출.
            if userVM.currentUser != nil {
                menuRow(title: "회원 탈퇴", icon: "person.crop.circle.badge.minus") {
                    showDeleteAccountSheet = true
                }
            }
        }
        .background(Color.getColour(.background_white))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func menuRow(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color.getColour(.label_normal))
                    .frame(width: 28)

                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(Color.getColour(.label_strong))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_alternative))
            }
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Legal Section

    @ViewBuilder
    private func legalSection() -> some View {
        VStack(spacing: 0) {
            menuRow(title: "개인정보처리방침", icon: "doc.text") {
                print("MyPageView // open policy: privacy")
                guard !isLoadingPolicyTerms else {
                    print("MyPageView // policy terms still loading: privacy")
                    return
                }
                openPolicy(type: "privacy", fallbackTitle: "개인정보 수집 및 이용 동의")
            }

            Divider().padding(.leading, 16)

            menuRow(title: "서비스이용약관", icon: "doc.plaintext") {
                print("MyPageView // open policy: service")
                guard !isLoadingPolicyTerms else {
                    print("MyPageView // policy terms still loading: service")
                    return
                }
                openPolicy(type: "service", fallbackTitle: "서비스 이용약관")
            }

            Divider().padding(.leading, 16)

            menuRow(title: "위치정보이용약관", icon: "location.circle") {
                print("MyPageView // open policy: location")
                guard !isLoadingPolicyTerms else {
                    print("MyPageView // policy terms still loading: location")
                    return
                }
                openPolicy(type: "location", fallbackTitle: "위치기반 서비스 이용약관")
            }

            Divider().padding(.leading, 16)

            menuRow(title: "오픈소스 라이선스", icon: "text.book.closed") {
                // 향후 리스트뷰 연결
            }
        }
        .background(Color.getColour(.background_white))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func appVersionSection() -> some View {
        HStack {
            Text("앱 버전")
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_alternative))
            Spacer()
            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_alternative))
        }
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
    }

    // MARK: - Body

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                Spacer(minLength: 8)

                // 상단: Auth 섹션
                if let user = userVM.currentUser {
                    loggedInSection(user)
                } else {
                    notLoggedInSection()
                }

                // 중간: 메뉴 섹션
                menuSection()

                // 하단: 법적/설정 섹션
                legalSection()

                // 앱 버전
                appVersionSection()

                Spacer(minLength: 16)
            }
        }
        .onAppear {
            if policyTermsByType.isEmpty {
                loadPolicyTerms()
            }
        }
        .background(Color.getColour(.background_yellow_white))
        .bottomSheet(isOpen: $showLogoutSheet) {
            VStack(spacing: 16) {
                Text("로그아웃 하시겠습니까?")
                    .font(.system(size: 16))
                    .foregroundColor(Color.getColour(.label_strong))
                    .padding(.top, 20)

                HStack(spacing: 12) {
                    FillTextButton(text: "취소") {
                        showLogoutSheet = false
                    }
                    .frame(maxWidth: .infinity)

                    StrokeTextButton(text: "로그아웃") {
                        showLogoutSheet = false
                        userVM.logout()
                        navigationVM.registerTabIndex = 0
                        navigationVM.navigateTo(setDestination: .onBoarding)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
        .fullScreenCover(isPresented: $showRecovery) {
            RecoveryView()
        }
        .bottomSheet(isOpen: $showDeleteAccountSheet) {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.orange)
                    .padding(.top, 24)

                Text("정말로 탈퇴하시겠습니까?")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color.getColour(.label_strong))

                VStack(alignment: .leading, spacing: 6) {
                    Text("• 모든 일정/채팅/메모/리뷰가 삭제됩니다")
                    Text("• 30일 동안은 동일 계정으로 재로그인 시 복구 가능")
                    Text("• 30일 후 영구 삭제됩니다 (복구 불가)")
                }
                .font(.system(size: 13))
                .foregroundColor(Color.getColour(.label_alternative))
                .padding(.horizontal, 16)

                if let msg = deleteAccountMessage {
                    Text(msg)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                }

                HStack(spacing: 12) {
                    FillTextButton(text: "취소") {
                        showDeleteAccountSheet = false
                        deleteAccountMessage = nil
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(deleteAccountInProgress)

                    StrokeTextButton(text: deleteAccountInProgress ? "처리 중…" : "탈퇴") {
                        deleteAccountInProgress = true
                        deleteAccountMessage = nil
                        userVM.deleteAccount { success, message in
                            deleteAccountInProgress = false
                            if success {
                                showDeleteAccountSheet = false
                                navigationVM.registerTabIndex = 0
                                navigationVM.navigateTo(setDestination: .onBoarding)
                            } else {
                                deleteAccountMessage = message ?? "오류가 발생했습니다. 잠시 후 다시 시도해주세요."
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(deleteAccountInProgress)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
        .fullScreenCover(item: $selectedPolicyItem) { item in
            switch item.id {
            case "service":
                // 서비스 이용약관
                TermsOfUseView(
                    termTitle: item.title,
                    termId: item.serverId,
                    onDismiss: { selectedPolicyItem = nil }
                )
            case "privacy":
                // 개인정보 수집 이용 및 이용 동의
                PrivacyPolicyView(
                    termTitle: item.title,
                    termId: item.serverId,
                    onDismiss: { selectedPolicyItem = nil }
                )
            case "location":
                // 위치기반 서비스 이용약관
                TermsOfService(
                    termTitle: item.title,
                    termId: item.serverId,
                    onDismiss: { selectedPolicyItem = nil }
                )
            default:
                PrivacyPolicyView(
                    termTitle: item.title,
                    termId: item.serverId,
                    onDismiss: { selectedPolicyItem = nil }
                )
            }
        }
    }
}
