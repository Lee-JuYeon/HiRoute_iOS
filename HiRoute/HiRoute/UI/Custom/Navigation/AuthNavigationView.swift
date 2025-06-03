//
//  AuthNavigationView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct AuthNavigationView: View {
    @State private var currentAuthDestination: AuthDestination = .login
    @State private var showingRegister = false
    
    var body: some View {
        NavigationView {
            Group {
                switch currentAuthDestination {
                case .login:
                    LoginScreen(onNavigateToRegister: { showingRegister = true })
                case .register:
                    RegisterScreen()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingRegister) {
            RegisterScreen()
        }
    }
}
