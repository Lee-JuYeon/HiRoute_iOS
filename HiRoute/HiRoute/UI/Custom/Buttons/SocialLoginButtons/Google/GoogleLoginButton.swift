//
//  GoogleLoginButton.swift
//  HiRoute
//
//  Created by Jupond on 2/12/26.
//
import SwiftUI
import GoogleSignIn

struct GoogleLoginButton: View {
    
    @EnvironmentObject private var naviVM : NavigationVM
    @EnvironmentObject private var userVM : UserVM
    
    var body: some View {
        Button(action: {
            googleSignin()
        }) {
            Image("logo_google")
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
    
    private func googleSignin(){
        guard let rootVC = UIApplication.shared.windows.first?.rootViewController else { return }
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result,error in
            guard error == nil,
            let idToken = result?.user.idToken?.tokenString else {
                if let error = error {
                    print("GoogleSignIn // Exception : \(error.localizedDescription)")
                }
                userVM.showSnackBarLoginError = true
                return
            }

            userVM.socialLogin(provider: "google", idToken: idToken) { isNewUser in
                if isNewUser {
                    naviVM.registerTabIndex = 0
                    naviVM.navigateTo(setDestination: .register)
                } else {
                    naviVM.navigateTo(setDestination: .main)
                }
            }
        }
    }
}
