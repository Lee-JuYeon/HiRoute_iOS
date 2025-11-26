//
//  FeedViewModel.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI
import Combine

class ScheduleViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var schedules: [ScheduleModel] = []
    @Published var selectedSchedule: ScheduleModel?
    @Published var selectedVisitPlace: VisitPlaceModel?
    @Published var selectedPlace: PlaceModel?
    @Published var filteredSchedules: [ScheduleModel] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Extended Features
    @Published var myBookMarkedPlaces: [PlaceModel] = []
    @Published var placeReviews: [ReviewModel] = []
    @Published var myReviews: [ReviewModel] = []
    @Published var isLoadingReviews = false
    @Published var currentUserRating: Int?
    @Published var placeAverageRating: Double = 0.0
    
    // MARK: - Services
    private let placeService = ServiceContainer.shared.placeService
    private let bookMarkService = ServiceContainer.shared.bookMarkService
    private let reviewService = ServiceContainer.shared.reviewService
    private let starService = ServiceContainer.shared.starService
    
    private var cancellables = Set<AnyCancellable>()
    private let currentUserUID = DummyPack.shared.myDataUID
    
    init() {
        setupSearchSubscription()
        loadInitialData()
    }
    
    // MARK: - Computed Properties
    var isSelectedPlaceBookmarked: Bool {
        guard let place = selectedPlace else { return false }
        return place.bookMarks.contains { $0.userUID == currentUserUID }
    }
    
    var selectedPlaceBookmarkCount: Int {
        return selectedPlace?.bookMarks.count ?? 0
    }
    
    var selectedPlaceReviewCount: Int {
        return selectedPlace?.reviews.count ?? 0
    }
    
    // MARK: - Place Service Methods
    func createPlace(_ place: PlaceModel) {
        isLoading = true
        placeService.createPlace(place)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { createdPlace in
                    print("✅ Place created: \(createdPlace.title)")
                }
            )
            .store(in: &cancellables)
    }
    
    func loadPlace(placeUID: String) {
        placeService.readPlace(placeUID: placeUID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] place in
                    self?.selectedPlace = place
                    self?.loadPlaceDetails(place)
                }
            )
            .store(in: &cancellables)
    }
    
    func loadPlaceList(page: Int = 1, itemsPerPage: Int = 20) {
        isLoading = true
        placeService.readPlaceList(page: page, itemsPerPage: itemsPerPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { places in
                    print("📍 Loaded \(places.count) places")
                }
            )
            .store(in: &cancellables)
    }
    
    func updatePlace(_ place: PlaceModel) {
        placeService.updatePlace(place)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] updatedPlace in
                    if self?.selectedPlace?.uid == updatedPlace.uid {
                        self?.selectedPlace = updatedPlace
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func deletePlace(placeUID: String) {
        placeService.deletePlace(placeUID: placeUID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] deletedPlace in
                    print("🗑️ Place deleted: \(deletedPlace.title)")
                    // 로컬에서 해당 Place 제거
                    self?.removeDeletedPlaceFromLocal(deletedPlace: deletedPlace)
                }
            )
            .store(in: &cancellables)
    }
    
    private func removeDeletedPlaceFromLocal(deletedPlace: PlaceModel) {
        // selectedPlace가 삭제된 Place면 clear
        if selectedPlace?.uid == deletedPlace.uid {
            clearPlaceSelection()
        }
        
        // schedules에서 해당 Place를 포함하는 VisitPlace 제거
        for i in schedules.indices {
            schedules[i].visitPlaceList.removeAll { visitPlace in
                visitPlace.placeModel.uid == deletedPlace.uid
            }
        }
        
        // bookmarked places에서도 제거
        myBookMarkedPlaces.removeAll { $0.uid == deletedPlace.uid }
    }
    
    func deletePlaceAndRefreshList(placeUID: String) {
        placeService.deletePlaceAndGetUpdatedList(placeUID: placeUID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] (updatedList, deletedPlace) in
                    print("🗑️ Place deleted: \(deletedPlace.title)")
                    print("📋 Updated list has \(updatedList.count) places")
                    self?.removeDeletedPlaceFromLocal(deletedPlace: deletedPlace)
                }
            )
            .store(in: &cancellables)
    }
 
    func requestPlaceInfoEdit(placeUID: String, reportType: ReportType.RawValue, reason: String) {
        placeService.requestPlaceInfoEdit(placeUID: placeUID, userUID: currentUserUID, reportType: reportType, reason: reason)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { _ in
                    print("📝 Place edit request submitted")
                }
            )
            .store(in: &cancellables)
    }
    
    func searchPlaces(query: String) {
        placeService.searchPlaces(query: query)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { places in
                    print("🔍 Found \(places.count) places for: \(query)")
                }
            )
            .store(in: &cancellables)
    }
    
    func loadPopularPlaces() {
        placeService.getPopularPlaces(limit: 10)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { places in
                    print("🔥 Loaded \(places.count) popular places")
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - BookMark Service Methods
    func toggleBookMark(for place: PlaceModel) {
        bookMarkService.toggleBookMark(placeUID: place.uid, userUID: currentUserUID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] newState in
                    self?.updateLocalBookmarkState(placeUID: place.uid, isBookmarked: newState)
                    self?.refreshMyBookMarkedPlaces()
                }
            )
            .store(in: &cancellables)
    }
    
    func checkBookmarkStatus(placeUID: String) {
        bookMarkService.isPlaceBookMarked(placeUID: placeUID, userUID: currentUserUID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { isBookmarked in
                    print("📌 Bookmark status for \(placeUID): \(isBookmarked)")
                }
            )
            .store(in: &cancellables)
    }
    
    func loadBookmarkCount(placeUID: String) {
        bookMarkService.getPlaceBookMarkCount(placeUID: placeUID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { count in
                    print("📌 Bookmark count for \(placeUID): \(count)")
                }
            )
            .store(in: &cancellables)
    }
    
    func loadMyBookMarkedPlaces(page: Int = 1, itemsPerPage: Int = 50) {
        bookMarkService.getUserBookMarkPlaces(userUID: currentUserUID, page: page, itemsPerPage: itemsPerPage)
            .receive(on: DispatchQueue.main)
            .assign(to: \.myBookMarkedPlaces, on: self)
            .store(in: &cancellables)
    }
    
    func clearBookmarkCache() {
        bookMarkService.clearBookmarkCache()
    }
    
    // MARK: - Review Service Methods
    func createReview(placeUID: String, reviewText: String, visitDate: Date, images: [ReviewImageModel] = []) {
        let newReview = ReviewModel(
            reviewUID: "",
            reviewText: reviewText,
            userUID: currentUserUID,
            userName: "Current User", // TODO: Get from User Service
            visitDate: visitDate,
            usefulCount: 0,
            images: images,
            usefulList: []
        )
        
        reviewService.createReview(placeUID: placeUID, reviewModel: newReview)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] createdReview in
                    self?.addNewReviewToLocal(createdReview)
                }
            )
            .store(in: &cancellables)
    }
    
    func updateReview(reviewUID: String, reviewText: String, visitDate: Date, images: [ReviewImageModel] = []) {
        let updatedReview = ReviewModel(
            reviewUID: reviewUID,
            reviewText: reviewText,
            userUID: currentUserUID,
            userName: "Current User",
            visitDate: visitDate,
            usefulCount: 0,
            images: images,
            usefulList: []
        )
        
        reviewService.updateReview(reviewUID: reviewUID, reviewModel: updatedReview)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { updatedReview in
                    print("✅ Review updated: \(updatedReview.reviewUID)")
                }
            )
            .store(in: &cancellables)
    }
    
    func deleteReview(reviewUID: String) {
        reviewService.deleteReview(reviewUID: reviewUID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.removeReviewFromLocal(reviewUID: reviewUID)
                }
            )
            .store(in: &cancellables)
    }
    
    func loadPlaceReviews(placeUID: String, page: Int = 1, itemsPerPage: Int = 20) {
        isLoadingReviews = true
        reviewService.readReviewList(placeUID: placeUID, page: page, itemsPerPage: itemsPerPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.isLoadingReviews = false
                },
                receiveValue: { [weak self] reviews in
                    self?.placeReviews = reviews
                }
            )
            .store(in: &cancellables)
    }
    
    func loadMyReviews(page: Int = 1, itemsPerPage: Int = 20) {
        reviewService.readMyReviewList(userUID: currentUserUID, page: page, itemsPerPage: itemsPerPage)
            .receive(on: DispatchQueue.main)
            .assign(to: \.myReviews, on: self)
            .store(in: &cancellables)
    }
    
    func toggleReviewUseful(reviewUID: String) {
        reviewService.toggleReviewUseful(reviewUID: reviewUID, userUID: currentUserUID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] newState in
                    self?.updateLocalReviewUsefulState(reviewUID: reviewUID, isUseful: newState)
                }
            )
            .store(in: &cancellables)
    }
    
    func reportReview(reviewUID: String, reportType: String, reportReason: String) {
        reviewService.reportReview(reviewUID: reviewUID, reporterUID: currentUserUID, reportType: reportType, reportReason: reportReason)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { _ in
                    print("🚨 Review reported: \(reviewUID)")
                }
            )
            .store(in: &cancellables)
    }
    
    func loadReviewsWithSorting(placeUID: String, sortBy: ReviewSortType) {
        reviewService.getReviewsWithSorting(placeUID: placeUID, sortBy: sortBy)
            .receive(on: DispatchQueue.main)
            .assign(to: \.placeReviews, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Star Service Methods
    func ratePlace(placeUID: String, rating: Int) {
        starService.createRate(placeUID: placeUID, userUID: currentUserUID, star: rating)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] star in
                    self?.updateLocalStarRating(placeUID: placeUID, star: star)
                    self?.currentUserRating = rating
                }
            )
            .store(in: &cancellables)
    }
    
    func removeRating(placeUID: String) {
        starService.removeRate(placeUID: placeUID, userUID: currentUserUID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.currentUserRating = nil
                    self?.updateLocalStarRemoval(placeUID: placeUID)
                }
            )
            .store(in: &cancellables)
    }
    
    func loadAverageRating(placeUID: String) {
        starService.readAverageRate(placeUID: placeUID)
            .receive(on: DispatchQueue.main)
            .assign(to: \.placeAverageRating, on: self)
            .store(in: &cancellables)
    }
    
    func loadMyRating(placeUID: String) {
        starService.readMyRateList(placeUID: placeUID, userUID: currentUserUID)
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentUserRating, on: self)
            .store(in: &cancellables)
    }
    
    func loadRatingStatistics(placeUID: String) {
        starService.getRatingStatistics(placeUID: placeUID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { statistics in
                    print("📊 Rating statistics: \(statistics)")
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Selection Management
    func selectSchedule(_ model: ScheduleModel) {
        selectedSchedule = model
        clearVisitPlaceSelection()
        clearPlaceSelection()
    }
    
    func selectVisitPlace(_ visitPlace: VisitPlaceModel) {
        selectedVisitPlace = visitPlace
        selectedPlace = visitPlace.placeModel
        loadPlaceDetails(visitPlace.placeModel)
    }
    
    func selectPlace(_ place: PlaceModel) {
        selectedPlace = place
        loadPlaceDetails(place)
    }
    
    // MARK: - Private Helper Methods
    private func loadPlaceDetails(_ place: PlaceModel) {
        loadPlaceReviews(placeUID: place.uid)
        loadAverageRating(placeUID: place.uid)
        loadMyRating(placeUID: place.uid)
    }
    
    private func updateLocalBookmarkState(placeUID: String, isBookmarked: Bool) {
        updatePlaceInAllLocations(placeUID: placeUID) { place in
            var updatedPlace = place
            if isBookmarked {
                if !updatedPlace.bookMarks.contains(where: { $0.userUID == currentUserUID }) {
                    updatedPlace.bookMarks.append(BookMarkModel(userUID: currentUserUID))
                }
            } else {
                updatedPlace.bookMarks.removeAll { $0.userUID == currentUserUID }
            }
            return updatedPlace
        }
    }
    
    private func updateLocalStarRating(placeUID: String, star: StarModel) {
        updatePlaceInAllLocations(placeUID: placeUID) { place in
            var updatedPlace = place
            updatedPlace.stars.removeAll { $0.userUID == currentUserUID }
            updatedPlace.stars.append(star)
            return updatedPlace
        }
    }
    
    private func updateLocalStarRemoval(placeUID: String) {
        updatePlaceInAllLocations(placeUID: placeUID) { place in
            var updatedPlace = place
            updatedPlace.stars.removeAll { $0.userUID == currentUserUID }
            return updatedPlace
        }
    }
    
    private func updateLocalReviewUsefulState(reviewUID: String, isUseful: Bool) {
        if let index = placeReviews.firstIndex(where: { $0.reviewUID == reviewUID }) {
            var updatedReview = placeReviews[index]
            if isUseful {
                if !updatedReview.usefulList.contains(where: { $0.userUID == currentUserUID }) {
                    updatedReview.usefulList.append(UsefulModel(userUID: currentUserUID))
                }
            } else {
                updatedReview.usefulList.removeAll { $0.userUID == currentUserUID }
            }
            placeReviews[index] = updatedReview
        }
    }
    
    private func addNewReviewToLocal(_ newReview: ReviewModel) {
        placeReviews.insert(newReview, at: 0)
        
        if let placeUID = selectedPlace?.uid {
            updatePlaceInAllLocations(placeUID: placeUID) { place in
                var updatedPlace = place
                updatedPlace.reviews.insert(newReview, at: 0)
                return updatedPlace
            }
        }
    }
    
    private func removeReviewFromLocal(reviewUID: String) {
        placeReviews.removeAll { $0.reviewUID == reviewUID }
        
        if let placeUID = selectedPlace?.uid {
            updatePlaceInAllLocations(placeUID: placeUID) { place in
                var updatedPlace = place
                updatedPlace.reviews.removeAll { $0.reviewUID == reviewUID }
                return updatedPlace
            }
        }
    }
    
    private func updatePlaceInAllLocations(placeUID: String, transform: (PlaceModel) -> PlaceModel) {
        // Update selectedPlace
        if let place = selectedPlace, place.uid == placeUID {
            selectedPlace = transform(place)
        }
        
        // Update selectedVisitPlace.placeModel
        if let visitPlace = selectedVisitPlace, visitPlace.placeModel.uid == placeUID {
            var updatedVisitPlace = visitPlace
            updatedVisitPlace.placeModel = transform(visitPlace.placeModel)
            selectedVisitPlace = updatedVisitPlace
        }
        
        // Update schedules
        for i in schedules.indices {
            for j in schedules[i].visitPlaceList.indices {
                if schedules[i].visitPlaceList[j].placeModel.uid == placeUID {
                    schedules[i].visitPlaceList[j].placeModel = transform(schedules[i].visitPlaceList[j].placeModel)
                }
            }
        }
    }
    
    private func refreshMyBookMarkedPlaces() {
        loadMyBookMarkedPlaces()
    }
    
    private func clearVisitPlaceSelection() {
        selectedVisitPlace = nil
    }
    
    private func clearPlaceSelection() {
        selectedPlace = nil
        placeReviews = []
        currentUserRating = nil
        placeAverageRating = 0.0
    }
    
    private func setupSearchSubscription() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.updateFilteredSchedules()
            }
            .store(in: &cancellables)
    }
    
    private func updateFilteredSchedules() {
        if searchText.isEmpty {
            filteredSchedules = schedules
        } else {
            filteredSchedules = schedules.filter { schedule in
                schedule.title.localizedCaseInsensitiveContains(searchText) ||
                schedule.memo.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func loadInitialData() {
        // 초기 데이터 로딩 로직
        schedules = DummyPack.sampleSchedules
        loadMyBookMarkedPlaces()
        loadMyReviews()
    }
}
