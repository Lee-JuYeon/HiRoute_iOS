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
    @Published var myUsefulReviews: [ReviewModel] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var isLoadingReviews = false
    @Published var errorMessage: String?
    @Published var currentUserRating: Int?
    @Published var placeAverageRating: Double = 0.0
    @Published var chipData: [HorizontalChipModel] = []
    @Published var guides: [GuideItem] = []
    @Published var isLoadingGuides = false

    // MARK: - Pagination State
    private let placePageSize = 50
    private let reviewPageSize = 20
    private let bookmarkPageSize = 30
    private let imagePageSize = 20

    private var placePage = 1
    var placeHasMore = true
    @Published var isLoadingMorePlaces = false
    private var currentFilterType: String?
    private var currentFilterSubtype: String?

    private var reviewPage = 1
    var reviewHasMore = true
    @Published var isLoadingMoreReviews = false

    private var bookmarkPage = 1
    var bookmarkHasMore = true
    @Published var isLoadingMoreBookmarks = false

    private var myReviewPage = 1
    var myReviewHasMore = true
    @Published var isLoadingMoreMyReviews = false

    private var placeImagePage = 1
    var placeImageHasMore = true
    @Published var currentPlaceImages: [ImageModel] = []
    @Published var isLoadingMorePlaceImages = false

    /// FullSizeImageListView에 표시할 이미지 — 네비게이션 직전에 설정
    @Published var fullScreenImages: [ImageModel] = []

    // MARK: - UI Triggers (PlaceView @State에서 VM @Published로 이동)
    @Published var showSnackBarCopyAddress: Bool = false
    @Published var showSnackBarAddBookMark: Bool = false
    @Published var showSnackBarRemoveBookMark: Bool = false
    @Published var showSnackBarReportReview: Bool = false
    @Published var showEditInfoView: Bool = false
    @Published var showAddScheduleView: Bool = false
    @Published var showSnackBarAddPlace: Bool = false
    @Published var showSnackBarNoImage: Bool = false

    // MARK: - Events
    internal lazy var events: PlaceEvent = PlaceEvent(vm: self)

    // MARK: - Services
    private let placeService: PlaceService
    private let bookmarkService: BookMarkService
    private let reviewService: ReviewService
    private let starService: StarService
    private let guideService: GuideService
    private var cancellables = Set<AnyCancellable>()

    private var currentUserUid: String {
        UserDefaults.standard.string(forKey: "currentUserUID") ?? ""
    }

    init(placeService: PlaceService, bookmarkService: BookMarkService,
         reviewService: ReviewService, starService: StarService,
         guideService: GuideService) {
        self.placeService = placeService
        self.bookmarkService = bookmarkService
        self.reviewService = reviewService
        self.starService = starService
        self.guideService = guideService

        setupBindings()
        loadInitialData()
    }

    func searchPlaces(text : String) -> [PlaceModel]{
        let searchText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        filteredPlaces = places.filter { place in
            let titleMatch = place.title.lowercased().contains(searchText)
            let subtitleMatch = place.subtitle?.lowercased().contains(searchText) ?? false
            let typeMatch = place.type.displayText.lowercased().contains(searchText)
            let fullAddressMatch = place.address.fullAddress?.lowercased().contains(searchText) ?? false
            let block1Match = place.address.addressBlock1?.lowercased().contains(searchText) ?? false
            let block2Match = place.address.addressBlock2?.lowercased().contains(searchText) ?? false
            let block3Match = place.address.addressBlock3?.lowercased().contains(searchText) ?? false
            let addressTitleMatch = place.address.addressTitle?.lowercased().contains(searchText) ?? false

            return titleMatch || subtitleMatch || typeMatch ||
                   fullAddressMatch || block1Match || block2Match ||
                   block3Match || addressTitleMatch
        }
        return filteredPlaces
    }

    func recommendPlaces() -> [PlaceModel]{
        return places
    }

    func editInfoRequest(text: String, userUid: String, placeUid: String) {
        placeService.requestPlaceInfoEdit(
            placeUid: placeUid,
            userUid: userUid,
            reportType: "edit_request",
            reason: text
        )
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlaceVM, editInfoRequest // Warning : 현재는 비짓서울 데이터만 사용합니다 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] _ in
                    print("PlaceVM, editInfoRequest // Success : 수정 요청 완료")
                    self?.showEditInfoView = false
                }
            )
            .store(in: &cancellables)
    }

    private func setupBindings() {
    }

    // MARK: - Place CRUD

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

    func loadPlace(uid: String) {
        placeService.readPlace(placeUid: uid)
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

    func loadPlaces(page: Int = 1, append: Bool = false, type: String? = nil, subtype: String? = nil) {
        if !append {
            isLoading = true
            placePage = 1
            placeHasMore = true
            currentFilterType = type
            currentFilterSubtype = subtype
        }

        placeService.readPlaceList(page: page, itemsPerPage: placePageSize, type: currentFilterType, subtype: currentFilterSubtype)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    self?.isLoadingMorePlaces = false
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] newPlaces in
                    guard let self = self else { return }
                    if newPlaces.count < self.placePageSize {
                        self.placeHasMore = false
                    }
                    if append {
                        self.places.append(contentsOf: newPlaces)
                        self.filteredPlaces = self.places
                    } else {
                        self.places = newPlaces
                        self.filteredPlaces = newPlaces
                    }
                    self.buildChipData()
                }
            )
            .store(in: &cancellables)
    }

    func loadMorePlaces() {
        guard placeHasMore, !isLoadingMorePlaces, !isLoading else { return }
        isLoadingMorePlaces = true
        placePage += 1
        loadPlaces(page: placePage, append: true, type: currentFilterType, subtype: currentFilterSubtype)
    }

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

    func deletePlace(uid: String) {
        placeService.deletePlace(placeUid: uid)
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

    func toggleBookmark(for place: PlaceModel) {
        let userUid = currentUserUid
        guard !userUid.isEmpty else {
            print("PlaceVM, toggleBookmark // Warning : 로그인 필요 — currentUserUID UserDefaults가 비어있어서 북마크 토글 불가. place.uid=\(place.uid)")
            return
        }
        print("PlaceVM, toggleBookmark // Info : place.uid=\(place.uid), userUid=\(userUid)")
        bookmarkService.toggleBookMark(placeUid: place.uid, userUid: userUid)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("PlaceVM, toggleBookmark // Exception : \(error.localizedDescription)")
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] isBookmarked in
                    print("PlaceVM, toggleBookmark // Success : isBookmarked=\(isBookmarked)")
                    self?.updateLocalBookmarkState(placeUid: place.uid, isBookmarked: isBookmarked)
                    self?.loadMyBookmarkedPlaces()
                }
            )
            .store(in: &cancellables)
    }

    func loadMyBookmarkedPlaces(page: Int = 1, append: Bool = false) {
        if !append {
            bookmarkPage = 1
            bookmarkHasMore = true
        }

        bookmarkService.getUserBookMarkPlaces(userUid: currentUserUid, page: page, itemsPerPage: bookmarkPageSize)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingMoreBookmarks = false
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] newPlaces in
                    guard let self = self else { return }
                    if newPlaces.count < self.bookmarkPageSize {
                        self.bookmarkHasMore = false
                    }
                    if append {
                        self.myBookmarkedPlaces.append(contentsOf: newPlaces)
                    } else {
                        self.myBookmarkedPlaces = newPlaces
                    }
                }
            )
            .store(in: &cancellables)
    }

    func loadMoreBookmarks() {
        guard bookmarkHasMore, !isLoadingMoreBookmarks else { return }
        isLoadingMoreBookmarks = true
        bookmarkPage += 1
        loadMyBookmarkedPlaces(page: bookmarkPage, append: true)
    }

    // MARK: - Review Methods

    func createReview(placeUid: String, reviewModel: ReviewModel) {
        reviewService.createReview(placeUid: placeUid, reviewModel: reviewModel)
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

    func loadReviews(placeUid: String, page: Int = 1, append: Bool = false) {
        if !append {
            isLoadingReviews = true
            reviewPage = 1
            reviewHasMore = true
        }

        reviewService.readReviewList(placeUid: placeUid, page: page, itemsPerPage: reviewPageSize)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingReviews = false
                    self?.isLoadingMoreReviews = false
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] newReviews in
                    guard let self = self else { return }
                    if newReviews.count < self.reviewPageSize {
                        self.reviewHasMore = false
                    }
                    // [2026-05-27 Phase A.9] 차단된 user 리뷰 제외.
                    let filteredReviews = BlockedUsersService.shared.filterReviews(newReviews)
                    if append {
                        self.placeReviews.append(contentsOf: filteredReviews)
                    } else {
                        self.placeReviews = filteredReviews
                    }
                    self.mergeLocalUsefulState()
                }
            )
            .store(in: &cancellables)
    }

    func loadMoreReviews(placeUid: String) {
        guard reviewHasMore, !isLoadingMoreReviews, !isLoadingReviews else { return }
        isLoadingMoreReviews = true
        reviewPage += 1
        loadReviews(placeUid: placeUid, page: reviewPage, append: true)
    }

    // MARK: - My Review Methods

    func loadMyReviews(page: Int = 1, append: Bool = false) {
        if !append {
            myReviewPage = 1
            myReviewHasMore = true
        }

        reviewService.readMyReviewList(userUid: currentUserUid, page: page, itemsPerPage: reviewPageSize)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingMoreMyReviews = false
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] newReviews in
                    guard let self = self else { return }
                    if newReviews.count < self.reviewPageSize {
                        self.myReviewHasMore = false
                    }
                    if append {
                        self.myReviews.append(contentsOf: newReviews)
                    } else {
                        self.myReviews = newReviews
                    }
                }
            )
            .store(in: &cancellables)
    }

    func loadMoreMyReviews() {
        guard myReviewHasMore, !isLoadingMoreMyReviews else { return }
        isLoadingMoreMyReviews = true
        myReviewPage += 1
        loadMyReviews(page: myReviewPage, append: true)
    }

    func loadMyUsefulReviews() {
        reviewService.readMyUsefulReviews(userUid: currentUserUid, page: 1, itemsPerPage: 100)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.loadMyUsefulReviewsFromLocal()
                    }
                },
                receiveValue: { [weak self] reviews in
                    guard let self = self else { return }
                    if reviews.isEmpty {
                        self.loadMyUsefulReviewsFromLocal()
                    } else {
                        self.myUsefulReviews = reviews.map { review in
                            var r = review
                            r.usefulList = [UsefulModel(userUid: self.currentUserUid)]
                            return r
                        }
                    }
                }
            )
            .store(in: &cancellables)
    }

    private func loadMyUsefulReviewsFromLocal() {
        LocalDB.shared.getUserUsefulReviewUids(userUid: currentUserUid) { [weak self] reviewUids in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let usefulSet = Set(reviewUids)
                let allReviews = self.places.flatMap { $0.reviews ?? [] } + self.placeReviews + self.myReviews
                var seen = Set<String>()
                self.myUsefulReviews = allReviews
                    .filter { usefulSet.contains($0.reviewUid) && seen.insert($0.reviewUid).inserted }
                    .map { review in
                        var r = review
                        r.usefulList = [UsefulModel(userUid: self.currentUserUid)]
                        return r
                    }
            }
        }
    }

    // MARK: - Place Images (GET /api/places/:placeUid/images)

    func loadPlaceImages(placeUid: String, page: Int = 1, append: Bool = false) {
        if !append {
            placeImagePage = 1
            placeImageHasMore = true
        }

        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(imagePageSize)")
        ]

        let publisher: AnyPublisher<APIResponse<[ImageModel]>, Error> =
            APIClient.shared.get(path: "/api/places/\(placeUid)/images", queryItems: queryItems)

        publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingMorePlaceImages = false
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    let newImages = response.data
                    if newImages.count < self.imagePageSize {
                        self.placeImageHasMore = false
                    }
                    if append {
                        self.currentPlaceImages.append(contentsOf: newImages)
                    } else {
                        self.currentPlaceImages = newImages
                    }
                }
            )
            .store(in: &cancellables)
    }

    func loadMorePlaceImages(placeUid: String) {
        guard placeImageHasMore, !isLoadingMorePlaceImages else { return }
        isLoadingMorePlaceImages = true
        placeImagePage += 1
        loadPlaceImages(placeUid: placeUid, page: placeImagePage, append: true)
    }

    // MARK: - Useful Methods

    func toggleUseful(reviewUid: String) {
        LocalDB.shared.toggleUseful(userUid: currentUserUid, reviewUid: reviewUid) { [weak self] isUseful in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.updateUsefulListInMemory(reviewUid: reviewUid, isUseful: isUseful)
            }
            // 서버 동기화 (fire-and-forget)
            guard let self = self else { return }
            self.reviewService.toggleReviewUseful(reviewUid: reviewUid, userUid: self.currentUserUid)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("toggleUseful API error: \(error.localizedDescription)")
                    }
                }, receiveValue: { _ in })
                .store(in: &self.cancellables)
        }
    }

    private func updateUsefulListInMemory(reviewUid: String, isUseful: Bool) {
        if let index = placeReviews.firstIndex(where: { $0.reviewUid == reviewUid }) {
            var review = placeReviews[index]
            var list = review.usefulList ?? []
            if isUseful {
                if !list.contains(where: { $0.userUid == currentUserUid }) {
                    list.append(UsefulModel(userUid: currentUserUid))
                }
                review.usefulCount += 1
            } else {
                list.removeAll { $0.userUid == currentUserUid }
                review.usefulCount = max(0, review.usefulCount - 1)
            }
            review.usefulList = list
            placeReviews[index] = review
        }

        for placeIndex in places.indices {
            let reviews = places[placeIndex].reviews ?? []
            if let reviewIndex = reviews.firstIndex(where: { $0.reviewUid == reviewUid }) {
                var review = reviews[reviewIndex]
                var list = review.usefulList ?? []
                if isUseful {
                    if !list.contains(where: { $0.userUid == currentUserUid }) {
                        list.append(UsefulModel(userUid: currentUserUid))
                    }
                    review.usefulCount += 1
                } else {
                    list.removeAll { $0.userUid == currentUserUid }
                    review.usefulCount = max(0, review.usefulCount - 1)
                }
                review.usefulList = list
                places[placeIndex].reviews?[reviewIndex] = review
            }
        }

        // 도움되요 취소 시 myUsefulReviews에서 제거
        if !isUseful {
            myUsefulReviews.removeAll { $0.reviewUid == reviewUid }
        }
    }

    private func mergeLocalUsefulState() {
        LocalDB.shared.getUserUsefulReviewUids(userUid: currentUserUid) { [weak self] usefulReviewUids in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let usefulSet = Set(usefulReviewUids)
                for index in self.placeReviews.indices {
                    if usefulSet.contains(self.placeReviews[index].reviewUid) {
                        self.placeReviews[index].usefulList = [UsefulModel(userUid: self.currentUserUid)]
                    }
                }
            }
        }
    }

    // MARK: - Report Methods

    func reportReview(reviewUid: String, reportType: String) {
        reviewService.reportReview(
            reviewUid: reviewUid,
            reporterUid: currentUserUid,
            reportType: reportType,
            reportReason: ""
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("PlaceVM, reportReview // Warning : 신고 실패 - \(error.localizedDescription)")
                }
            },
            receiveValue: { [weak self] _ in
                print("PlaceVM, reportReview // Success : 신고 완료")
                self?.showSnackBarReportReview = true
            }
        )
        .store(in: &cancellables)
    }

    // MARK: - Rating Methods

    func ratePlace(placeUid: String, rating: Int) {
        starService.createRate(placeUid: placeUid, userUid: currentUserUid, star: rating)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.currentUserRating = rating
                    self?.loadAverageRating(placeUid: placeUid)
                }
            )
            .store(in: &cancellables)
    }

    func loadAverageRating(placeUid: String) {
        starService.readAverageRate(placeUid: placeUid)
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
        guides = []
        loadPlaceDetails(place)
        // 북마크 표시 정확성 — myBookmarkedPlaces가 마이페이지 진입 시점에만 채워지던 문제 보완.
        // 비어있고 로그인 상태면 한 번 로드해 PlaceButtons의 isBookmarked가 정확하게 평가되도록.
        if myBookmarkedPlaces.isEmpty && !currentUserUid.isEmpty {
            loadMyBookmarkedPlaces()
        }
    }

    func clearSelection() {
        selectedPlace = nil
        placeReviews = []
        currentPlaceImages = []
        guides = []
        isLoadingGuides = false
        currentUserRating = nil
        placeAverageRating = 0.0
        reviewPage = 1
        reviewHasMore = true
        placeImagePage = 1
        placeImageHasMore = true
    }

    // MARK: - Private Helpers

    private func loadPlaceDetails(_ place: PlaceModel) {
        placeReviews = []
        myReviews = []
        myUsefulReviews = []
        currentUserRating = nil
        placeAverageRating = 0.0
        currentPlaceImages = place.placeImages ?? []
        fullScreenImages = place.placeImages ?? []
        guides = []
        isLoadingGuides = false
    }

    // MARK: - Guide Methods

    func loadGuides(placeUid: String) {
        isLoadingGuides = true
        guideService.readGuides(placeUid: placeUid)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] _ in self?.isLoadingGuides = false },
                receiveValue: { [weak self] guides in
                    self?.guides = guides
                    self?.isLoadingGuides = false
                }
            )
            .store(in: &cancellables)
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

    private func updateLocalBookmarkState(placeUid: String, isBookmarked: Bool) {
        if isBookmarked {
            showSnackBarAddBookMark = true
        } else {
            showSnackBarRemoveBookMark = true
        }

        if let index = places.firstIndex(where: { $0.uid == placeUid }) {
            var place = places[index]
            var bookmarks = place.bookMarks ?? []
            if isBookmarked {
                if !bookmarks.contains(where: { $0.userUid == currentUserUid }) {
                    bookmarks.append(BookMarkModel(userUid: currentUserUid))
                }
            } else {
                bookmarks.removeAll { $0.userUid == currentUserUid }
            }
            place.bookMarks = bookmarks
            places[index] = place
        }
    }

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
    }

    // MARK: - Chip Data (places 데이터에서 파생)

    private func buildChipData() {
        var grouped: [String: (text: String, subtypes: [HorizontalChipSubtypeModel])] = [:]

        for place in places {
            let typeKey = place.type.rawValue
            if grouped[typeKey] == nil {
                grouped[typeKey] = (
                    text: place.typeDisplayText ?? place.type.displayText,
                    subtypes: []
                )
            }
            if let subtype = place.subtype,
               let subtypeText = place.subtypeDisplayText {
                let existing = grouped[typeKey]!.subtypes
                if !existing.contains(where: { $0.id == subtype }) {
                    grouped[typeKey]!.subtypes.append(
                        HorizontalChipSubtypeModel(id: subtype, text: subtypeText)
                    )
                }
            }
        }

        chipData = PlaceType.allCases.compactMap { type in
            guard let group = grouped[type.rawValue] else { return nil }
            return HorizontalChipModel(id: type.rawValue, text: group.text, subtypes: group.subtypes)
        }
    }

    private func loadInitialData() {
        loadPlaces()
        loadMyBookmarkedPlaces()
    }

    deinit {
        print("✅ PlaceViewModel deinit")
    }
}
