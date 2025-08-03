//
//  FeedViewModel.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

 import SwiftUI
import Combine

class PlanViewModel : ObservableObject {
    @Published var trendRoutes : [RouteModel] = []
    @Published var localisedRoutes : [RouteModel] = []
    @Published var searchRoutes : [RouteModel] = []
    @Published var searchText : String = ""
    @Published var myPlans: [PlanModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPlan : PlanModel?
    
    private let routeUseCase: RouteUseCase
    private let planUseCase: PlanUseCase
    private let userUID: String
    
    private var currentPageRoute: Int = 1
    private var currentPagePlan: Int = 1
    private var cancellables = Set<AnyCancellable>()
    
    // 원본 데이터 (북마크 동기화용)
    private var originalTrendRoutes: [RouteModel] = []
    private var originalLocalisedRoutes: [RouteModel] = []
    private var originalMyPlans: [PlanModel] = []
    
    init(userUID: String, routeUseCase: RouteUseCase, planUseCase: PlanUseCase) {
        self.userUID = userUID
        self.routeUseCase = routeUseCase
        self.planUseCase = planUseCase
        
        setupLifecycleObserver()
        loadInitialData()
    }
    
    // MARK: - 🔄 생명주기 관리
    private func setupLifecycleObserver() {
        NotificationCenter.default
            /*
             willResignActiveNotification : 앱이 비활성화되기 직전에 발생하는 시스템 알림
             1. 홈버튼 누를때
             2. 앱 스위치로 이동시
             3. 전화가 올 대
             4. 알림이 와서 상단을 내릴 때
             5. 화면을 잠글 때
             */
            .publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                // 북마크 업데이트
                
            }
            .store(in: &cancellables)
    }
    
    func loadInitialData() {
        isLoading = true
        
        let trendingPublisher = routeUseCase.getTrendingRoutes()
        let localisedPublisher = routeUseCase.getLocalRoutes()
        let plansPublisher = planUseCase.getAllPlans()
        
        Publishers.CombineLatest3(trendingPublisher, localisedPublisher, plansPublisher)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] trendingRoutes, localisedRoutes, plans in
                    // 원본 저장
                    self?.originalTrendRoutes = trendingRoutes
                    self?.originalLocalisedRoutes = localisedRoutes
                    self?.originalMyPlans = plans
                    
                    // UI용 복사본
                    self?.trendRoutes = trendingRoutes
                    self?.localisedRoutes = localisedRoutes
                    self?.myPlans = plans
                    
                    print("✅ 데이터 로드 완료: 트렌딩 \(trendingRoutes.count)개, 로컬 \(localisedRoutes.count)개, 플랜 \(plans.count)개")
                }
            )
            .store(in: &cancellables)
    }
    
    func fetchTrendRoutes() {
         routeUseCase.getTrendingRoutes(page: currentPageRoute)
             .receive(on: DispatchQueue.main)
             .sink(
                 receiveCompletion: { [weak self] completion in
                     if case .failure(let error) = completion {
                         self?.errorMessage = error.localizedDescription
                     }
                 },
                 receiveValue: { [weak self] routes in
                     if self?.currentPageRoute == 1 {
                         self?.trendRoutes = routes
                         self?.originalTrendRoutes = routes
                     } else {
                         self?.trendRoutes.append(contentsOf: routes)
                     }
                     self?.currentPageRoute += 1
                 }
             )
             .store(in: &cancellables)
     }
    
    func fetchLocalisedRoutes() {
        routeUseCase.getLocalRoutes(page: currentPageRoute)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] routes in
                    if self?.currentPageRoute == 1 {
                        self?.localisedRoutes = routes
                        self?.originalLocalisedRoutes = routes
                    } else {
                        self?.localisedRoutes.append(contentsOf: routes)
                    }
                    self?.currentPageRoute += 1
                }
            )
            .store(in: &cancellables)
    }
    
    func fetchMyPlans() {
        planUseCase.getAllPlans(page: currentPagePlan)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] plans in
                    if self?.currentPagePlan == 1 {
                        self?.myPlans = plans
                        self?.originalMyPlans = plans
                    } else {
                        self?.myPlans.append(contentsOf: plans)
                    }
                    self?.currentPagePlan += 1
                }
            )
            .store(in: &cancellables)
    }
       
    func fetchRouteDetail(routeUID: String) {
        routeUseCase.getRouteDetail(routeUID: routeUID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { route in
                    print("📍 장소 상세 정보: \(route.routeTitle)")
                }
            )
            .store(in: &cancellables)
    }
    
    func updateBookMark(routeUid : String){
        /*
         1. 복사본 plna list 혹은 route list에서 route uid 비교하여 업데이트함.
         2. State 리스트라 Ui렌더링도 동기적으로 바뀔것
         3. planvm 생명주기가 끝나면 복사본 plan list에서 업데이트 된 북마크 모델만 찾아내어 제 3의 업데이트된 리스트를 만들어 서버에 업데이트
         */
        
        
    }
    
    
    
}
