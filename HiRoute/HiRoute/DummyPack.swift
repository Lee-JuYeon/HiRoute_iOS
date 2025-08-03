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
    let samplePlans = [
        PlanModel(
            planUID: "plan_1",
            planTitle: "혜화 8월 지민이랑 저녁약속. 피자랑 영국식 카페 ㄱ",
            planCreatorUID: "user_1",
            meetingDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 13))!,
            meetingAddress: AddressModel(
                addressUID: "address_1",
                addressTitle: "혜화",
                addressLat: 37.578647,
                addressLon: 127.002090,
                sido: "서울특별시",
                gungu: "종로구",
                dong: "연건동",
                fullAddress: "서울특별시 종로구 연건동 72-1"
            ),
            partnerType: PartnerType.friend,
            activityType: ActivityType.restaurant,
            appointmentTimeType: AppointmentTimeType.afternoon,
            visitRoutes: [
                RouteModel(
                    routeUID: "route_1",
                    routeType: "카페", //소상공인 소분류로하나? 뭐로가지?
                    routeTitle: "노모어 피자 대학로점",
                    routeMemo: "여기서 반반피자 먹기로함. 이후 공차 ㄱ",
                    address: AddressModel(
                        addressUID: "address_2",
                        addressTitle: "노모어 피자 대학로점",
                        addressLat: 37.583319,
                        addressLon: 126.999358,
                        sido: "서울특별시",
                        gungu: "종로구",
                        dong: "창경궁로 246",
                        fullAddress: "서울특별시 종로구 창경궁로 246"
                    ),
                    thumbNailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240116_3%2F1705376556071Xe3sT_JPEG%2F%25B4%25D9%25BF%25EE%25B7%25CE%25B5%25E5.jpg",
                    images: [
                        "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20250110_79%2F1736478428509Eg9Fr_JPEG%2F%25B9%25E8%25B4%25DE%25C0%25C7-%25B9%25CE%25C1%25B7-%25BB%25F3%25B4%25DC%25C0%25CC%25B9%25CC%25C1%25F6_250109-1.jpg",
                        "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20250110_243%2F1736478428527T2M0l_JPEG%2F%25B9%25E8%25B4%25DE%25C0%25C7-%25B9%25CE%25C1%25B7-%25BB%25F3%25B4%25DC%25C0%25CC%25B9%25CC%25C1%25F6_250109-2.jpg",
                        "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MTdfMTE1%2FMDAxNzUyNzUzNTA4MTU0.fvvMUW9ZRWzU_GOVDEPcTWSZI88eEVx3Mf4vamFtmlEg.vWhBverEYFRtcLJQYXaNBo62x3J_OhGYYC6As6-XLrcg.JPEG%2FScreenshot_20250717_205714_NAVER.jpg.jpg%3Ftype%3Dw1500_60_sharpen"
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
                            reviewUID: "review_1",
                            reviewText: "반반 사이즈로 바질과 옥수수가 비이스인 피자. 다른 피자보다 담백하고 토핑이 맛있음. 도우가 얇아서 좋았음. 좀 비싼 느낌이지만 가끔은 먹을 정도의 가격. 1,2층올 되어있고 옥상 테라스가 있음.",
                            userUID: "user_123",
                            userName: "행복한 자수성가",
                            visitDate: Calendar.current.date(from: DateComponents(year: 2024, month: 2, day: 24))!,
                            usefulCount: 2,
                            images: [
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTAyMjVfMTg3%2FMDAxNzQwNDUxNDU0Njc5.mdZhMJ2381E42wZdZgCtAMQDluigDAUTcVOdMNEfLIkg.kD7UUkpopv82bg2LWKBOw1RfPYV_BaxiUhE00BPVfMMg.JPEG%2F1B13DE7E-96F4-4BB8-AC56-240192202F48.jpeg%3Ftype%3Dw1500_60_sharpen",
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTAyMjVfMTQ1%2FMDAxNzQwNDUxNDU1NTcx.ApVImHPYlJt9xtFPqhCk_QrOxis-qF_Jq-9ltvoAm1Eg.oFvafGlu4bctEM37JZnTqOQoPjE63gtDVlGe-V0rVR0g.JPEG%2F7372C888-7188-42F0-A111-1D6F950C70DA.jpeg%3Ftype%3Dw1500_60_sharpen",
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTAyMjVfMjQx%2FMDAxNzQwNDUxNDUzMDg2.eTmm5Md4IToJ3RhDzjx_OJSN6i3ZAsElD9FN_o6tnD0g.k7y1G6MjhzDzDDRsAveDfpTqItLGYdOeYXGI7nPDqiAg.JPEG%2FC7C6069C-063C-45B6-89B1-6C6FBC78FBDA.jpeg%3Ftype%3Dw1500_60_sharpen",
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTAyMjVfMTIg%2FMDAxNzQwNDUxNDUzNTIz.xYZIFGFgPaE6gTJah4d1lKzu_WG8rk13-It6H8MzM6Qg.iFJ9j4gbRyr_o7IkGnmGLpsx6J8Oq1y0RPq54sxY1jcg.JPEG%2FADBE1AE7-406A-4B37-A3B7-C872130CA66A.jpeg%3Ftype%3Dw1500_60_sharpen"
                            ]
                        )
                    ],
                    totalStarCount: 300,
                    totalBookmarkCount: 21,
                    isBookmarkedLocally: true
                ),
                RouteModel(
                    routeUID: "route_2",
                    routeType: "카페", //소상공인 소분류로하나? 뭐로가지?
                    routeTitle: "브리트레소 혜화",
                    routeMemo: "영국식 카페임. 디저트랑 같이 먹자",
                    address: AddressModel(
                        addressUID: "address_3",
                        addressTitle: "브리트레소 혜화",
                        addressLat: 37.5833198,
                        addressLon: 127.005177,
                        sido: "서울특별시",
                        gungu: "종로구",
                        dong: "동숭4길 246",
                        fullAddress: "서울특별시 종로구 동숭4길 30-3 1층 101호"
                    ),
                    thumbNailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240326_195%2F1711439415401NEQr8_JPEG%2F%25C0%25BD%25B7%25E1_%25C0%25FC%25C3%25BC2.jpeg",
                    images: [
                        "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20250215_235%2F1739614756753JkdO8_JPEG%2F%25C6%25BC%25B1%25D7%25B7%25B9.jpg",
                        "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240314_267%2F1710387666891cX3tS_JPEG%2FIMG_7754.jpeg",
                        "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MjlfMjc5%2FMDAxNzUzNzg0MTM0ODg3.83F49g86DjdsYIZ8htmXp-GN4lYbSGTYAMpfFHdE5FIg.svJQAZ36hK5HzP02O-3ywoRrRzY4UcCFpuHyiQwjnf4g.JPEG%2F060F609F-AE81-419A-A1BE-AAC67BFB2899.jpeg%3Ftype%3Dw1500_60_sharpen"
                    ],
                    workingTimes: [
                        WorkingTimeModel(dayTitle: "월", open: "1100", close: "2200", lastOrder: "21:30"),
                        WorkingTimeModel(dayTitle: "화", open: "1100", close: "2200", lastOrder: "21:30"),
                        WorkingTimeModel(dayTitle: "수", open: "1100", close: "2200", lastOrder: "21:30"),
                        WorkingTimeModel(dayTitle: "목", open: "1100", close: "2200", lastOrder: "21:30"),
                        WorkingTimeModel(dayTitle: "금", open: "1100", close: "2200", lastOrder: "21:30"),
                        WorkingTimeModel(dayTitle: "토", open: "1100", close: "2200", lastOrder: "21:30"),
                        WorkingTimeModel(dayTitle: "일", open: "1100", close: "2200", lastOrder: "21:30")
                    ],
                    reviews: [
                        ReviewModel(
                            reviewUID: "review_2",
                            reviewText: "남자친구가 지인이랑 왔다가 애프터눈티 시켰는데 맛있고 카페도 넘 좋았다고 나중에 데리고 오겠다하고 오늘 데리고 와쓴데 와.. 오기 직전에 밥 3인분 푸파하고 와서 디저트 안먹으려 했는데 다먹음요.",
                            userUID: "user_안68",
                            userName: "안68",
                            visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 28))!,
                            usefulCount: 2,
                            images: [
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA2MjhfMTYx%2FMDAxNzUxMTA3NDI4MTEy.kxFrm8frqE1hSFic3QYfJUN511JxCwsnMSjwUDfVTzgg.mxSwv1w6IdCLCT5y7oTdGthjqldYHjQ5EXNw-MHs7oog.JPEG%2F54121148-F522-4AA4-A4BA-5308EDDCD6B9.jpeg%3Ftype%3Dw1500_60_sharpen",
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA2MjhfNzUg%2FMDAxNzUxMTA3NDI4MDY1.dhUKB6RtfnSeDiZRtUEJpgtruDrRG7M-VAQ3vi-iqTkg.hoYjdJuS_Ul6IQNJkUZzgDOmB_NlRdeqNYNDKnDt_t4g.JPEG%2F102B293C-BA3E-40CC-A459-AEE9189351DC.jpeg%3Ftype%3Dw1500_60_sharpen",
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA2MjhfMjUg%2FMDAxNzUxMTA3NDI4MDg1.WPbItmr_VuLthzeADGRJ0dXa-jKzNy0YQD7qdEe9sXQg.spkF6T4VIeNqvhERk1FIsrsTdc7RHIMLVcbFJp_IDS4g.JPEG%2FF58F99C1-6A69-4503-AE52-D9372EA2634E.jpeg%3Ftype%3Dw1500_60_sharpen"
                            ]
                        ),
                        ReviewModel(
                            reviewUID: "review_4",
                            reviewText: "찾기가 좀 어려웠지만 전화드리니 상세히 알려주시고 인테리어와 분위기 음악 다 좋네요. 시그니처주문여부를 고민하다 일단 카운티스그레니를 주문했습니다.",
                            userUID: "user_에밀리",
                            userName: "Emilymoniwa",
                            visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 10))!,
                            usefulCount: 30,
                            images: [
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA2MTBfMjQ3%2FMDAxNzQ5NTQwMDE5OTgw.A2i7kxwz9yWJMFH9WIRVQEOZTIRz8YgTDixozstfGrgg._0Xx0aiUdKhb2Zj01pqmsHZbkcoq95dj7pBglqWScgsg.JPEG%2F1000133827.jpg%3Ftype%3Dw1500_60_sharpen",
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA2MTBfMTYg%2FMDAxNzQ5NTQwMDIwMDM5.GA8WG_2nBSrKXRgSQFkhVyKJJkZvj5ac5SOVO_7qOhkg.hWfrKcOWtdjwU5aPDfnjifzbvYYwyunGWnNacK7qBAMg.JPEG%2F1000133828.jpg%3Ftype%3Dw1500_60_sharpen",
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA2MTBfOTYg%2FMDAxNzQ5NTQwMDIwMjM3.f9xcpk9XmyDA_rWc-tpoMmp0HzyOWMvdEfo_imjAFD4g.swkFzzlAYWbT15fZBOraI6QZSb6F0L_-PoaeVfUBxkkg.JPEG%2F1000133837.jpg%3Ftype%3Dw1500_60_sharpen",
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA2MTBfMTcz%2FMDAxNzQ5NTQwMDE5OTU4.r4j3tzMgjPCkTcCJGC9-BfOO9DJi83bohxH87p3uAfUg.lMorTv9Rg0jPiESKUvMDIOmFpFPSJc5cl0HjNiCD77wg.JPEG%2F1000133840.jpg%3Ftype%3Dw1500_60_sharpen"
                            ]
                        ),
                        ReviewModel(
                            reviewUID: "review_22",
                            reviewText: "평일 오후에 여유 느끼고 싶어서 왔어요. 디저트 사실 이ㅡㅃ기만 할 줄 알았는데, 맛도 너무 좋아요! 카페 여러군데 중 고민했는데 여기로 선택 잘한거 같네요.",
                            userUID: "user_miyago",
                            userName: "Miyaaa",
                            visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 23))!,
                            usefulCount: 8,
                            images: [
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MjNfMTQ1%2FMDAxNzUzMjUyNjgxNTU2.Y8j11KGLNb_w1Sb_irCYZoktEMud7K7O5gt7lpzdb5Qg.qdP7bWSrhptq5npIptPwBOQFyC5zr1E22dKccl0IY_cg.JPEG%2F04CF2D87-F676-448E-862C-8BC2D0B30FEF.jpeg%3Ftype%3Dw1500_60_sharpen",
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MjNfMjY0%2FMDAxNzUzMjUyNjgxNTMx._uQuoJHrl3Uuj6xe5rRCTvYi5KE12v0XS_AAxyo8Ue0g.AVb8TQ5rpfUPkY35aT0Kj3rJBZE5nMH_h4snrFSv4H8g.JPEG%2FEC4F8146-1E59-436E-AC42-0CADA362F88F.jpeg%3Ftype%3Dw1500_60_sharpen"
                            ]
                        )
                    ],
                    totalStarCount: 1232,
                    totalBookmarkCount: 295,
                    isBookmarkedLocally: true
                ),
                RouteModel(
                    routeUID: "route_99",
                    routeType: "액티비티", //소상공인 소분류로하나? 뭐로가지?
                    routeTitle: "보드게임카페 레드버튼 대학로점",
                    routeMemo: "정태오면 같이 3명이서 보드게임 한판 스근하게",
                    address: AddressModel(
                        addressUID: "address_8",
                        addressTitle: "보드게임카페 레드버튼 대학로점",
                        addressLat: 37.583330,
                        addressLon: 127.000944,
                        sido: "서울특별시",
                        gungu: "종로구",
                        dong: "대명길 9 4층",
                        fullAddress: "서울특별시 종로구 대명길 9 4층"
                    ),
                    thumbNailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20200820_231%2F15978901980448D5jT_JPEG%2FtEjtohJPJHPHP-VTEAxL4UgH.jpg",
                    images: [
                        "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20200820_276%2F15978902012280Fv7i_JPEG%2F3hFFlPYPtUiHDv4kXOeWPg9k.jpg",
                        "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20200820_288%2F1597890204005dj4Hw_JPEG%2F449pRqg_4Bk-kn7T_E7RYWpC.jpg"
                    ],
                    workingTimes: [
                        WorkingTimeModel(dayTitle: "월", open: "1300", close: "2400"),
                        WorkingTimeModel(dayTitle: "화", open: "1300", close: "2400"),
                        WorkingTimeModel(dayTitle: "수", open: "1300", close: "2400"),
                        WorkingTimeModel(dayTitle: "목", open: "1300", close: "2400"),
                        WorkingTimeModel(dayTitle: "금", open: "1300", close: "2400"),
                        WorkingTimeModel(dayTitle: "토", open: "1300", close: "2400"),
                        WorkingTimeModel(dayTitle: "일", open: "1300", close: "2400")
                    ],
                    reviews: [
                        ReviewModel(
                            reviewUID: "review_777",
                            reviewText: "혜화역에서 애들이랑 보드게임카페 어디 갈까 했는데 보드게임카페는 역시 레드버튼이ㅣ라서 근처에 바로 왔어요. 쾌적하고 게임 상태도 너무 꺠끗하고 좋아서 시원하게 놀았습니다.",
                            userUID: "user_아기물고기",
                            userName: "아기물고기31",
                            visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 30))!,
                            usefulCount: 40,
                            images: [
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MzBfMjQy%2FMDAxNzUzODY5ODE1OTM0.89DF7qLU_hC_4ZlwR99WLPjQtModJBjlH601wEp8Nbcg.OOI8B4rfYHGb4d7SyuU5EZzHqZDRs-QXlXMmWqg2mjIg.JPEG%2F1000012795.jpg.jpg%3Ftype%3Dw1500_60_sharpen",
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MzBfMTg2%2FMDAxNzUzODY5ODE2MDc3.gJ_vVJlyzJSChXMbQaY19TTf94sicYR7GsCdfocWuwQg.q63PFrBvUjZxDCB7cU91K8uvcdPH9nhXaDUynein66kg.JPEG%2F1000012794.jpg.jpg%3Ftype%3Dw1500_60_sharpen",
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MzBfMTE2%2FMDAxNzUzODY5ODE2MDk5.0gn-ukqHKjQqE-s2aMALO3uI6122RYj35GjkPMJ97R8g.mtGoy-6l1WhrQzpIA4Q8gjSRW-e-s1KfU862Vw4WtKEg.JPEG%2F1000012783.jpg.jpg%3Ftype%3Dw1500_60_sharpen"
                            ]
                        ),
                        ReviewModel(
                            reviewUID: "review_444",
                            reviewText: "시설이 깨끗해서 그런지 이용하능 사람이 많아요. 주문 실수를 햇는데 카운터에서 잘 응대해주셔서 좋았습니다. 게임 관리가 잘 되어 있네요 :)",
                            userUID: "user_조랭떡2",
                            userName: "조랭떡2",
                            visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 26))!,
                            usefulCount: 38,
                            images: [
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MjlfMTUy%2FMDAxNzUzNzc3NzU3OTE2.63rV-rTW8vNyYdsZy-GtD1t1RsUt1F_Vn0YS6Dyiicsg.dLNWyVDNkID__YxahQ0XIbmLCzJvqLSJ2WSTOBTvYx0g.JPEG%2F16DF43B3-63D4-469D-9824-F7F8757907B8.jpeg%3Ftype%3Dw1500_60_sharpen",
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MjlfMTU4%2FMDAxNzUzNzc3NzU3OTY5.otBTiFpyIQL8rEfkB0zmwKCVvouBsnOZRE_7bIl0giwg.ydlj6CjRN5lTv-Rb75SxiL8wp114_kCruJVmyEK4b4gg.JPEG%2F3A5BA71A-1424-4C47-AEF0-02511E05923E.jpeg%3Ftype%3Dw1500_60_sharpen"
                            ]
                        ),
                        ReviewModel(
                            reviewUID: "review_1111",
                            reviewText: "쾌적한 시설이 정말 좋아요! 음식 가성비도 좋고 맛있ㅇ요 다음에 또 방문할게요",
                            userUID: "user_chem01",
                            userName: "chemchem",
                            visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 28))!,
                            usefulCount: 412,
                            images: [
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MjhfMjIx%2FMDAxNzUzNjgxODI2OTM1.82OyhHHfvOKoiZlgZL3p-rLDbpyYVEtB30mOzS0VD_Ug.l0vLTn_PwYuIYIuIwZlJYBEWAuFrrmlJ3tGF1l6uRNUg.JPEG%2F20250728_144824.jpg.jpg%3Ftype%3Dw1500_60_sharpen",
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MjhfMTE2%2FMDAxNzUzNjgxODI3NTM1.KEOUA9YnJNzJd3CxNMrlHk3x0QmPLHLCSl1z3hSQa9gg.VBow8M67z9HW9DCmtHJSvJ63ref7N6gq76yQSI1a-DIg.JPEG%2F20250728_144828.jpg.jpg%3Ftype%3Dw1500_60_sharpen"
                            ]
                        )
                    ],
                    totalStarCount: 3209,
                    totalBookmarkCount: 212,
                    isBookmarkedLocally: false
                ),
            ],
            thumbnailIamgeURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20150901_184%2F14410455912147SBYx_JPEG%2F13491247_0.jpg"
        ),
        PlanModel(
            planUID: "plan_2",
            planTitle: "hoka, 한빛이랑 저녁",
            planCreatorUID: "user_2",
            meetingDate: Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 26))!,
            meetingAddress: AddressModel(
                addressUID: "address_2",
                addressTitle: "을지로입구역",
                addressLat: 37.564699,
                addressLon: 126.981666,
                sido: "서울특별시",
                gungu: "중구",
                dong: "남대문로 81",
                fullAddress: "서울특별시 중구 남대문로 81 본점 7층"
            ),
            partnerType: PartnerType.friend,
            activityType: ActivityType.shopping,
            appointmentTimeType: AppointmentTimeType.allDay,
            visitRoutes: [
                RouteModel(
                    routeUID: "route_1",
                    routeType: "쇼핑", //소상공인 소분류로하나? 뭐로가지?
                    routeTitle: "호카 롯데백화점 본점",
                    routeMemo: "여기서 호카 빅사이즈 300넘는거 구매",
                    address: AddressModel(
                        addressUID: "address_2002",
                        addressTitle: "호카 롯데백화점 본점",
                        addressLat: 37.564699,
                        addressLon: 126.981666,
                        sido: "서울특별시",
                        gungu: "중구",
                        dong: "남대문로 81",
                        fullAddress: "서울특별시 중구 남대문로 81 본점 7층"
                    ),
                    thumbNailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20220927_160%2F1664267007062e6wq7_PNG%2F%25C8%25A3%25C4%25AB_%25B7%25CE%25B0%25ED.png",
                    images: [
                        "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20220927_160%2F1664267007062e6wq7_PNG%2F%25C8%25A3%25C4%25AB_%25B7%25CE%25B0%25ED.png",
                        "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20220927_101%2F1664267003216LEUCr_JPEG%2F%25C8%25A3%25C4%25AB_%25B7%25D4%25B5%25A5%25B8%25ED%25B5%25BF%25C1%25A1_1.jpg"
                    ],
                    workingTimes: [
                        WorkingTimeModel(dayTitle: "월", open: "1030", close: "2000"),
                        WorkingTimeModel(dayTitle: "화", open: "1030", close: "2000"),
                        WorkingTimeModel(dayTitle: "수", open: "1030", close: "2000"),
                        WorkingTimeModel(dayTitle: "목", open: "1030", close: "2000"),
                        WorkingTimeModel(dayTitle: "금", open: "1030", close: "2000"),
                        WorkingTimeModel(dayTitle: "토", open: "1030", close: "2000"),
                        WorkingTimeModel(dayTitle: "일", open: "1030", close: "2000")
                    ],
                    reviews: [
                        ReviewModel(
                            reviewUID: "review_101",
                            reviewText: "불친절의 끝판왕... 명품 매장인줄? 아니 명품 매장도 이정도는 아닐것같다는.. 인사는 뭐 당연히 없고 그건 이해하는데 뭐뭐 물어봐도 아니요 없어요 말 길게 못하는 병에 걸린건지?",
                            userUID: "user_123",
                            userName: "남자사람55",
                            visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 30))!,
                            usefulCount: 100,
                            images: [
                                
                            ]
                        ),
                        ReviewModel(
                            reviewUID: "review_1044",
                            reviewText: "가볍고 발이 편해요. 내구성은 좀 떨어져요",
                            userUID: "user_431",
                            userName: "petitlapin",
                            visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 29))!,
                            usefulCount: 23,
                            images: [
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA2MzBfMTAg%2FMDAxNzUxMjMzOTU4OTE2.f8F3je1ybWqyQbYyKNSRPIXKcGvcEnS-HJ3_dd92uNwg.GWNkL0xOjaXYi4nTaVbkJB7PZCX1O5n7RbqK50zlNfEg.JPEG%2F20250629_173935.jpg.jpg%3Ftype%3Dw1500_60_sharpen"
                            ]
                        ),
                        ReviewModel(
                            reviewUID: "review_1244",
                            reviewText: "이제 여름이라 발에 땀이 많이차서 샌들이 필요하더라고요. 인터넷에서 여름 샌들을 찾아봤는데 호카 호파라 제품이 직장에서 신기에도 괜찮아 보이고 착화감도 좋다고해서 마음에 들어요",
                            userUID: "user_40192",
                            userName: "25 2월21일",
                            visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 10))!,
                            usefulCount: 1,
                            images: [
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA2MTBfMjYg%2FMDAxNzQ5NTU3MjcyMjY2.mnHqpP_xkl9DMCVEpYBq0DimCK0d0QQubHYU7RPB-pMg.9XWhy2udGcg8e4FMHY4JCMEmpx-czB79-34uE9Jt7ykg.JPEG%2F1000035986.jpg.jpg%3Ftype%3Dw1500_60_sharpen"
                            ]
                        )
                    ],
                    totalStarCount: 22,
                    totalBookmarkCount: 101,
                    isBookmarkedLocally: false
                ),
                RouteModel(
                    routeUID: "route_21449",
                    routeType: "레스토랑", //소상공인 소분류로하나? 뭐로가지?
                    routeTitle: "멜팅소울 롯데백화점 본점",
                    routeMemo: "4만원정도 나올듯? 잠봉뵈르 2개, 고구마칩1, 제로 콜라 2개",
                    address: AddressModel(
                        addressUID: "address_3011",
                        addressTitle: "멜팅소울 롯데백화점 본점",
                        addressLat: 37.564799,
                        addressLon: 126.981112,
                        sido: "서울특별시",
                        gungu: "중구",
                        dong: "남대문로 81",
                        fullAddress: "서울특별시 중구 남대문로 81 롯데백화점 본점 지하 1층"
                    ),
                    thumbNailImageURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240514_119%2F1715668910247St53v_JPEG%2F%25C7%25CA%25B8%25E1%25C6%25C3%25BC%25D2%25BF%25EF%25C7%25C1%25B7%25CE1_%25B4%25EB%25C1%25F6_1_%25B4%25EB%25C1%25F6_1.jpg",
                    images: [
                        "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240514_119%2F1715668910247St53v_JPEG%2F%25C7%25CA%25B8%25E1%25C6%25C3%25BC%25D2%25BF%25EF%25C7%25C1%25B7%25CE1_%25B4%25EB%25C1%25F6_1_%25B4%25EB%25C1%25F6_1.jpg",
                        "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240516_183%2F1715821784338o0A79_JPEG%2F%25C7%25CA%25B8%25E1%25C6%25C3%25BC%25D2%25BF%25EF%25C7%25C1%25B7%25CEweb1_%25B4%25EB%25C1%25F6_1_%25B4%25EB%25C1%25F6_1.jpg",
                        "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20240516_82%2F1715821791592dDudc_JPEG%2FKakaoTalk_20240313_172423642.jpg"
                    ],
                    workingTimes: [
                        WorkingTimeModel(dayTitle: "월", open: "1030", close: "2000", lastOrder: "19:30"),
                        WorkingTimeModel(dayTitle: "화", open: "1030", close: "2000", lastOrder: "19:30"),
                        WorkingTimeModel(dayTitle: "수", open: "1030", close: "2000", lastOrder: "19:30"),
                        WorkingTimeModel(dayTitle: "목", open: "1030", close: "2000", lastOrder: "19:30"),
                        WorkingTimeModel(dayTitle: "금", open: "1030", close: "2000", lastOrder: "19:30"),
                        WorkingTimeModel(dayTitle: "토", open: "1030", close: "2000", lastOrder: "19:30"),
                        WorkingTimeModel(dayTitle: "일", open: "1030", close: "2000", lastOrder: "19:30")
                    ],
                    reviews: [
                        ReviewModel(
                            reviewUID: "review_2111111",
                            reviewText: "을지로 롯배 ㄱ맛집 멜팅소울!! 대회에서 우승한 버거 비주얼도 맛도 최고입니다!! 치즈완전 가득해서 맘에 들었어요!!",
                            userUID: "user_돼지교슈",
                            userName: "안돼지교수님",
                            visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 25))!,
                            usefulCount: 92,
                            images: [
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MjVfNDEg%2FMDAxNzUzNDM5MTcxNDc4.qY1jjwSPxbo4CNkosp6fXsjDLYkn6gX8gKvQfQrvng4g.bXfIS0mFXMynHvp1eByHCTu1yZsH8EA5Lanf5kIqdr4g.JPEG%2F20250725_184425.jpg.jpg%3Ftype%3Dw1500_60_sharpen",
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MjVfMjIw%2FMDAxNzUzNDM5MTgwNzcx.FwoBXkwbiFhnefBqkOob3vAWtlviQa1VJMDfHDSmWeog.1JV9s7Z5LMhablziDkl3cvZzF0JEvW0BHv_D3AIO4fkg.JPEG%2F20250725_184239.jpg.jpg%3Ftype%3Dw1500_60_sharpen"
                            ]
                        ),
                        ReviewModel(
                            reviewUID: "review_4103",
                            reviewText: "정말 먹고 싶었던 버거집.",
                            userUID: "user_쿠우",
                            userName: "ㅏㅐㅐ6190",
                            visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 6))!,
                            usefulCount: 2,
                            images: [
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MTNfMjY3%2FMDAxNzUyNDEwOTQ4OTgx.oIvf6ZJcvtjyFiRyeV8ByJwcoPlxrPNip2otdPNOplog.NvVttSkb0Q4K9IJvpyJ1vQDqibT7IR5syVgLUFDOBxcg.JPEG%2F1000015877.jpg.jpg%3Ftype%3Dw1500_60_sharpen",
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MTNfMjc1%2FMDAxNzUyNDEwOTQ5Nzk3.z6TT4h0MQOyMyq7q9-lfIMM0x7tVDj4Qvd1xe3sLEzgg.3IiAkc_BDaAeEngGuf5c8ar4x-6hbIGZKeKoNbLNDosg.JPEG%2F1000015876.jpg.jpg%3Ftype%3Dw1500_60_sharpen",
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MTNfMjM2%2FMDAxNzUyNDEwOTUwNDkz.9xD4ujeLarMSIHOs3WQ9XoO3HebdifBdfh_fQBLkn_8g.3os8mcph6Yy5sZ8aHn1TXoxYWiHubu-7AKluJPF_OsIg.JPEG%2F1000015875.jpg.jpg%3Ftype%3Dw1500_60_sharpen"
                            ]
                        ),
                        ReviewModel(
                            reviewUID: "review_88888",
                            reviewText: "근처에 일있다가 상받은 버거가 있다고해서 방문했어요! 시그니처인 멜팅옐로우 치즈버거랑 잠봉버거 먹었는데 둘다조맛이었습니다! 멜팅 치즈버거가 과하다고 하는 리뷰도 있었지만 너무 좋았어요",
                            userUID: "user_호빵",
                            userName: "팥듬뿍호빵",
                            visitDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 16))!,
                            usefulCount: 22,
                            images: [
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MTlfMjUz%2FMDAxNzUyODk1NjM1Mjg5.tf2u3B8543S_UpV4Q2TI6s-heqzttvvznwGRlXgFC5Ag.Tro4_ef3iv5dcMUzVBXTXG7GKUibFkRv76Sm5MEQvNYg.JPEG%2F1000028745.jpg.jpg%3Ftype%3Dw1500_60_sharpen",
                                "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyNTA3MTlfMjY4%2FMDAxNzUyODk1NjM1NDA1.piSC09-fS6ClOG6Eh82Wcw8_fajhEjPWivqISm-QnIMg.aKNL4H9gAFBg1kdyQ3ertULdkIaGrc6P51dt_ilF9_8g.JPEG%2F1000028747.jpg.jpg%3Ftype%3Dw1500_60_sharpen"
                            ]
                        )
                    ],
                    totalStarCount: 22,
                    totalBookmarkCount: 1,
                    isBookmarkedLocally: false
                )
            ],
            thumbnailIamgeURL: "https://search.pstatic.net/common/?src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20150901_184%2F14410455912147SBYx_JPEG%2F13491247_0.jpg"
        )
    ]
    
   
}
