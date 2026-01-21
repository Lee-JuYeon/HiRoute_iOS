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
    
    static var sampleSchedules: [ScheduleModel] = [
        ScheduleModel(
            uid: "schedule_001",
            index: 1,
            title: "제주도 여행",
            memo: "친구들과 함께하는 2박3일 제주도 여행",
            editDate: Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 10))!,
            d_day: Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 15))!,
            planList: [
                PlanModel(
                    uid: "visit_001_01",
                    index: 1,
                    memo: "공항에서 렌터카 픽업 후 첫 번째 목적지",
                    placeModel: PlaceModel(
                        uid: "jeju_cafe_001",
                        address: AddressModel(
                            addressUID: "jeju_addr_001",
                            addressLat: 33.4996,
                            addressLon: 126.5312,
                            addressTitle: "제주 공항 카페",
                            sido: "제주특별자치도",
                            gungu: "제주시",
                            dong: "용담동",
                            fullAddress: "제주특별자치도 제주시 용담동 123"
                        ),
                        type: .cafe,
                        title: "제주 공항 카페",
                        subtitle: "공항 근처 • WiFi 무료",
                        thumbnailImageURL: "https://images.khan.co.kr/article/2025/07/01/news-p.v1.20250701.a9878bb6854e4f9f832e68396d1f6bb6_P1.png",
                        workingTimes: [
                            WorkingTimeModel(
                                id: "jeju_cafe_mon",
                                dayTitle: "월",
                                open: "0700",
                                close: "2200"
                            ),
                            WorkingTimeModel(
                                id: "jeju_cafe_tue",
                                dayTitle: "화",
                                open: "0700",
                                close: "2200"
                            )
                        ],
                        reviews: [
                            ReviewModel(
                                reviewUID: "review_001",
                                reviewText: "응급실 시설이 정말 좋고 의료진들이 친절합니다. 대기시간은 있지만 진료 퀄리티가 높아요.",
                                userUID: "user_123",
                                userName: "건강한사람",
                                visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 15))!,
                                usefulCount: 45,
                                images: [
                                    ReviewImageModel(
                                        uid: "세경1",
                                        userUID: "육룡이나르샤1",
                                        date: Date(),
                                        imageURL:  "https://img2.sbs.co.kr/img/sbs_cms/PG/2015/09/22/PG50388602_w640_h360.jpg"
                                    ),
                                    ReviewImageModel(
                                        uid: "세경1",
                                        userUID: "육룡이나르샤2",
                                        date: Date(),
                                        imageURL:  "https://cloudfront-ap-northeast-1.images.arcpublishing.com/chosun/BTLHC72XM3JUD6YA3GGCIVPIVI.jpg"
                                    ),
                                    ReviewImageModel(
                                        uid: "세경1",
                                        userUID: "육룡이나르샤3",
                                        date: Date(),
                                        imageURL:  "https://image.bugsm.co.kr/album/images/350/200105/20010582.jpg"
                                    ),
                                    ReviewImageModel(
                                        uid: "세경1",
                                        userUID: "육룡이나르샤4",
                                        date: Date(),
                                        imageURL:  "https://i.ytimg.com/vi/Iia1ra5DZb4/maxresdefault.jpg"
                                    ),
                                    ReviewImageModel(
                                        uid: "세경1",
                                        userUID: "육룡이나르샤5",
                                        date: Date(),
                                        imageURL:  "https://img1.daumcdn.net/thumb/R1280x0.fjpg/?fname=http://t1.daumcdn.net/brunch/service/user/cTw6/image/wXxvUu8DDrkpNNLm4DSLPxw02IU.jpg"
                                    ),
                                    ReviewImageModel(
                                        uid: "세경1",
                                        userUID: "육룡이나르샤6",
                                        date: Date(),
                                        imageURL:  "https://img2.sbs.co.kr/img/sbs_cms/SR/2016/03/23/SR56128835_w640_h360.jpg"
                                    )
                                ],
                                usefulList: [
                                    UsefulModel(userUID: "user_456"),
                                    UsefulModel(userUID: "super1"),
                                    UsefulModel(userUID: "user_789")
                                ]
                            ),
                            ReviewModel(
                                reviewUID: "review_002",
                                reviewText: "주차공간이 넓고 찾기 쉬워요. 의료진 설명도 자세해서 만족스럽습니다.",
                                userUID: "user_456",
                                userName: "환자가족",
                                visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 3))!,
                                usefulCount: 23,
                                images: [
                                    ReviewImageModel(
                                        uid: "세경1",
                                        userUID: "runon1",
                                        date: Date(),
                                        imageURL:  "https://i.ytimg.com/vi/t98RXxs1fOE/maxresdefault.jpg"
                                    ),
                                    ReviewImageModel(
                                        uid: "세경1",
                                        userUID: "runon2",
                                        date: Date(),
                                        imageURL:  "https://assets.repress.co.kr/photos/42112a1a07f497270cf0f118ce9e977d/original.jpg"
                                    ),
                                    ReviewImageModel(
                                        uid: "세경1",
                                        userUID: "runon3",
                                        date: Date(),
                                        imageURL:  "https://images.khan.co.kr/article/2020/12/16/l_2020121602000827700157831.jpg"
                                    ),
                                    ReviewImageModel(
                                        uid: "세경1",
                                        userUID: "runon4",
                                        date: Date(),
                                        imageURL:  "https://cdn.spotvnews.co.kr/news/photo/202008/375155_473057_5353.jpg"
                                    ),
                                    ReviewImageModel(
                                        uid: "세경1",
                                        userUID: "runon5",
                                        date: Date(),
                                        imageURL:  "https://spnimage.edaily.co.kr/images/photo/files/NP/S/2020/12/PS20122800084.jpg"
                                    ),
                                    ReviewImageModel(
                                        uid: "세경1",
                                        userUID: "runon6",
                                        date: Date(),
                                        imageURL:  "https://dimg.donga.com/wps/SPORTS/IMAGE/2021/01/08/104828506.1.jpg"
                                    )
                                ],
                                usefulList: [
                                    UsefulModel(userUID: "super1"),
                                    UsefulModel(userUID: "user_789")
                                ]
                            ),
                            ReviewModel(
                                reviewUID: "review_003",
                                reviewText: "응급실 시설이 정말 좋고 의료진들이 친절합니다. 대기시간은 있지만 진료 퀄리티가 높아요.",
                                userUID: "user_123",
                                userName: "건강한사람3",
                                visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 15))!,
                                usefulCount: 45,
                                images: [],
                                usefulList: [
                                    UsefulModel(userUID: "user_456"),
                                    UsefulModel(userUID: "user_789")
                                ]
                            ),
                            ReviewModel(
                                reviewUID: "review_004",
                                reviewText: "주차공간이 넓고 찾기 쉬워요. 의료진 설명도 자세해서 만족스럽습니다.",
                                userUID: "44444",
                                userName: "44444",
                                visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 3))!,
                                usefulCount: 23,
                                images: [],
                                usefulList: [UsefulModel(userUID: "user_123")]
                            ),
                            ReviewModel(
                                reviewUID: "review_005",
                                reviewText: "응급실 시설이 정말 좋고 의료진들이 친절합니다. 대기시간은 있지만 진료 퀄리티가 높아요.",
                                userUID: "5555",
                                userName: "건강한5555사람",
                                visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 15))!,
                                usefulCount: 45,
                                images: [],
                                usefulList: [
                                    UsefulModel(userUID: "user_456"),
                                    UsefulModel(userUID: "user_789")
                                ]
                            ),
                            ReviewModel(
                                reviewUID: "review_006",
                                reviewText: "주차공간이 넓고 찾기 쉬워요. 의료진 설명도 자세해서 만족스럽습니다.",
                                userUID: "666",
                                userName: "환자가족6666",
                                visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 3))!,
                                usefulCount: 23,
                                images: [],
                                usefulList: [UsefulModel(userUID: "user_123")]
                            ),
                            ReviewModel(
                                reviewUID: "review_007",
                                reviewText: "응급실 시설이 정말 좋고 의료진들이 친절합니다. 대기시간은 있지만 진료 퀄리티가 높아요.",
                                userUID: "user_7777",
                                userName: "77777건강한사람",
                                visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 15))!,
                                usefulCount: 45,
                                images: [],
                                usefulList: [
                                    UsefulModel(userUID: "user_456"),
                                    UsefulModel(userUID: "user_789")
                                ]
                            ),
                            ReviewModel(
                                reviewUID: "review_008",
                                reviewText: "주차공간이 넓고 찾기 쉬워요. 의료진 설명도 자세해서 만족스럽습니다.",
                                userUID: "user_888",
                                userName: "환자가족8888",
                                visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 3))!,
                                usefulCount: 23,
                                images: [],
                                usefulList: [UsefulModel(userUID: "user_123")]
                            ),
                            ReviewModel(
                                reviewUID: "review_009",
                                reviewText: "응급실 시설이 정말 좋고 의료진들이 친절합니다. 대기시간은 있지만 진료 퀄리티가 높아요.",
                                userUID: "user_9999",
                                userName: "건강한사람9999",
                                visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 15))!,
                                usefulCount: 45,
                                images: [],
                                usefulList: [
                                    UsefulModel(userUID: "user_456"),
                                    UsefulModel(userUID: "user_789")
                                ]
                            ),
                            ReviewModel(
                                reviewUID: "review_010",
                                reviewText: "주차공간이 넓고 찾기 쉬워요. 의료진 설명도 자세해서 만족스럽습니다.",
                                userUID: "user_10",
                                userName: "환자가족10 10",
                                visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 3))!,
                                usefulCount: 23,
                                images: [],
                                usefulList: [UsefulModel(userUID: "user_123")]
                            )
                        ],
                        bookMarks: [],
                        stars: [
                            StarModel(userUID: "user_123", star: 4),
                            StarModel(userUID: "user_456", star: 5)
                        ]
                    ),
                    files: []
                ),
                
                PlanModel(
                    uid: "visit_001_02",
                    index: 2,
                    memo: "점심식사 - 흑돼지 맛집",
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
                        title: "제주 흑돼지 전문점",
                        subtitle: "흑돼지 전문 • 현지 맛집",
                        thumbnailImageURL: "https://example.com/jeju_pork.jpg",
                        workingTimes: [
                            WorkingTimeModel(
                                id: "jeju_rest_mon",
                                dayTitle: "월",
                                open: "1100",
                                close: "2200",
                                lastOrder: "21:30"
                            )
                        ],
                        reviews: [
                            ReviewModel(
                                reviewUID: "review_jeju_001",
                                reviewText: "제주 흑돼지가 정말 맛있어요!",
                                userUID: "user_789",
                                userName: "여행러버",
                                visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 10))!,
                                usefulCount: 15,
                                images: [
                                    ReviewImageModel(
                                        uid: "review_img_001",
                                        userUID: "user_789",
                                        date: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 10))!,
                                        imageURL: "https://example.com/review_pork.jpg"
                                    )
                                ],
                                usefulList: [
                                    UsefulModel(userUID: "user_123"),
                                    UsefulModel(userUID: "user_456")
                                ]
                            )
                        ],
                        bookMarks: [
                            BookMarkModel(userUID: "user_789")
                        ],
                        stars: [
                            StarModel(userUID: "user_789", star: 5),
                            StarModel(userUID: "user_123", star: 4)
                        ]
                    ),
                    files: []
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
            planList: [
                PlanModel(
                    uid: "visit_002_01",
                    index: 1,
                    memo: "가족 모임 식사 장소",
                    placeModel: PlaceModel(
                        uid: "birthday_restaurant_001",
                        address: AddressModel(
                            addressUID: "seoul_addr_003",
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
                        thumbnailImageURL: "https://example.com/pizza.jpg",
                        workingTimes: [
                            WorkingTimeModel(
                                id: "pizza_mon",
                                dayTitle: "월",
                                open: "1100",
                                close: "2200",
                                lastOrder: "21:30"
                            )
                        ],
                        reviews: [],
                        bookMarks: [],
                        stars: []
                    ),
                    files: []
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
            planList: []
        )
    ]
    static let sampleAnnotations: [PlaceModel] = [
        // 1. 서울대학교병원
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
            thumbnailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20190417_78%2F1555465116063h8kKu_JPEG%2FuZNobeKCumi2ws8sEcbdsKX6.jpg",
            workingTimes: [
                WorkingTimeModel(id: "wt_001_mon", dayTitle: "월", open: "0800", close: "1700"),
                WorkingTimeModel(id: "wt_001_tue", dayTitle: "화", open: "0800", close: "1700"),
                WorkingTimeModel(id: "wt_001_wed", dayTitle: "수", open: "0800", close: "1700"),
                WorkingTimeModel(id: "wt_001_thu", dayTitle: "목", open: "0800", close: "1700"),
                WorkingTimeModel(id: "wt_001_fri", dayTitle: "금", open: "0800", close: "1700"),
                WorkingTimeModel(id: "wt_001_sat", dayTitle: "토", open: "0800", close: "1200"),
                WorkingTimeModel(id: "wt_001_sun", dayTitle: "일", open: "휴무", close: "휴무")
            ],
            reviews: [
                ReviewModel(
                    reviewUID: "review_001",
                    reviewText: "응급실 시설이 정말 좋고 의료진들이 친절합니다. 대기시간은 있지만 진료 퀄리티가 높아요.",
                    userUID: "user_123",
                    userName: "건강한사람",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 15))!,
                    usefulCount: 45,
                    images: [],
                    usefulList: [
                        UsefulModel(userUID: "user_456"),
                        UsefulModel(userUID: "user_789")
                    ]
                ),
                ReviewModel(
                    reviewUID: "review_002",
                    reviewText: "주차공간이 넓고 찾기 쉬워요. 의료진 설명도 자세해서 만족스럽습니다.",
                    userUID: "user_456",
                    userName: "환자가족",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 3))!,
                    usefulCount: 23,
                    images: [],
                    usefulList: [UsefulModel(userUID: "user_123")]
                )
            ],
            bookMarks: [
                BookMarkModel(userUID: "super1"),
                BookMarkModel(userUID: "user_123"),
                BookMarkModel(userUID: "user_456")
            ],
            stars: [
                StarModel(userUID: "user_123", star: 5),
                StarModel(userUID: "user_456", star: 4),
                StarModel(userUID: "user_789", star: 5),
                StarModel(userUID: "user_012", star: 4)
            ]
        ),
        
        // 2. 세븐일레븐 홍대점
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
            thumbnailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20200826_105%2F1598427446074FhQeY_JPEG%2FJJsBaMWXYwpkdDEvKmZKIKgJ.jpg",
            workingTimes: [
                WorkingTimeModel(id: "wt_002_mon", dayTitle: "월", open: "0000", close: "2400"),
                WorkingTimeModel(id: "wt_002_tue", dayTitle: "화", open: "0000", close: "2400"),
                WorkingTimeModel(id: "wt_002_wed", dayTitle: "수", open: "0000", close: "2400"),
                WorkingTimeModel(id: "wt_002_thu", dayTitle: "목", open: "0000", close: "2400"),
                WorkingTimeModel(id: "wt_002_fri", dayTitle: "금", open: "0000", close: "2400"),
                WorkingTimeModel(id: "wt_002_sat", dayTitle: "토", open: "0000", close: "2400"),
                WorkingTimeModel(id: "wt_002_sun", dayTitle: "일", open: "0000", close: "2400")
            ],
            reviews: [
                ReviewModel(
                    reviewUID: "review_003",
                    reviewText: "홍대 근처에서 24시간 운영하는 편의점이라 정말 편해요. 직원분들도 친절합니다.",
                    userUID: "user_789",
                    userName: "야식러버",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 20))!,
                    usefulCount: 12,
                    images: [],
                    usefulList: [UsefulModel(userUID: "user_012")]
                )
            ],
            bookMarks: [BookMarkModel(userUID: "user_789")],
            stars: [
                StarModel(userUID: "user_456", star: 4),
                StarModel(userUID: "user_789", star: 3),
                StarModel(userUID: "user_012", star: 4)
            ]
        ),
        
        // 3. 스타벅스 홍대역점
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
            thumbnailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240116_3%2F1705376556071Xe3sT_JPEG%2F%25B4%25D9%25BF%25EE%25B7%25CE%25B5%25E5.jpg",
            workingTimes: [
                WorkingTimeModel(id: "wt_003_mon", dayTitle: "월", open: "0700", close: "2200"),
                WorkingTimeModel(id: "wt_003_tue", dayTitle: "화", open: "0700", close: "2200"),
                WorkingTimeModel(id: "wt_003_wed", dayTitle: "수", open: "0700", close: "2200"),
                WorkingTimeModel(id: "wt_003_thu", dayTitle: "목", open: "0700", close: "2200"),
                WorkingTimeModel(id: "wt_003_fri", dayTitle: "금", open: "0700", close: "2300"),
                WorkingTimeModel(id: "wt_003_sat", dayTitle: "토", open: "0700", close: "2300"),
                WorkingTimeModel(id: "wt_003_sun", dayTitle: "일", open: "0800", close: "2200")
            ],
            reviews: [
                ReviewModel(
                    reviewUID: "review_004",
                    reviewText: "홍대역 바로 앞에 있어서 접근성이 좋고, 매장이 넓어서 자리 찾기도 쉬워요. WiFi도 빠르고 공부하기 좋습니다.",
                    userUID: "user_012",
                    userName: "카페인중독",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 25))!,
                    usefulCount: 23,
                    images: [
                        ReviewImageModel(
                            uid: "img_001",
                            userUID: "user_012",
                            date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 25))!,
                            imageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA2MjhfMTYx%2FMDAxNzUxMTA3NDI4MTEy.kxFrm8frqE1hSFic3QYfJUN511JxCwsnMSjwUDfVTzgg.mxSwv1w6IdCLCT5y7oTdGthjqldYHjQ5EXNw-MHs7oog.JPEG%2F54121148-F522-4AA4-A4BA-5308EDDCD6B9.jpeg%3Ftype%3Dw1500_60_sharpen"
                        )
                    ],
                    usefulList: [
                        UsefulModel(userUID: "user_456"),
                        UsefulModel(userUID: "user_789")
                    ]
                ),
                ReviewModel(
                    reviewUID: "review_005",
                    reviewText: "2층이 있어서 자리가 많고 콘센트도 곳곳에 있어요. 아메리카노 맛도 일정해서 자주 와요.",
                    userUID: "user_345",
                    userName: "스터디족",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 1))!,
                    usefulCount: 15,
                    images: [],
                    usefulList: [UsefulModel(userUID: "user_012")]
                )
            ],
            bookMarks: [
                BookMarkModel(userUID: "super1"),
                BookMarkModel(userUID: "user_345")
            ],
            stars: [
                StarModel(userUID: "super1", star: 5),
                StarModel(userUID: "user_123", star: 4),
                StarModel(userUID: "user_345", star: 4),
                StarModel(userUID: "user_012", star: 5)
            ]
        ),
        
        // 4. 노모어 피자 홍대점
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
            thumbnailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240116_3%2F1705376556071Xe3sT_JPEG%2F%25B4%25D9%25BF%25EE%25B7%25CE%25B5%25E5.jpg",
            workingTimes: [
                WorkingTimeModel(id: "wt_004_mon", dayTitle: "월", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_004_tue", dayTitle: "화", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_004_wed", dayTitle: "수", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_004_thu", dayTitle: "목", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_004_fri", dayTitle: "금", open: "1100", close: "2300", lastOrder: "22:30"),
                WorkingTimeModel(id: "wt_004_sat", dayTitle: "토", open: "1100", close: "2300", lastOrder: "22:30"),
                WorkingTimeModel(id: "wt_004_sun", dayTitle: "일", open: "1100", close: "2200", lastOrder: "21:30")
            ],
            reviews: [
                ReviewModel(
                    reviewUID: "review_006",
                    reviewText: "반반 사이즈로 바질과 옥수수가 베이스인 피자. 다른 피자보다 담백하고 토핑이 맛있음. 도우가 얇아서 좋았음.",
                    userUID: "user_012",
                    userName: "피자매니아",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 18))!,
                    usefulCount: 67,
                    images: [
                        ReviewImageModel(
                            uid: "img_002",
                            userUID: "user_012",
                            date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 18))!,
                            imageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTAyMjVfMTQ1%2FMDAxNzQwNDUxNDU1NTcx.ApVImHPYlJt9xtFPqhCk_QrOxis-qF_Jq-9ltvoAm1Eg.oFvafGlu4bctEM37JZnTqOQoPjE63gtDVlGe-V0rVR0g.JPEG%2F7372C888-7188-42F0-A111-1D6F950C70DA.jpeg%3Ftype%3Dw1500_60_sharpen"
                        ),
                        ReviewImageModel(
                            uid: "img_003",
                            userUID: "user_012",
                            date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 18))!,
                            imageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTAyMjVfMjQx%2FMDAxNzQwNDUxNDUzMDg2.eTmm5Md4IToJ3RhDzjx_OJSN6i3ZAsElD9FN_o6tnD0g.k7y1G6MjhzDzDDRsAveDfpTqItLGYdOeYXGI7nPDqiAg.JPEG%2FC7C6069C-063C-45B6-89B1-6C6FBC78FBDA.jpeg%3Ftype%3Dw1500_60_sharpen"
                        )
                    ],
                    usefulList: [
                        UsefulModel(userUID: "user_123"),
                        UsefulModel(userUID: "user_456"),
                        UsefulModel(userUID: "user_789")
                    ]
                ),
                ReviewModel(
                    reviewUID: "review_007",
                    reviewText: "옥상 테라스가 있어서 분위기 좋아요. 가격은 좀 비싸지만 가끔 먹을만해요. 직원분들 친절하구요.",
                    userUID: "user_567",
                    userName: "데이트족",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 5))!,
                    usefulCount: 34,
                    images: [],
                    usefulList: [
                        UsefulModel(userUID: "user_012"),
                        UsefulModel(userUID: "user_345")
                    ]
                )
            ],
            bookMarks: [
                BookMarkModel(userUID: "super1"),
                BookMarkModel(userUID: "user_012"),
                BookMarkModel(userUID: "user_567")
            ],
            stars: [
                StarModel(userUID: "user_012", star: 5),
                StarModel(userUID: "user_123", star: 4),
                StarModel(userUID: "user_456", star: 5),
                StarModel(userUID: "user_567", star: 4),
                StarModel(userUID: "user_789", star: 4)
            ]
        ),
        
        // 5. 브리트레소 혜화점
        PlaceModel(
            uid: "place_cafe_002",
            address: AddressModel(
                addressUID: "addr_005",
                addressLat: 37.5833,
                addressLon: 127.0051,
                addressTitle: "브리트레소 혜화",
                sido: "서울특별시",
                gungu: "종로구",
                dong: "동숭동",
                fullAddress: "서울특별시 종로구 동숭4길 30-3 1층 101호"
            ),
            type: .cafe,
            title: "브리트레소 혜화",
            subtitle: "영국식 카페 • 애프터눈티",
            thumbnailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240326_195%2F1711439415401NEQr8_JPEG%2F%25C0%25DD%25B7%25E1_%25C0%25FC%25C3%25BC2.jpeg",
            workingTimes: [
                WorkingTimeModel(id: "wt_005_mon", dayTitle: "월", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_005_tue", dayTitle: "화", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_005_wed", dayTitle: "수", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_005_thu", dayTitle: "목", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_005_fri", dayTitle: "금", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_005_sat", dayTitle: "토", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_005_sun", dayTitle: "일", open: "1100", close: "2200", lastOrder: "21:30")
            ],
            reviews: [
                ReviewModel(
                    reviewUID: "review_008",
                    reviewText: "남자친구가 데리고 와쓴데 와.. 애프터눈티 시켰는데 맛있고 카페도 넘 좋았다. 다먹었어요.",
                    userUID: "user_안68",
                    userName: "안68",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 28))!,
                    usefulCount: 42,
                    images: [
                        ReviewImageModel(
                            uid: "img_004",
                            userUID: "user_안68",
                            date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 28))!,
                            imageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA2MjhfMTYx%2FMDAxNzUxMTA3NDI4MTEy.kxFrm8frqE1hSFic3QYfJUN511JxCwsnMSjwUDfVTzgg.mxSwv1w6IdCLCT5y7oTdGthjqldYHjQ5EXNw-MHs7oog.JPEG%2F54121148-F522-4AA4-A4BA-5308EDDCD6B9.jpeg%3Ftype%3Dw1500_60_sharpen"
                        )
                    ],
                    usefulList: [
                        UsefulModel(userUID: "user_567"),
                        UsefulModel(userUID: "user_890")
                    ]
                ),
                ReviewModel(
                    reviewUID: "review_009",
                    reviewText: "인테리어와 분위기 음악 다 좋네요. 시그니처 주문 고민했는데 카운티스그레이를 주문했습니다.",
                    userUID: "user_에밀리",
                    userName: "Emilymoniwa",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 10))!,
                    usefulCount: 18,
                    images: [],
                    usefulList: [
                        UsefulModel(userUID: "user_안68")
                    ]
                )
            ],
            bookMarks: [
                BookMarkModel(userUID: "user_안68"),
                BookMarkModel(userUID: "user_에밀리")
            ],
            stars: [
                StarModel(userUID: "user_안68", star: 5),
                StarModel(userUID: "user_에밀리", star: 4),
                StarModel(userUID: "user_567", star: 5)
            ]
        ),
        
        // 6. 멜팅소울 롯데백화점 본점
        PlaceModel(
            uid: "place_restaurant_002",
            address: AddressModel(
                addressUID: "addr_006",
                addressLat: 37.5648,
                addressLon: 126.9811,
                addressTitle: "멜팅소울 롯데백화점 본점",
                sido: "서울특별시",
                gungu: "중구",
                dong: "남대문로",
                fullAddress: "서울특별시 중구 남대문로 81 롯데백화점 본점 지하 1층"
            ),
            type: .restaurant,
            title: "멜팅소울 롯데백화점 본점",
            subtitle: "버거 전문점 • 대회 우승작",
            thumbnailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240514_119%2F1715668910247St53v_JPEG%2F%25C7%25CA%25B8%25E1%25C6%25C3%25BC%25D2%25BF%25EF%25C7%25C1%25B7%25CE1_%25B4%25EB%25C1%25F6_1_%25B4%25EB%25C1%25F6_1.jpg",
            workingTimes: [
                WorkingTimeModel(id: "wt_006_mon", dayTitle: "월", open: "1030", close: "2000", lastOrder: "19:30"),
                WorkingTimeModel(id: "wt_006_tue", dayTitle: "화", open: "1030", close: "2000", lastOrder: "19:30"),
                WorkingTimeModel(id: "wt_006_wed", dayTitle: "수", open: "1030", close: "2000", lastOrder: "19:30"),
                WorkingTimeModel(id: "wt_006_thu", dayTitle: "목", open: "1030", close: "2000", lastOrder: "19:30"),
                WorkingTimeModel(id: "wt_006_fri", dayTitle: "금", open: "1030", close: "2000", lastOrder: "19:30"),
                WorkingTimeModel(id: "wt_006_sat", dayTitle: "토", open: "1030", close: "2000", lastOrder: "19:30"),
                WorkingTimeModel(id: "wt_006_sun", dayTitle: "일", open: "1030", close: "2000", lastOrder: "19:30")
            ],
            reviews: [
                ReviewModel(
                    reviewUID: "review_010",
                    reviewText: "을지로 롯백 맛집 멜팅소울!! 대회에서 우승한 버거 비주얼도 맛도 최고입니다!! 치즈완전 가득해서 맘에 들었어요!!",
                    userUID: "user_돼지교수",
                    userName: "안돼지교수님",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 25))!,
                    usefulCount: 92,
                    images: [
                        ReviewImageModel(
                            uid: "img_005",
                            userUID: "user_돼지교수",
                            date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 25))!,
                            imageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MjVfNDEg%2FMDAxNzUzNDM5MTcxNDc4.qY1jjwSPxbo4CNkosp6fXsjDLYkn6gX8gKvQfQrvng4g.bXfIS0mFXMynHvp1eByHCTu1yZsH8EA5Lanf5kIqdr4g.JPEG%2F20250725_184425.jpg.jpg%3Ftype%3Dw1500_60_sharpen"
                        )
                    ],
                    usefulList: [
                        UsefulModel(userUID: "user_345"),
                        UsefulModel(userUID: "user_890")
                    ]
                )
            ],
            bookMarks: [
                BookMarkModel(userUID: "user_돼지교수"),
                BookMarkModel(userUID: "super1")
            ],
            stars: [
                StarModel(userUID: "user_돼지교수", star: 5),
                StarModel(userUID: "user_345", star: 4),
                StarModel(userUID: "user_890", star: 5)
            ]
        ),
        
        // 7. GS25 편의점
        PlaceModel(
            uid: "place_store_002",
            address: AddressModel(
                addressUID: "addr_007",
                addressLat: 37.5701,
                addressLon: 126.9762,
                addressTitle: "GS25 명동중앙점",
                sido: "서울특별시",
                gungu: "중구",
                dong: "명동",
                fullAddress: "서울특별시 중구 명동8길 16"
            ),
            type: .store,
            title: "GS25 명동중앙점",
            subtitle: "편의점 • 관광지 근처",
            thumbnailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20200826_105%2F1598427446074FhQeY_JPEG%2FJJsBaMWXYwpkdDEvKmZKIKgJ.jpg",
            workingTimes: [
                WorkingTimeModel(id: "wt_007_mon", dayTitle: "월", open: "0600", close: "0100"),
                WorkingTimeModel(id: "wt_007_tue", dayTitle: "화", open: "0600", close: "0100"),
                WorkingTimeModel(id: "wt_007_wed", dayTitle: "수", open: "0600", close: "0100"),
                WorkingTimeModel(id: "wt_007_thu", dayTitle: "목", open: "0600", close: "0100"),
                WorkingTimeModel(id: "wt_007_fri", dayTitle: "금", open: "0600", close: "0200"),
                WorkingTimeModel(id: "wt_007_sat", dayTitle: "토", open: "0600", close: "0200"),
                WorkingTimeModel(id: "wt_007_sun", dayTitle: "일", open: "0700", close: "0100")
            ],
            reviews: [
                ReviewModel(
                    reviewUID: "review_011",
                    reviewText: "명동 관광 중에 간식이나 음료수 사기 편해요. 외국인 손님들도 많이 오시네요.",
                    userUID: "user_관광객",
                    userName: "서울나들이",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 10))!,
                    usefulCount: 8,
                    images: [],
                    usefulList: [
                        UsefulModel(userUID: "user_567")
                    ]
                )
            ],
            bookMarks: [],
            stars: [
                StarModel(userUID: "user_관광객", star: 4),
                StarModel(userUID: "user_567", star: 3)
            ]
        ),
        
        // 8. 강남세브란스병원
        PlaceModel(
            uid: "place_hospital_002",
            address: AddressModel(
                addressUID: "addr_008",
                addressLat: 37.4925,
                addressLon: 127.0348,
                addressTitle: "강남세브란스병원",
                sido: "서울특별시",
                gungu: "강남구",
                dong: "도곡동",
                fullAddress: "서울특별시 강남구 언주로 211"
            ),
            type: .hospital,
            title: "강남세브란스병원",
            subtitle: "종합병원 • 전문진료",
            thumbnailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20190417_78%2F1555465116063h8kKu_JPEG%2FuZNobeKCumi2ws8sEcbdsKX6.jpg",
            workingTimes: [
                WorkingTimeModel(id: "wt_008_mon", dayTitle: "월", open: "0800", close: "1730"),
                WorkingTimeModel(id: "wt_008_tue", dayTitle: "화", open: "0800", close: "1730"),
                WorkingTimeModel(id: "wt_008_wed", dayTitle: "수", open: "0800", close: "1730"),
                WorkingTimeModel(id: "wt_008_thu", dayTitle: "목", open: "0800", close: "1730"),
                WorkingTimeModel(id: "wt_008_fri", dayTitle: "금", open: "0800", close: "1730"),
                WorkingTimeModel(id: "wt_008_sat", dayTitle: "토", open: "0800", close: "1300"),
                WorkingTimeModel(id: "wt_008_sun", dayTitle: "일", open: "휴무", close: "휴무")
            ],
            reviews: [
                ReviewModel(
                    reviewUID: "review_012",
                    reviewText: "최신 의료장비와 시설이 좋습니다. 주차장도 넓고 찾아가기 쉬워요.",
                    userUID: "user_건강관리",
                    userName: "건강챙김이",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 8))!,
                    usefulCount: 25,
                    images: [],
                    usefulList: [
                        UsefulModel(userUID: "user_890")
                    ]
                )
            ],
            bookMarks: [
                BookMarkModel(userUID: "user_건강관리")
            ],
            stars: [
                StarModel(userUID: "user_건강관리", star: 5),
                StarModel(userUID: "user_890", star: 4),
                StarModel(userUID: "user_234", star: 5)
            ]
        )
        ]
    
    static let samplePlaces: [PlaceModel] = [
        // 1. 서울대학교병원
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
            thumbnailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20190417_78%2F1555465116063h8kKu_JPEG%2FuZNobeKCumi2ws8sEcbdsKX6.jpg",
            workingTimes: [
                WorkingTimeModel(id: "wt_001_mon", dayTitle: "월", open: "0800", close: "1700"),
                WorkingTimeModel(id: "wt_001_tue", dayTitle: "화", open: "0800", close: "1700"),
                WorkingTimeModel(id: "wt_001_wed", dayTitle: "수", open: "0800", close: "1700"),
                WorkingTimeModel(id: "wt_001_thu", dayTitle: "목", open: "0800", close: "1700"),
                WorkingTimeModel(id: "wt_001_fri", dayTitle: "금", open: "0800", close: "1700"),
                WorkingTimeModel(id: "wt_001_sat", dayTitle: "토", open: "0800", close: "1200"),
                WorkingTimeModel(id: "wt_001_sun", dayTitle: "일", open: "휴무", close: "휴무")
            ],
            reviews: [
                ReviewModel(
                    reviewUID: "review_001",
                    reviewText: "응급실 시설이 정말 좋고 의료진들이 친절합니다. 대기시간은 있지만 진료 퀄리티가 높아요.",
                    userUID: "user_123",
                    userName: "건강한사람",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 15))!,
                    usefulCount: 45,
                    images: [],
                    usefulList: [
                        UsefulModel(userUID: "user_456"),
                        UsefulModel(userUID: "user_789")
                    ]
                ),
                ReviewModel(
                    reviewUID: "review_002",
                    reviewText: "주차공간이 넓고 찾기 쉬워요. 의료진 설명도 자세해서 만족스럽습니다.",
                    userUID: "user_456",
                    userName: "환자가족",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 3))!,
                    usefulCount: 23,
                    images: [],
                    usefulList: [UsefulModel(userUID: "user_123")]
                )
            ],
            bookMarks: [
                BookMarkModel(userUID: "super1"),
                BookMarkModel(userUID: "user_123"),
                BookMarkModel(userUID: "user_456")
            ],
            stars: [
                StarModel(userUID: "user_123", star: 5),
                StarModel(userUID: "user_456", star: 4),
                StarModel(userUID: "user_789", star: 5),
                StarModel(userUID: "user_012", star: 4)
            ]
        ),
        
        // 2. 세븐일레븐 홍대점
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
            thumbnailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20200826_105%2F1598427446074FhQeY_JPEG%2FJJsBaMWXYwpkdDEvKmZKIKgJ.jpg",
            workingTimes: [
                WorkingTimeModel(id: "wt_002_mon", dayTitle: "월", open: "0000", close: "2400"),
                WorkingTimeModel(id: "wt_002_tue", dayTitle: "화", open: "0000", close: "2400"),
                WorkingTimeModel(id: "wt_002_wed", dayTitle: "수", open: "0000", close: "2400"),
                WorkingTimeModel(id: "wt_002_thu", dayTitle: "목", open: "0000", close: "2400"),
                WorkingTimeModel(id: "wt_002_fri", dayTitle: "금", open: "0000", close: "2400"),
                WorkingTimeModel(id: "wt_002_sat", dayTitle: "토", open: "0000", close: "2400"),
                WorkingTimeModel(id: "wt_002_sun", dayTitle: "일", open: "0000", close: "2400")
            ],
            reviews: [
                ReviewModel(
                    reviewUID: "review_003",
                    reviewText: "홍대 근처에서 24시간 운영하는 편의점이라 정말 편해요. 직원분들도 친절합니다.",
                    userUID: "user_789",
                    userName: "야식러버",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 20))!,
                    usefulCount: 12,
                    images: [],
                    usefulList: [UsefulModel(userUID: "user_012")]
                )
            ],
            bookMarks: [BookMarkModel(userUID: "user_789")],
            stars: [
                StarModel(userUID: "user_456", star: 4),
                StarModel(userUID: "user_789", star: 3),
                StarModel(userUID: "user_012", star: 4)
            ]
        ),
        
        // 3. 스타벅스 홍대역점
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
            thumbnailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240116_3%2F1705376556071Xe3sT_JPEG%2F%25B4%25D9%25BF%25EE%25B7%25CE%25B5%25E5.jpg",
            workingTimes: [
                WorkingTimeModel(id: "wt_003_mon", dayTitle: "월", open: "0700", close: "2200"),
                WorkingTimeModel(id: "wt_003_tue", dayTitle: "화", open: "0700", close: "2200"),
                WorkingTimeModel(id: "wt_003_wed", dayTitle: "수", open: "0700", close: "2200"),
                WorkingTimeModel(id: "wt_003_thu", dayTitle: "목", open: "0700", close: "2200"),
                WorkingTimeModel(id: "wt_003_fri", dayTitle: "금", open: "0700", close: "2300"),
                WorkingTimeModel(id: "wt_003_sat", dayTitle: "토", open: "0700", close: "2300"),
                WorkingTimeModel(id: "wt_003_sun", dayTitle: "일", open: "0800", close: "2200")
            ],
            reviews: [
                ReviewModel(
                    reviewUID: "review_004",
                    reviewText: "홍대역 바로 앞에 있어서 접근성이 좋고, 매장이 넓어서 자리 찾기도 쉬워요. WiFi도 빠르고 공부하기 좋습니다.",
                    userUID: "user_012",
                    userName: "카페인중독",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 25))!,
                    usefulCount: 23,
                    images: [
                        ReviewImageModel(
                            uid: "img_001",
                            userUID: "user_012",
                            date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 25))!,
                            imageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA2MjhfMTYx%2FMDAxNzUxMTA3NDI4MTEy.kxFrm8frqE1hSFic3QYfJUN511JxCwsnMSjwUDfVTzgg.mxSwv1w6IdCLCT5y7oTdGthjqldYHjQ5EXNw-MHs7oog.JPEG%2F54121148-F522-4AA4-A4BA-5308EDDCD6B9.jpeg%3Ftype%3Dw1500_60_sharpen"
                        )
                    ],
                    usefulList: [
                        UsefulModel(userUID: "user_456"),
                        UsefulModel(userUID: "user_789")
                    ]
                ),
                ReviewModel(
                    reviewUID: "review_005",
                    reviewText: "2층이 있어서 자리가 많고 콘센트도 곳곳에 있어요. 아메리카노 맛도 일정해서 자주 와요.",
                    userUID: "user_345",
                    userName: "스터디족",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 1))!,
                    usefulCount: 15,
                    images: [],
                    usefulList: [UsefulModel(userUID: "user_012")]
                )
            ],
            bookMarks: [
                BookMarkModel(userUID: "super1"),
                BookMarkModel(userUID: "user_345")
            ],
            stars: [
                StarModel(userUID: "super1", star: 5),
                StarModel(userUID: "user_123", star: 4),
                StarModel(userUID: "user_345", star: 4),
                StarModel(userUID: "user_012", star: 5)
            ]
        ),
        
        // 4. 노모어 피자 홍대점
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
            thumbnailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240116_3%2F1705376556071Xe3sT_JPEG%2F%25B4%25D9%25BF%25EE%25B7%25CE%25B5%25E5.jpg",
            workingTimes: [
                WorkingTimeModel(id: "wt_004_mon", dayTitle: "월", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_004_tue", dayTitle: "화", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_004_wed", dayTitle: "수", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_004_thu", dayTitle: "목", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_004_fri", dayTitle: "금", open: "1100", close: "2300", lastOrder: "22:30"),
                WorkingTimeModel(id: "wt_004_sat", dayTitle: "토", open: "1100", close: "2300", lastOrder: "22:30"),
                WorkingTimeModel(id: "wt_004_sun", dayTitle: "일", open: "1100", close: "2200", lastOrder: "21:30")
            ],
            reviews: [
                ReviewModel(
                    reviewUID: "review_006",
                    reviewText: "반반 사이즈로 바질과 옥수수가 베이스인 피자. 다른 피자보다 담백하고 토핑이 맛있음. 도우가 얇아서 좋았음.",
                    userUID: "user_012",
                    userName: "피자매니아",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 18))!,
                    usefulCount: 67,
                    images: [
                        ReviewImageModel(
                            uid: "img_002",
                            userUID: "user_012",
                            date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 18))!,
                            imageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTAyMjVfMTQ1%2FMDAxNzQwNDUxNDU1NTcx.ApVImHPYlJt9xtFPqhCk_QrOxis-qF_Jq-9ltvoAm1Eg.oFvafGlu4bctEM37JZnTqOQoPjE63gtDVlGe-V0rVR0g.JPEG%2F7372C888-7188-42F0-A111-1D6F950C70DA.jpeg%3Ftype%3Dw1500_60_sharpen"
                        ),
                        ReviewImageModel(
                            uid: "img_003",
                            userUID: "user_012",
                            date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 18))!,
                            imageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTAyMjVfMjQx%2FMDAxNzQwNDUxNDUzMDg2.eTmm5Md4IToJ3RhDzjx_OJSN6i3ZAsElD9FN_o6tnD0g.k7y1G6MjhzDzDDRsAveDfpTqItLGYdOeYXGI7nPDqiAg.JPEG%2FC7C6069C-063C-45B6-89B1-6C6FBC78FBDA.jpeg%3Ftype%3Dw1500_60_sharpen"
                        )
                    ],
                    usefulList: [
                        UsefulModel(userUID: "user_123"),
                        UsefulModel(userUID: "user_456"),
                        UsefulModel(userUID: "user_789")
                    ]
                ),
                ReviewModel(
                    reviewUID: "review_007",
                    reviewText: "옥상 테라스가 있어서 분위기 좋아요. 가격은 좀 비싸지만 가끔 먹을만해요. 직원분들 친절하구요.",
                    userUID: "user_567",
                    userName: "데이트족",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 5))!,
                    usefulCount: 34,
                    images: [],
                    usefulList: [
                        UsefulModel(userUID: "user_012"),
                        UsefulModel(userUID: "user_345")
                    ]
                )
            ],
            bookMarks: [
                BookMarkModel(userUID: "super1"),
                BookMarkModel(userUID: "user_012"),
                BookMarkModel(userUID: "user_567")
            ],
            stars: [
                StarModel(userUID: "user_012", star: 5),
                StarModel(userUID: "user_123", star: 4),
                StarModel(userUID: "user_456", star: 5),
                StarModel(userUID: "user_567", star: 4),
                StarModel(userUID: "user_789", star: 4)
            ]
        ),
        
        // 5. 브리트레소 혜화점
        PlaceModel(
            uid: "place_cafe_002",
            address: AddressModel(
                addressUID: "addr_005",
                addressLat: 37.5833,
                addressLon: 127.0051,
                addressTitle: "브리트레소 혜화",
                sido: "서울특별시",
                gungu: "종로구",
                dong: "동숭동",
                fullAddress: "서울특별시 종로구 동숭4길 30-3 1층 101호"
            ),
            type: .cafe,
            title: "브리트레소 혜화",
            subtitle: "영국식 카페 • 애프터눈티",
            thumbnailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240326_195%2F1711439415401NEQr8_JPEG%2F%25C0%25DD%25B7%25E1_%25C0%25FC%25C3%25BC2.jpeg",
            workingTimes: [
                WorkingTimeModel(id: "wt_005_mon", dayTitle: "월", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_005_tue", dayTitle: "화", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_005_wed", dayTitle: "수", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_005_thu", dayTitle: "목", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_005_fri", dayTitle: "금", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_005_sat", dayTitle: "토", open: "1100", close: "2200", lastOrder: "21:30"),
                WorkingTimeModel(id: "wt_005_sun", dayTitle: "일", open: "1100", close: "2200", lastOrder: "21:30")
            ],
            reviews: [
                ReviewModel(
                    reviewUID: "review_008",
                    reviewText: "남자친구가 데리고 와쓴데 와.. 애프터눈티 시켰는데 맛있고 카페도 넘 좋았다. 다먹었어요.",
                    userUID: "user_안68",
                    userName: "안68",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 28))!,
                    usefulCount: 42,
                    images: [
                        ReviewImageModel(
                            uid: "img_004",
                            userUID: "user_안68",
                            date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 28))!,
                            imageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA2MjhfMTYx%2FMDAxNzUxMTA3NDI4MTEy.kxFrm8frqE1hSFic3QYfJUN511JxCwsnMSjwUDfVTzgg.mxSwv1w6IdCLCT5y7oTdGthjqldYHjQ5EXNw-MHs7oog.JPEG%2F54121148-F522-4AA4-A4BA-5308EDDCD6B9.jpeg%3Ftype%3Dw1500_60_sharpen"
                        )
                    ],
                    usefulList: [
                        UsefulModel(userUID: "user_567"),
                        UsefulModel(userUID: "user_890")
                    ]
                ),
                ReviewModel(
                    reviewUID: "review_009",
                    reviewText: "인테리어와 분위기 음악 다 좋네요. 시그니처 주문 고민했는데 카운티스그레이를 주문했습니다.",
                    userUID: "user_에밀리",
                    userName: "Emilymoniwa",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 10))!,
                    usefulCount: 18,
                    images: [],
                    usefulList: [
                        UsefulModel(userUID: "user_안68")
                    ]
                )
            ],
            bookMarks: [
                BookMarkModel(userUID: "user_안68"),
                BookMarkModel(userUID: "user_에밀리")
            ],
            stars: [
                StarModel(userUID: "user_안68", star: 5),
                StarModel(userUID: "user_에밀리", star: 4),
                StarModel(userUID: "user_567", star: 5)
            ]
        ),
        
        // 6. 멜팅소울 롯데백화점 본점
        PlaceModel(
            uid: "place_restaurant_002",
            address: AddressModel(
                addressUID: "addr_006",
                addressLat: 37.5648,
                addressLon: 126.9811,
                addressTitle: "멜팅소울 롯데백화점 본점",
                sido: "서울특별시",
                gungu: "중구",
                dong: "남대문로",
                fullAddress: "서울특별시 중구 남대문로 81 롯데백화점 본점 지하 1층"
            ),
            type: .restaurant,
            title: "멜팅소울 롯데백화점 본점",
            subtitle: "버거 전문점 • 대회 우승작",
            thumbnailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240514_119%2F1715668910247St53v_JPEG%2F%25C7%25CA%25B8%25E1%25C6%25C3%25BC%25D2%25BF%25EF%25C7%25C1%25B7%25CE1_%25B4%25EB%25C1%25F6_1_%25B4%25EB%25C1%25F6_1.jpg",
            workingTimes: [
                WorkingTimeModel(id: "wt_006_mon", dayTitle: "월", open: "1030", close: "2000", lastOrder: "19:30"),
                WorkingTimeModel(id: "wt_006_tue", dayTitle: "화", open: "1030", close: "2000", lastOrder: "19:30"),
                WorkingTimeModel(id: "wt_006_wed", dayTitle: "수", open: "1030", close: "2000", lastOrder: "19:30"),
                WorkingTimeModel(id: "wt_006_thu", dayTitle: "목", open: "1030", close: "2000", lastOrder: "19:30"),
                WorkingTimeModel(id: "wt_006_fri", dayTitle: "금", open: "1030", close: "2000", lastOrder: "19:30"),
                WorkingTimeModel(id: "wt_006_sat", dayTitle: "토", open: "1030", close: "2000", lastOrder: "19:30"),
                WorkingTimeModel(id: "wt_006_sun", dayTitle: "일", open: "1030", close: "2000", lastOrder: "19:30")
            ],
            reviews: [
                ReviewModel(
                    reviewUID: "review_010",
                    reviewText: "을지로 롯백 맛집 멜팅소울!! 대회에서 우승한 버거 비주얼도 맛도 최고입니다!! 치즈완전 가득해서 맘에 들었어요!!",
                    userUID: "user_돼지교수",
                    userName: "안돼지교수님",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 25))!,
                    usefulCount: 92,
                    images: [
                        ReviewImageModel(
                            uid: "img_005",
                            userUID: "user_돼지교수",
                            date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 25))!,
                            imageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MjVfNDEg%2FMDAxNzUzNDM5MTcxNDc4.qY1jjwSPxbo4CNkosp6fXsjDLYkn6gX8gKvQfQrvng4g.bXfIS0mFXMynHvp1eByHCTu1yZsH8EA5Lanf5kIqdr4g.JPEG%2F20250725_184425.jpg.jpg%3Ftype%3Dw1500_60_sharpen"
                        )
                    ],
                    usefulList: [
                        UsefulModel(userUID: "user_345"),
                        UsefulModel(userUID: "user_890")
                    ]
                )
            ],
            bookMarks: [
                BookMarkModel(userUID: "user_돼지교수"),
                BookMarkModel(userUID: "super1")
            ],
            stars: [
                StarModel(userUID: "user_돼지교수", star: 5),
                StarModel(userUID: "user_345", star: 4),
                StarModel(userUID: "user_890", star: 5)
            ]
        ),
        
        // 7. GS25 편의점
        PlaceModel(
            uid: "place_store_002",
            address: AddressModel(
                addressUID: "addr_007",
                addressLat: 37.5701,
                addressLon: 126.9762,
                addressTitle: "GS25 명동중앙점",
                sido: "서울특별시",
                gungu: "중구",
                dong: "명동",
                fullAddress: "서울특별시 중구 명동8길 16"
            ),
            type: .store,
            title: "GS25 명동중앙점",
            subtitle: "편의점 • 관광지 근처",
            thumbnailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20200826_105%2F1598427446074FhQeY_JPEG%2FJJsBaMWXYwpkdDEvKmZKIKgJ.jpg",
            workingTimes: [
                WorkingTimeModel(id: "wt_007_mon", dayTitle: "월", open: "0600", close: "0100"),
                WorkingTimeModel(id: "wt_007_tue", dayTitle: "화", open: "0600", close: "0100"),
                WorkingTimeModel(id: "wt_007_wed", dayTitle: "수", open: "0600", close: "0100"),
                WorkingTimeModel(id: "wt_007_thu", dayTitle: "목", open: "0600", close: "0100"),
                WorkingTimeModel(id: "wt_007_fri", dayTitle: "금", open: "0600", close: "0200"),
                WorkingTimeModel(id: "wt_007_sat", dayTitle: "토", open: "0600", close: "0200"),
                WorkingTimeModel(id: "wt_007_sun", dayTitle: "일", open: "0700", close: "0100")
            ],
            reviews: [
                ReviewModel(
                    reviewUID: "review_011",
                    reviewText: "명동 관광 중에 간식이나 음료수 사기 편해요. 외국인 손님들도 많이 오시네요.",
                    userUID: "user_관광객",
                    userName: "서울나들이",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 10))!,
                    usefulCount: 8,
                    images: [],
                    usefulList: [
                        UsefulModel(userUID: "user_567")
                    ]
                )
            ],
            bookMarks: [],
            stars: [
                StarModel(userUID: "user_관광객", star: 4),
                StarModel(userUID: "user_567", star: 3)
            ]
        ),
        
        // 8. 강남세브란스병원
        PlaceModel(
            uid: "place_hospital_002",
            address: AddressModel(
                addressUID: "addr_008",
                addressLat: 37.4925,
                addressLon: 127.0348,
                addressTitle: "강남세브란스병원",
                sido: "서울특별시",
                gungu: "강남구",
                dong: "도곡동",
                fullAddress: "서울특별시 강남구 언주로 211"
            ),
            type: .hospital,
            title: "강남세브란스병원",
            subtitle: "종합병원 • 전문진료",
            thumbnailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20190417_78%2F1555465116063h8kKu_JPEG%2FuZNobeKCumi2ws8sEcbdsKX6.jpg",
            workingTimes: [
                WorkingTimeModel(id: "wt_008_mon", dayTitle: "월", open: "0800", close: "1730"),
                WorkingTimeModel(id: "wt_008_tue", dayTitle: "화", open: "0800", close: "1730"),
                WorkingTimeModel(id: "wt_008_wed", dayTitle: "수", open: "0800", close: "1730"),
                WorkingTimeModel(id: "wt_008_thu", dayTitle: "목", open: "0800", close: "1730"),
                WorkingTimeModel(id: "wt_008_fri", dayTitle: "금", open: "0800", close: "1730"),
                WorkingTimeModel(id: "wt_008_sat", dayTitle: "토", open: "0800", close: "1300"),
                WorkingTimeModel(id: "wt_008_sun", dayTitle: "일", open: "휴무", close: "휴무")
            ],
            reviews: [
                ReviewModel(
                    reviewUID: "review_012",
                    reviewText: "최신 의료장비와 시설이 좋습니다. 주차장도 넓고 찾아가기 쉬워요.",
                    userUID: "user_건강관리",
                    userName: "건강챙김이",
                    visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 8))!,
                    usefulCount: 25,
                    images: [],
                    usefulList: [
                        UsefulModel(userUID: "user_890")
                    ]
                )
            ],
            bookMarks: [
                BookMarkModel(userUID: "user_건강관리")
            ],
            stars: [
                StarModel(userUID: "user_건강관리", star: 5),
                StarModel(userUID: "user_890", star: 4),
                StarModel(userUID: "user_234", star: 5)
            ]
        )
    ]
}
