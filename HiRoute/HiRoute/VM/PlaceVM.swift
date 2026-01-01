//
//  PlaceVM.swift
//  HiRoute
//
//  Created by Jupond on 12/3/25.
//
import Combine
import SwiftUI

class PlaceVM: ObservableObject {
    
    // MARK: - Published Properties (UI 상태)
    @Published var places: [PlaceModel] = []
    @Published var filteredPlaces : [PlaceModel] = []
    @Published var selectedPlace: PlaceModel?
    @Published var myBookmarkedPlaces: [PlaceModel] = []
    @Published var placeReviews: [ReviewModel] = []
    @Published var myReviews: [ReviewModel] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var isLoadingReviews = false
    @Published var errorMessage: String?
    @Published var currentUserRating: Int?
    @Published var placeAverageRating: Double = 0.0
    
    // MARK: - Services
    private let placeService: PlaceService
    private let bookmarkService: BookMarkService
    private let reviewService: ReviewService
    private let starService: StarService
    private var cancellables = Set<AnyCancellable>()
    
    private let currentUserUID = "user_uid_1"
    
    init(placeService: PlaceService, bookmarkService: BookMarkService,
         reviewService: ReviewService, starService: StarService) {
        self.placeService = placeService
        self.bookmarkService = bookmarkService
        self.reviewService = reviewService
        self.starService = starService
        
        setupBindings()
        loadInitialData()
    }
    
    func searchPlaces(text : String) -> [PlaceModel]{
        let searchText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        filteredPlaces = DummyPack.samplePlaces.filter { place in
            // 제목에서 검색
            let titleMatch = place.title.lowercased().contains(searchText)
            
            // 부제목에서 검색 (옵셔널 처리)
            let subtitleMatch = place.subtitle?.lowercased().contains(searchText) ?? false
            
            // 장소 타입에서 검색
            let typeMatch = place.type.displayText.lowercased().contains(searchText)
            
            // 주소에서 검색 (전체 주소, 시도, 구군, 동)
            let fullAddressMatch = place.address.fullAddress.lowercased().contains(searchText)
            let sidoMatch = place.address.sido.lowercased().contains(searchText)
            let gunguMatch = place.address.gungu.lowercased().contains(searchText)
            let dongMatch = place.address.dong.lowercased().contains(searchText)
            let addressTitleMatch = place.address.addressTitle.lowercased().contains(searchText)
            
            // 하나라도 일치하면 포함
            return titleMatch || subtitleMatch || typeMatch ||
                   fullAddressMatch || sidoMatch || gunguMatch ||
                   dongMatch || addressTitleMatch
        }
        return filteredPlaces
    }
    
    func recommendPlaces() -> [PlaceModel]{
        return DummyPack.samplePlaces
    }
    
    // MARK: - Service Bindings (안전한 패턴)
    
    private func setupBindings() {
        // Service Publisher들 구독 (weak self로 순환참조 방지)
        // 필요시 Service에서 Publisher 제공받아 바인딩
    }
    
    // MARK: - Place CRUD
    
    /// 장소 생성
    func createPlace(_ place: PlaceModel) {
        isLoading = true
        
        placeService.createPlace(place)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] createdPlace in
                    self?.places.append(createdPlace)
                    print("✅ Place created: \(createdPlace.title)")
                }
            )
            .store(in: &cancellables)
    }
    
    /// 장소 로드
    func loadPlace(uid: String) {
        placeService.readPlace(placeUID: uid)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] place in
                    self?.selectedPlace = place
                    self?.loadPlaceDetails(place)
                }
            )
            .store(in: &cancellables)
    }
    
    /// 장소 리스트 로드
    func loadPlaces(page: Int = 0, itemsPerPage: Int = 20) {
        isLoading = true
        
        placeService.readPlaceList(page: page, itemsPerPage: itemsPerPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] places in
                    if page == 0 {
                        self?.places = places
                    } else {
                        self?.places.append(contentsOf: places)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    /// 장소 업데이트
    func updatePlace(_ place: PlaceModel) {
        placeService.updatePlace(place)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] updatedPlace in
                    self?.updateLocalPlace(updatedPlace)
                }
            )
            .store(in: &cancellables)
    }
    
    /// 장소 삭제
    func deletePlace(uid: String) {
        placeService.deletePlace(placeUID: uid)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.removeLocalPlace(uid: uid)
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Bookmark Methods
    
    /// 북마크 토글
    func toggleBookmark(for place: PlaceModel) {
        bookmarkService.toggleBookMark(placeUID: place.uid, userUID: currentUserUID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] isBookmarked in
                    self?.updateLocalBookmarkState(placeUID: place.uid, isBookmarked: isBookmarked)
                    self?.loadMyBookmarkedPlaces()
                }
            )
            .store(in: &cancellables)
    }
    
    /// 내 북마크 장소들 로드
    func loadMyBookmarkedPlaces() {
        bookmarkService.getUserBookMarkPlaces(userUID: currentUserUID, page: 1, itemsPerPage: 50)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] places in
                    self?.myBookmarkedPlaces = places
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Review Methods
    
    /// 리뷰 작성
    func createReview(placeUID: String, reviewModel: ReviewModel) {
        let newReview = ReviewModel(
            reviewUID: UUID().uuidString,
            reviewText: reviewModel.reviewText,
            userUID: currentUserUID,
            userName: reviewModel.userName,
            visitDate: reviewModel.visitDate,
            usefulCount: 0,
            images: reviewModel.images,
            usefulList: []
        )
        
        reviewService.createReview(placeUID: placeUID, reviewModel: newReview)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] createdReview in
                    self?.placeReviews.insert(createdReview, at: 0)
                }
            )
            .store(in: &cancellables)
    }
    
    /// 리뷰 로드
    func loadReviews(placeUID: String, page: Int = 0) {
        isLoadingReviews = true
        
        reviewService.readReviewList(placeUID: placeUID, page: page, itemsPerPage: 20)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingReviews = false
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] reviews in
                    self?.placeReviews = reviews
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Rating Methods
    
    /// 별점 평가
    func ratePlace(placeUID: String, rating: Int) {
        starService.createRate(placeUID: placeUID, userUID: currentUserUID, star: rating)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.currentUserRating = rating
                    self?.loadAverageRating(placeUID: placeUID)
                }
            )
            .store(in: &cancellables)
    }
    
    /// 평균 별점 로드
    func loadAverageRating(placeUID: String) {
        starService.readAverageRate(placeUID: placeUID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] rating in
                    self?.placeAverageRating = rating
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Selection Management
    
    func selectPlace(_ place: PlaceModel) {
        selectedPlace = place
        loadPlaceDetails(place)
    }
    
    func clearSelection() {
        selectedPlace = nil
        placeReviews = []
        currentUserRating = nil
        placeAverageRating = 0.0
    }
    
    // MARK: - Private Helpers
    
    private func loadPlaceDetails(_ place: PlaceModel) {
        loadReviews(placeUID: place.uid)
        loadAverageRating(placeUID: place.uid)
    }
    
    private func updateLocalPlace(_ place: PlaceModel) {
        if let index = places.firstIndex(where: { $0.uid == place.uid }) {
            places[index] = place
        }
        
        if selectedPlace?.uid == place.uid {
            selectedPlace = place
        }
    }
    
    private func removeLocalPlace(uid: String) {
        places.removeAll { $0.uid == uid }
        
        if selectedPlace?.uid == uid {
            clearSelection()
        }
    }
    
    private func updateLocalBookmarkState(placeUID: String, isBookmarked: Bool) {
        // 로컬 상태 업데이트 로직
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
    }
    
    private func loadInitialData() {
        loadPlaces()
        loadMyBookmarkedPlaces()
        
        places = DummyPack.samplePlaces
        filteredPlaces = places
    }
    
    deinit {
        print("✅ PlaceViewModel deinit")
    }
}
