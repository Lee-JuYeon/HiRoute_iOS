//
//  LoginScreen.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct OnBoardingScreen: View {

    @EnvironmentObject private var userVM: UserVM

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Social Media로 간편하게 로그인해보세요")
                .font(.largeTitle)
                .fontWeight(.bold)

            HStack(){
                // google login
                GoogleLoginButton()

                // apple login
                AppleLoginButton()

                // line login (임시 비활성화 - SDK 호환성 이슈)
                // LineLoginButton()
            }
        }
        .snackbar($userVM.showSnackBarLoginError, message: "로그인에 실패했습니다. 다시 시도해주세요.")
    }
}
