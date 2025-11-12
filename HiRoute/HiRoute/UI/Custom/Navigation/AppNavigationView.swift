//
//  AppNavigationView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

/*
 현재 앱프로우 : Splash -> Auth -> Main
 방식 1) "Group"
  - 필요할 때먄 생성 (Lazy loading)
  - 중첩장지로 각 화면이 독립적인 navigationview를 가질 수 있음
  - 유연성이 높아 Tabview, modal등 다양한 네비게이션 패턴을 조합하기 쉬움
  - 불필요한 네비게이션 스택을 만들지 않아 퍼포먼스가 높음.
 
 방식 2) "NavigationView"
  - 미리 다 만들어놓기 (Eager loading)
  - 화면 내에서 push/pop 네비게이션이 필요한 경우
  - 계층적 데이터를 탐색하는 경우
  - back 버튼이 의미가 있는 경우
 */


struct AppNavigationView: View {
  

    @StateObject private var navigationVM = NavigationVM()
    @StateObject private var planVM = PlanViewModel(
        userUID: DummyPack.shared.myDataUID,
        routeUseCase: RouteUseCase(repository: RouteRepository()),
        planUseCase: PlanUseCase(repository: PlanRepository())
    )
    @StateObject private var searchVM = SearchViewModel()

    var body: some View {
        Group {
            switch navigationVM.destination {
            case .splash:
                SplashScreen()
                    .onAppear {
                        // 2초 후 자동으로 인증 화면으로 이동
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            navigationVM.navigateTo(setDestination: AppDestination.auth)
                        }
                    }
            case .auth:
                AuthNavigationView()
            case .main:
                MainScreen()
                    .environmentObject(planVM)
                    .environmentObject(navigationVM)
                    .environmentObject(searchVM)
            case .search:
                RootSearchView()
                    .environmentObject(planVM)
                    .environmentObject(navigationVM)
            case .planDetail:
                RootDetailView()
                    .environmentObject(planVM)
                    .environmentObject(navigationVM)
            case .planCreate:
                RouteView()
                    .environmentObject(planVM)
                    .environmentObject(navigationVM)
            }
        }
    }
}
