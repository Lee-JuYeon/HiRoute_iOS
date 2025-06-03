//
//  LoginScreen.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct LoginScreen: View {
    @State private var email = ""
    @State private var password = ""
    let onNavigateToRegister: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("로그인")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                TextField("이메일", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("비밀번호", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("로그인") {
                    // Login logic
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("회원가입") {
                    onNavigateToRegister()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("로그인")
    }
}
