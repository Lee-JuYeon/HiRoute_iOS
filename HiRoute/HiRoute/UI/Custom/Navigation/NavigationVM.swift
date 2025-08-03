//
//  NavigationVM.swift
//  HiRoute
//
//  Created by Jupond on 6/28/25.
//
import SwiftUI

class NavigationVM : ObservableObject {
    @Published var destination : AppDestination = .main
    
    func navigateTo(setDestination : AppDestination){
        destination = setDestination
    }
    
    @Published var isShowFeedDetailView = false
    @Published var isShowFeedCreateView = false
}
