//
//  LineLoginButton.swift
//  HiRoute
//
//  Created by Jupond on 2/12/26.
//
import SwiftUI
import LineSDK

struct LineLoginButton: View {

    @EnvironmentObject private var naviVM: NavigationVM
    @EnvironmentObject private var userVM: UserVM

    var body: some View {
        Button(action: {
            lineSignIn()
        }) {
            Image("logo_line")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .padding(4)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func lineSignIn() {
        let viewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.rootViewController
        LoginManager.shared.login(permissions: [.openID, .profile], in: viewController) { result in
            switch result {
            case .success(let loginResult):
                guard let idToken = loginResult.accessToken.IDTokenRaw else { return }

                userVM.socialLogin(provider: "line", idToken: idToken) { isNewUser in
                    if isNewUser {
                        naviVM.navigateTo(setDestination: .register)
                    } else {
                        naviVM.navigateTo(setDestination: .main)
                    }
                }
            case .failure(let error):
                print("LineSignIn // Exception : \(error.localizedDescription)")
                userVM.showSnackBarLoginError = true
            }
        }
    }
}

