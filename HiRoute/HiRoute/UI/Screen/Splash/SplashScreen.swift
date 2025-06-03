//
//  SplashScreen.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct SplashScreen: View {
    var body: some View {
        VStack {
            Text("HiRoute")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Splash Screen")
                .font(.title2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue.opacity(0.1))
        .navigationTitle("Splash")
    }
}
