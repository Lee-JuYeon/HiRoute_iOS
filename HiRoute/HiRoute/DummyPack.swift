//
//  DummyPack.swift
//  HiRoute
//
//  Created by Jupond on 6/26/25.
//
import Foundation

class DummyPack {
    
    static let shared = DummyPack()
    
    private init(){}
    
    let myDataUID = "super1"
    
    // MARK: - Sample Data
    
    static let sampleSchedules: [ScheduleModel] = [
        ScheduleModel(
            uid: "schedule_001",
            index: 1,
            title: "제주도 여행",
            memo: "친구들과 함께하는 2박3일 제주도 여행",
            editDate: Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 10))!,
            d_day: Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 15))!,
            visitPlaceList: [
                VisitPlaceModel(
                    uid: "visit_001_01",
                    index: 1,
                    memo: "공항에서 렌터카 픽업 후 첫 번째 목적지",
                    placeModel: PlaceModel(
                        uid: "jeju_cafe_001",
                        address: AddressModel(
                            addressUID: "jeju_addr_001",
                            addressLat: 33.4996,
                            addressLon: 126.5312,
                            addressTitle: "제주공항 근처 카페",
                            sido: "제주특별자치도",
                            gungu: "제주시",
                            dong: "용담동",
                            fullAddress: "제주특별자치도 제주시 용담동 123"
                        ),
                        type: .cafe,
                        title: "제주 공항 카페",
                        subtitle: "공항 근처 • WiFi 무료",
                        thumbanilImageURL: "https://example.com/jeju_cafe.jpg",
                        imageURLs: [],
                        workingTimes: [],
                        reviews: [],
                        totalStarCount: 250,
                        totalBookmarkCount: 45,
                        isBookmarkedLocally: false
                    ),
                    files: ["jeju_map.pdf", "flight_ticket.jpg"]
                ),
                VisitPlaceModel(
                    uid: "visit_001_02",
                    index: 2,
                    memo: "점심식사 장소, 흑돼지 맛집",
                    placeModel: PlaceModel(
                        uid: "jeju_restaurant_001",
                        address: AddressModel(
                            addressUID: "jeju_addr_002",
                            addressLat: 33.5102,
                            addressLon: 126.5211,
                            addressTitle: "제주 흑돼지 맛집",
                            sido: "제주특별자치도",
                            gungu: "제주시",
                            dong: "이도동",
                            fullAddress: "제주특별자치도 제주시 이도동 456"
                        ),
                        type: .restaurant,
                        title: "제주 흑돼지 맛집",
                        subtitle: "흑돼지 전문점 • 현지 맛집",
                        thumbanilImageURL: "https://example.com/jeju_pork.jpg",
                        imageURLs: [],
                        workingTimes: [],
                        reviews: [],
                        totalStarCount: 420,
                        totalBookmarkCount: 89,
                        isBookmarkedLocally: true
                    ),
                    files: ["restaurant_menu.jpg"]
                ),
                VisitPlaceModel(
                    uid: "visit_001_03",
                    index: 3,
                    memo: "숙소 체크인 및 휴식",
                    placeModel: PlaceModel(
                        uid: "jeju_hotel_001",
                        address: AddressModel(
                            addressUID: "jeju_addr_003",
                            addressLat: 33.4890,
                            addressLon: 126.4983,
                            addressTitle: "제주 리조트",
                            sido: "제주특별자치도",
                            gungu: "제주시",
                            dong: "연동",
                            fullAddress: "제주특별자치도 제주시 연동 789"
                        ),
                        type: .hospital, // 임시로 hospital 사용 (숙박시설 타입이 없어서)
                        title: "제주 오션뷰 리조트",
                        subtitle: "바다 전망 • 수영장",
                        thumbanilImageURL: "https://example.com/jeju_resort.jpg",
                        imageURLs: [],
                        workingTimes: [],
                        reviews: [],
                        totalStarCount: 380,
                        totalBookmarkCount: 67,
                        isBookmarkedLocally: true
                    ),
                    files: ["reservation_confirm.pdf", "resort_info.jpg"]
                )
            ]
        ),
        
        ScheduleModel(
            uid: "schedule_002",
            index: 2,
            title: "부모님 생신",
            memo: "아버지 70세 생신 가족 모임",
            editDate: Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 12))!,
            d_day: Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 3))!,
            visitPlaceList: [
                VisitPlaceModel(
                    uid: "visit_002_01",
                    index: 1,
                    memo: "가족 모임 식사 장소",
                    placeModel: samplePlaces[3], // 노모어 피자 홍대점 재사용
                    files: ["family_photo.jpg"]
                ),
                VisitPlaceModel(
                    uid: "visit_002_02",
                    index: 2,
                    memo: "생신케이크 픽업",
                    placeModel: samplePlaces[2], // 스타벅스 홍대역점 재사용
                    files: ["cake_order.pdf"]
                )
            ]
        ),
        
        ScheduleModel(
            uid: "schedule_003",
            index: 3,
            title: "회사 송년회",
            memo: "팀 전체 송년회 및 회식",
            editDate: Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 8))!,
            d_day: Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 20))!,
            visitPlaceList: [
                VisitPlaceModel(
                    uid: "visit_003_01",
                    index: 1,
                    memo: "회식 장소, 회사 근처",
                    placeModel: samplePlaces[3], // 노모어 피자 홍대점
                    files: []
                )
            ]
        ),
        
        // 나머지 ScheduleModel들은 기존과 동일하게 빈 배열로 유지
        ScheduleModel(
            uid: "schedule_004",
            index: 4,
            title: "대학교 동창회",
            memo: "졸업 후 첫 동창회 모임",
            editDate: Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 14))!,
            d_day: Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 28))!,
            visitPlaceList: []
        )
    ]
    static let sampleAnnotations: [PlaceModel] = [
            // 병원 데이터
            PlaceModel(
                uid: "place_hospital_001",
                address: AddressModel(
                    addressUID: "addr_001",
                    addressLat: 37.5665,
                    addressLon: 126.9780,
                    addressTitle: "서울대학교병원",
                    sido: "서울특별시",
                    gungu: "종로구",
                    dong: "연건동",
                    fullAddress: "서울특별시 종로구 대학로 101"
                ),
                type: .hospital,
                title: "서울대학교병원",
                subtitle: "종합병원 • 24시간 응급실",
                thumbanilImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20190417_78%2F1555465116063h8kKu_JPEG%2FuZNobeKCumi2ws8sEcbdsKX6.jpg",
                imageURLs: [
                    "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20190417_78%2F1555465116063h8kKu_JPEG%2FuZNobeKCumi2ws8sEcbdsKX6.jpg"
                ],
                workingTimes: [
                    WorkingTimeModel(dayTitle: "월", open: "0800", close: "1700"),
                    WorkingTimeModel(dayTitle: "화", open: "0800", close: "1700"),
                    WorkingTimeModel(dayTitle: "수", open: "0800", close: "1700"),
                    WorkingTimeModel(dayTitle: "목", open: "0800", close: "1700"),
                    WorkingTimeModel(dayTitle: "금", open: "0800", close: "1700"),
                    WorkingTimeModel(dayTitle: "토", open: "0800", close: "1200"),
                    WorkingTimeModel(dayTitle: "일", open: "휴무", close: "휴무")
                ],
                reviews: [
                    ReviewModel(
                        reviewUID: "review_hospital_001",
                        reviewText: "응급실 시설이 정말 좋고 의료진들이 친절합니다. 대기시간은 좀 있지만 진료 퀄리티가 높아요.",
                        userUID: "user_123",
                        userName: "건강한사람",
                        visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 15))!,
                        usefulCount: 45,
                        images: []
                    )
                ],
                totalStarCount: 850,
                totalBookmarkCount: 120,
                isBookmarkedLocally: true
            ),
            
            // 편의점 데이터
            PlaceModel(
                uid: "place_store_001",
                address: AddressModel(
                    addressUID: "addr_002",
                    addressLat: 37.5655,
                    addressLon: 126.9770,
                    addressTitle: "세븐일레븐 홍대점",
                    sido: "서울특별시",
                    gungu: "마포구",
                    dong: "서교동",
                    fullAddress: "서울특별시 마포구 홍익로5길 20"
                ),
                type: .store,
                title: "세븐일레븐 홍대점",
                subtitle: "편의점 • 24시간 운영",
                thumbanilImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20200826_105%2F1598427446074FhQeY_JPEG%2FJJsBaMWXYwpkdDEvKmZKIKgJ.jpg",
                imageURLs: [
                    "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20200826_105%2F1598427446074FhQeY_JPEG%2FJJsBaMWXYwpkdDEvKmZKIKgJ.jpg"
                ],
                workingTimes: [
                    WorkingTimeModel(dayTitle: "월", open: "0000", close: "2400"),
                    WorkingTimeModel(dayTitle: "화", open: "0000", close: "2400"),
                    WorkingTimeModel(dayTitle: "수", open: "0000", close: "2400"),
                    WorkingTimeModel(dayTitle: "목", open: "0000", close: "2400"),
                    WorkingTimeModel(dayTitle: "금", open: "0000", close: "2400"),
                    WorkingTimeModel(dayTitle: "토", open: "0000", close: "2400"),
                    WorkingTimeModel(dayTitle: "일", open: "0000", close: "2400")
                ],
                reviews: [
                    ReviewModel(
                        reviewUID: "review_store_001",
                        reviewText: "홍대 근처에서 24시간 운영하는 편의점이라 정말 편해요. 물건도 다양하게 있고 직원분들도 친절합니다.",
                        userUID: "user_456",
                        userName: "야식러버",
                        visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 20))!,
                        usefulCount: 12,
                        images: []
                    )
                ],
                totalStarCount: 320,
                totalBookmarkCount: 45,
                isBookmarkedLocally: false
            ),
            
            // 카페 데이터
            PlaceModel(
                uid: "place_cafe_001",
                address: AddressModel(
                    addressUID: "addr_003",
                    addressLat: 37.5675,
                    addressLon: 126.9790,
                    addressTitle: "스타벅스 홍대역점",
                    sido: "서울특별시",
                    gungu: "마포구",
                    dong: "서교동",
                    fullAddress: "서울특별시 마포구 양화로 160"
                ),
                type: .cafe,
                title: "스타벅스 홍대역점",
                subtitle: "카페 • WiFi 무료",
                thumbanilImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240116_3%2F1705376556071Xe3sT_JPEG%2F%25B4%25D9%25BF%25EE%25B7%25CE%25B5%25E5.jpg",
                imageURLs: [
                    "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20250110_79%2F1736478428509Eg9Fr_JPEG%2F%25B9%25E8%25B4%25DE%25C0%25C7-%25B9%25CE%25C1%25B7-%25BB%25F3%25B4%25DC%25C0%25CC%25B9%25CC%25C1%25F6_250109-1.jpg",
                    "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20250110_243%2F1736478428527T2M0l_JPEG%2F%25B9%25E8%25B4%25DE%25C0%25C7-%25B9%25CE%25C1%25B7-%25BB%25F3%25B4%25DC%25C0%25CC%25B9%25CC%25C1%25F6_250109-2.jpg"
                ],
                workingTimes: [
                    WorkingTimeModel(dayTitle: "월", open: "0700", close: "2200"),
                    WorkingTimeModel(dayTitle: "화", open: "0700", close: "2200"),
                    WorkingTimeModel(dayTitle: "수", open: "0700", close: "2200"),
                    WorkingTimeModel(dayTitle: "목", open: "0700", close: "2200"),
                    WorkingTimeModel(dayTitle: "금", open: "0700", close: "2300"),
                    WorkingTimeModel(dayTitle: "토", open: "0700", close: "2300"),
                    WorkingTimeModel(dayTitle: "일", open: "0800", close: "2200")
                ],
                reviews: [
                    ReviewModel(
                        reviewUID: "review_cafe_001",
                        reviewText: "홍대역 바로 앞에 있어서 접근성이 좋고, 매장이 넓어서 자리 찾기도 쉬워요. WiFi도 빠르고 공부하기 좋습니다.",
                        userUID: "user_789",
                        userName: "카페인중독",
                        visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 25))!,
                        usefulCount: 23,
                        images: [
                            "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTAyMjVfMTg3%2FMDAxNzQwNDUxNDU0Njc5.mdZhMJ2381E42wZdZgCtAMQDluigDAUTcVOdMNEfLIkg.kD7UUkpopv82bg2LWKBOw1RfPYV_BaxiUhE00BPVfMMg.JPEG%2F1B13DE7E-96F4-4BB8-AC56-240192202F48.jpeg%3Ftype%3Dw1500_60_sharpen"
                        ]
                    )
                ],
                totalStarCount: 450,
                totalBookmarkCount: 89,
                isBookmarkedLocally: true
            ),
            
            // 레스토랑 데이터
            PlaceModel(
                uid: "place_restaurant_001",
                address: AddressModel(
                    addressUID: "addr_004",
                    addressLat: 37.5685,
                    addressLon: 126.9800,
                    addressTitle: "노모어 피자 홍대점",
                    sido: "서울특별시",
                    gungu: "마포구",
                    dong: "서교동",
                    fullAddress: "서울특별시 마포구 홍익로 30"
                ),
                type: .restaurant,
                title: "노모어 피자 홍대점",
                subtitle: "이탈리안 레스토랑 • 피자 전문점",
                thumbanilImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240116_3%2F1705376556071Xe3sT_JPEG%2F%25B4%25D9%25BF%25EE%25B7%25CE%25B5%25E5.jpg",
                imageURLs: [
                    "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20250110_79%2F1736478428509Eg9Fr_JPEG%2F%25B9%25E8%25B4%25DE%25C0%25C7-%25B9%25CE%25C1%25B7-%25BB%25F3%25B4%25DC%25C0%25CC%25B9%25CC%25C1%25F6_250109-1.jpg",
                    "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTAyMjVfMTg3%2FMDAxNzQwNDUxNDU0Njc5.mdZhMJ2381E42wZdZgCtAMQDluigDAUTcVOdMNEfLIkg.kD7UUkpopv82bg2LWKBOw1RfPYV_BaxiUhE00BPVfMMg.JPEG%2F1B13DE7E-96F4-4BB8-AC56-240192202F48.jpeg%3Ftype%3Dw1500_60_sharpen"
                ],
                workingTimes: [
                    WorkingTimeModel(dayTitle: "월", open: "1100", close: "2200", lastOrder: "21:30"),
                    WorkingTimeModel(dayTitle: "화", open: "1100", close: "2200", lastOrder: "21:30"),
                    WorkingTimeModel(dayTitle: "수", open: "1100", close: "2200", lastOrder: "21:30"),
                    WorkingTimeModel(dayTitle: "목", open: "1100", close: "2200", lastOrder: "21:30"),
                    WorkingTimeModel(dayTitle: "금", open: "1100", close: "2300", lastOrder: "22:30"),
                    WorkingTimeModel(dayTitle: "토", open: "1100", close: "2300", lastOrder: "22:30"),
                    WorkingTimeModel(dayTitle: "일", open: "1100", close: "2200", lastOrder: "21:30")
                ],
                reviews: [
                    ReviewModel(
                        reviewUID: "review_restaurant_001",
                        reviewText: "반반 사이즈로 바질과 옥수수가 베이스인 피자. 다른 피자보다 담백하고 토핑이 맛있음. 도우가 얇아서 좋았음.",
                        userUID: "user_012",
                        userName: "피자매니아",
                        visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 18))!,
                        usefulCount: 67,
                        images: [
                            "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTAyMjVfMTQ1%2FMDAxNzQwNDUxNDU1NTcx.ApVImHPYlJt9xtFPqhCk_QrOxis-qF_Jq-9ltvoAm1Eg.oFvafGlu4bctEM37JZnTqOQoPjE63gtDVlGe-V0rVR0g.JPEG%2F7372C888-7188-42F0-A111-1D6F950C70DA.jpeg%3Ftype%3Dw1500_60_sharpen"
                        ]
                    )
                ],
                totalStarCount: 680,
                totalBookmarkCount: 156,
                isBookmarkedLocally: true
            )
        ]
    static let samplePlaces: [PlaceModel] = [
            // 병원 데이터
            PlaceModel(
                uid: "place_hospital_001",
                address: AddressModel(
                    addressUID: "addr_001",
                    addressLat: 37.5665,
                    addressLon: 126.9780,
                    addressTitle: "서울대학교병원",
                    sido: "서울특별시",
                    gungu: "종로구",
                    dong: "연건동",
                    fullAddress: "서울특별시 종로구 대학로 101"
                ),
                type: .hospital,
                title: "서울대학교병원",
                subtitle: "종합병원 • 24시간 응급실",
                thumbanilImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20190417_78%2F1555465116063h8kKu_JPEG%2FuZNobeKCumi2ws8sEcbdsKX6.jpg",
                imageURLs: [
                    "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20190417_78%2F1555465116063h8kKu_JPEG%2FuZNobeKCumi2ws8sEcbdsKX6.jpg"
                ],
                workingTimes: [
                    WorkingTimeModel(dayTitle: "월", open: "0800", close: "1700"),
                    WorkingTimeModel(dayTitle: "화", open: "0800", close: "1700"),
                    WorkingTimeModel(dayTitle: "수", open: "0800", close: "1700"),
                    WorkingTimeModel(dayTitle: "목", open: "0800", close: "1700"),
                    WorkingTimeModel(dayTitle: "금", open: "0800", close: "1700"),
                    WorkingTimeModel(dayTitle: "토", open: "0800", close: "1200"),
                    WorkingTimeModel(dayTitle: "일", open: "휴무", close: "휴무")
                ],
                reviews: [
                    ReviewModel(
                        reviewUID: "review_hospital_001",
                        reviewText: "응급실 시설이 정말 좋고 의료진들이 친절합니다. 대기시간은 좀 있지만 진료 퀄리티가 높아요.",
                        userUID: "user_123",
                        userName: "건강한사람",
                        visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 15))!,
                        usefulCount: 45,
                        images: []
                    )
                ],
                totalStarCount: 850,
                totalBookmarkCount: 120,
                isBookmarkedLocally: true
            ),
            
            // 편의점 데이터
            PlaceModel(
                uid: "place_store_001",
                address: AddressModel(
                    addressUID: "addr_002",
                    addressLat: 37.5655,
                    addressLon: 126.9770,
                    addressTitle: "세븐일레븐 홍대점",
                    sido: "서울특별시",
                    gungu: "마포구",
                    dong: "서교동",
                    fullAddress: "서울특별시 마포구 홍익로5길 20"
                ),
                type: .store,
                title: "세븐일레븐 홍대점",
                subtitle: "편의점 • 24시간 운영",
                thumbanilImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20200826_105%2F1598427446074FhQeY_JPEG%2FJJsBaMWXYwpkdDEvKmZKIKgJ.jpg",
                imageURLs: [
                    "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20200826_105%2F1598427446074FhQeY_JPEG%2FJJsBaMWXYwpkdDEvKmZKIKgJ.jpg"
                ],
                workingTimes: [
                    WorkingTimeModel(dayTitle: "월", open: "0000", close: "2400"),
                    WorkingTimeModel(dayTitle: "화", open: "0000", close: "2400"),
                    WorkingTimeModel(dayTitle: "수", open: "0000", close: "2400"),
                    WorkingTimeModel(dayTitle: "목", open: "0000", close: "2400"),
                    WorkingTimeModel(dayTitle: "금", open: "0000", close: "2400"),
                    WorkingTimeModel(dayTitle: "토", open: "0000", close: "2400"),
                    WorkingTimeModel(dayTitle: "일", open: "0000", close: "2400")
                ],
                reviews: [
                    ReviewModel(
                        reviewUID: "review_store_001",
                        reviewText: "홍대 근처에서 24시간 운영하는 편의점이라 정말 편해요. 물건도 다양하게 있고 직원분들도 친절합니다.",
                        userUID: "user_456",
                        userName: "야식러버",
                        visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 20))!,
                        usefulCount: 12,
                        images: []
                    )
                ],
                totalStarCount: 320,
                totalBookmarkCount: 45,
                isBookmarkedLocally: false
            ),
            
            // 카페 데이터
            PlaceModel(
                uid: "place_cafe_001",
                address: AddressModel(
                    addressUID: "addr_003",
                    addressLat: 37.5675,
                    addressLon: 126.9790,
                    addressTitle: "스타벅스 홍대역점",
                    sido: "서울특별시",
                    gungu: "마포구",
                    dong: "서교동",
                    fullAddress: "서울특별시 마포구 양화로 160"
                ),
                type: .cafe,
                title: "스타벅스 홍대역점",
                subtitle: "카페 • WiFi 무료",
                thumbanilImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240116_3%2F1705376556071Xe3sT_JPEG%2F%25B4%25D9%25BF%25EE%25B7%25CE%25B5%25E5.jpg",
                imageURLs: [
                    "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20250110_79%2F1736478428509Eg9Fr_JPEG%2F%25B9%25E8%25B4%25DE%25C0%25C7-%25B9%25CE%25C1%25B7-%25BB%25F3%25B4%25DC%25C0%25CC%25B9%25CC%25C1%25F6_250109-1.jpg",
                    "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20250110_243%2F1736478428527T2M0l_JPEG%2F%25B9%25E8%25B4%25DE%25C0%25C7-%25B9%25CE%25C1%25B7-%25BB%25F3%25B4%25DC%25C0%25CC%25B9%25CC%25C1%25F6_250109-2.jpg"
                ],
                workingTimes: [
                    WorkingTimeModel(dayTitle: "월", open: "0700", close: "2200"),
                    WorkingTimeModel(dayTitle: "화", open: "0700", close: "2200"),
                    WorkingTimeModel(dayTitle: "수", open: "0700", close: "2200"),
                    WorkingTimeModel(dayTitle: "목", open: "0700", close: "2200"),
                    WorkingTimeModel(dayTitle: "금", open: "0700", close: "2300"),
                    WorkingTimeModel(dayTitle: "토", open: "0700", close: "2300"),
                    WorkingTimeModel(dayTitle: "일", open: "0800", close: "2200")
                ],
                reviews: [
                    ReviewModel(
                        reviewUID: "review_cafe_001",
                        reviewText: "홍대역 바로 앞에 있어서 접근성이 좋고, 매장이 넓어서 자리 찾기도 쉬워요. WiFi도 빠르고 공부하기 좋습니다.",
                        userUID: "user_789",
                        userName: "카페인중독",
                        visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 25))!,
                        usefulCount: 23,
                        images: [
                            "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTAyMjVfMTg3%2FMDAxNzQwNDUxNDU0Njc5.mdZhMJ2381E42wZdZgCtAMQDluigDAUTcVOdMNEfLIkg.kD7UUkpopv82bg2LWKBOw1RfPYV_BaxiUhE00BPVfMMg.JPEG%2F1B13DE7E-96F4-4BB8-AC56-240192202F48.jpeg%3Ftype%3Dw1500_60_sharpen"
                        ]
                    )
                ],
                totalStarCount: 450,
                totalBookmarkCount: 89,
                isBookmarkedLocally: true
            ),
            
            // 레스토랑 데이터
            PlaceModel(
                uid: "place_restaurant_001",
                address: AddressModel(
                    addressUID: "addr_004",
                    addressLat: 37.5685,
                    addressLon: 126.9800,
                    addressTitle: "노모어 피자 홍대점",
                    sido: "서울특별시",
                    gungu: "마포구",
                    dong: "서교동",
                    fullAddress: "서울특별시 마포구 홍익로 30"
                ),
                type: .restaurant,
                title: "노모어 피자 홍대점",
                subtitle: "이탈리안 레스토랑 • 피자 전문점",
                thumbanilImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240116_3%2F1705376556071Xe3sT_JPEG%2F%25B4%25D9%25BF%25EE%25B7%25CE%25B5%25E5.jpg",
                imageURLs: [
                    "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20250110_79%2F1736478428509Eg9Fr_JPEG%2F%25B9%25E8%25B4%25DE%25C0%25C7-%25B9%25CE%25C1%25B7-%25BB%25F3%25B4%25DC%25C0%25CC%25B9%25CC%25C1%25F6_250109-1.jpg",
                    "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTAyMjVfMTg3%2FMDAxNzQwNDUxNDU0Njc5.mdZhMJ2381E42wZdZgCtAMQDluigDAUTcVOdMNEfLIkg.kD7UUkpopv82bg2LWKBOw1RfPYV_BaxiUhE00BPVfMMg.JPEG%2F1B13DE7E-96F4-4BB8-AC56-240192202F48.jpeg%3Ftype%3Dw1500_60_sharpen"
                ],
                workingTimes: [
                    WorkingTimeModel(dayTitle: "월", open: "1100", close: "2200", lastOrder: "21:30"),
                    WorkingTimeModel(dayTitle: "화", open: "1100", close: "2200", lastOrder: "21:30"),
                    WorkingTimeModel(dayTitle: "수", open: "1100", close: "2200", lastOrder: "21:30"),
                    WorkingTimeModel(dayTitle: "목", open: "1100", close: "2200", lastOrder: "21:30"),
                    WorkingTimeModel(dayTitle: "금", open: "1100", close: "2300", lastOrder: "22:30"),
                    WorkingTimeModel(dayTitle: "토", open: "1100", close: "2300", lastOrder: "22:30"),
                    WorkingTimeModel(dayTitle: "일", open: "1100", close: "2200", lastOrder: "21:30")
                ],
                reviews: [
                    ReviewModel(
                        reviewUID: "review_restaurant_001",
                        reviewText: "반반 사이즈로 바질과 옥수수가 베이스인 피자. 다른 피자보다 담백하고 토핑이 맛있음. 도우가 얇아서 좋았음.",
                        userUID: "user_012",
                        userName: "피자매니아",
                        visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 18))!,
                        usefulCount: 67,
                        images: [
                            "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTAyMjVfMTQ1%2FMDAxNzQwNDUxNDU1NTcx.ApVImHPYlJt9xtFPqhCk_QrOxis-qF_Jq-9ltvoAm1Eg.oFvafGlu4bctEM37JZnTqOQoPjE63gtDVlGe-V0rVR0g.JPEG%2F7372C888-7188-42F0-A111-1D6F950C70DA.jpeg%3Ftype%3Dw1500_60_sharpen"
                        ]
                    )
                ],
                totalStarCount: 680,
                totalBookmarkCount: 156,
                isBookmarkedLocally: true
            )
        ]
   
}
