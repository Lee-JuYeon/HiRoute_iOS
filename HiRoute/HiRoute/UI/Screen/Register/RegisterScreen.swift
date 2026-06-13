//
//  RegisterScreen.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

import SwiftUI

struct RegisterScreen: View {

    @EnvironmentObject private var naviVM: NavigationVM
    @EnvironmentObject private var userVM: UserVM
    @State private var showExitSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // 상단바
            HStack {
                ImageButton(imageUrl: "icon_back", imageSize: 30) {
                    showExitSheet = true
                }

                Spacer()

                Text(naviVM.registerTabIndex == 0 ? "약관 동의" : "프로필 등록")
                    .font(.headline)

                Spacer()

                Color.clear
                    .frame(width: 30, height: 30)
            }
            .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))

            RouteTabView(
                tabViewIndex: $naviVM.registerTabIndex,
                totalPage: 2
            ) {
                switch naviVM.registerTabIndex {
                case 0:
                    AgreeView()
                case 1:
                    UserInfoSettingView()
                default:
                    AgreeView()
                }
            }
        }
        .bottomSheet(isOpen: $showExitSheet) {
            VStack(spacing: 16) {
                Text("프로필 설정이 완료되지 않았습니다.\n나가시면 회원가입 역시 취소됩니다.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)

                HStack(spacing: 12) {
                    Button(action: {
                        showExitSheet = false
                    }) {
                        Text("취소")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }

                    Button(action: {
                        showExitSheet = false
                        let deletedAccess = KeychainService.delete(account: "access_token")
                        let deletedRefresh = KeychainService.delete(account: "refresh_token")
                        UserDefaults.standard.removeObject(forKey: "currentUserUID")
                        naviVM.registerTabIndex = 0
                        userVM.pendingAgreements = [:]

                        #if DEBUG
                        let tokenAfter = (try? KeychainService.load(account: "access_token")) != nil
                        let uidAfter = UserDefaults.standard.string(forKey: "currentUserUID")
                        print("🔍 Register 나가기 // deletedAccess: \(deletedAccess), deletedRefresh: \(deletedRefresh)")
                        print("🔍 Register 나가기 // 삭제 후 tokenExists: \(tokenAfter), uidExists: \(uidAfter ?? "nil")")
                        #endif

                        naviVM.navigateTo(setDestination: .onBoarding)
                    }) {
                        Text("나가기")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }
}
