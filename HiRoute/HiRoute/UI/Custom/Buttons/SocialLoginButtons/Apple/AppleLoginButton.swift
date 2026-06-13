//
//  AppleLoginButton.swift
//  HiRoute
//
//  Created by Jupond on 2/12/26.
//

import SwiftUI
import AuthenticationServices

struct AppleLoginButton: View {
    
    @EnvironmentObject private var naviVM : NavigationVM
    @EnvironmentObject private var userVM : UserVM
    
    var body: some View {
        Button(action: {
            // 로그인 메소드 구현
            appleSignIn()
        }) {
            Image("logo_apple")
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
    
    private func appleSignIn(){
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        // [SEC] replay 방어 nonce. request.nonce 에는 sha256(rawNonce), 서버에는 rawNonce 전송.
        let rawNonce = AppleNonceGenerator.randomNonceString()
        request.nonce = AppleNonceGenerator.sha256(rawNonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        let coordinator = AppleSignInCoordinator(
            onComplete: { idToken, fullName in
                userVM.socialLogin(provider: "apple", idToken: idToken, name: fullName, rawNonce: rawNonce) { isNewUser in
                    if isNewUser {
                        naviVM.registerTabIndex = 0
                        naviVM.navigateTo(setDestination: .register)
                    } else {
                        naviVM.navigateTo(setDestination: .main)
                    }
                }
            },
            onError: {
                userVM.showSnackBarLoginError = true
            }
        )
        controller.delegate = coordinator
        
        // coordinator가 해제되지 않도록 retain
        AppleSignInCoordinator.current = coordinator

        if let window = UIApplication.shared.windows.first,
           let presentationProvider = window.rootViewController as? ASAuthorizationControllerPresentationContextProviding {
                     controller.presentationContextProvider = presentationProvider
        }

        controller.performRequests()
    }
}
