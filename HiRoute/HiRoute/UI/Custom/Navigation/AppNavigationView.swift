//
//  AppNavigationView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

/*
 독립 화면 전환 방식 (Group + switch)
 - 항상 1개 화면만 메모리에 존재 (이전 화면은 파괴)
 - NavigationVM.destination으로 화면 전환 제어
 - 데이터는 각 화면이 @EnvironmentObject VM에서 직접 읽음
 */

struct AppNavigationView: View {

    @EnvironmentObject private var navigationVM : NavigationVM
    @State private var showSecurityReloginSnackbar = false

    @EnvironmentObject private var audioPlayerVM: AudioPlayerVM

    var body: some View {
        VStack(spacing: 0) {
        MiniAudioPlayerView()
        Group {
            switch navigationVM.destination {
            case .splash:
                MainScreen()
//                SplashScreen()
//                GeoObjectARView()
            case .onBoarding:
                OnBoardingScreen()
            case .register:
                RegisterScreen()
            case .main:
                MainScreen()
            case .plan:
                PlanView()
            case .place:
                PlaceView()
            case .placeSearch:
                PlaceSearchView()
            case .searchRoute:
                SearchRouteView()
            case .pictureList:
                FullSizeImageListView()
            case .reviewWrite:
                ReviewWriteView()
            case .myReviews:
                MyReviewsView()
            case .myBookmarks:
                MyBookmarksView()
            case .myUsefuls:
                MyUsefulsView()
            }
       
        }
        .onReceive(NotificationCenter.default.publisher(for: .sessionExpired)) { _ in
            showSecurityReloginSnackbar = true
            navigationVM.navigateTo(setDestination: .onBoarding)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showSecurityReloginSnackbar = false
            }
        }
        .overlay(
            Group {
                if showSecurityReloginSnackbar {
                    VStack {
                        Spacer()
                        Text("보안이 업데이트 되어 다시 로그인이 필요합니다")
                            .font(.footnote)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(8)
                            .padding(.bottom, 50)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: showSecurityReloginSnackbar)
                }
            }
        )
        } // VStack
    }
}

/*
 ⏺ 시나리오: 유저 A가 여행 일정을 관리한다

   [Phase 1: 기본 CRUD]

   ① 생성 — "서울 벚꽃 여행" 일정 + 플랜 1개 (경복궁)
      → 201, plans 배열에 1개

   ② 생성 — "부산 해운대" 일정 (플랜 없이)
      → 201, plans 빈 배열

   ③ 생성 — "제주도 힐링" 일정
      → 201

   ④ 목록 조회
      → 3개, index_order 순서 확인

   ⑤ 상세 조회 — ①번 일정
      → plans 1개 + files 빈 배열

   ⑥ 수정 — ①번 제목 변경 + 플랜 추가 (북촌한옥마을)
      → plans 2개로 늘어남

   ⑦ 상세 재조회 — ①번
      → 수정된 제목 + plans 2개 확인

   [Phase 2: 순서 변경]
ㄹ
   ⑧ 순서 변경 — 제주도(0), 부산(1), 서울(2)
      → 200

   ⑨ 목록 조회
      → 제주도가 맨 위

   [Phase 3: 삭제]

   ⑩ 삭제 — 부산 일정
      → soft delete 메시지

   ⑪ 목록 조회
      → 2개만 (부산 사라짐)

   ⑫ 삭제된 일정 상세 조회
      → 404

   [Phase 4: 엣지 케이스]

   ⑬ 중복 생성 — ①번 uid 재사용
      → 409 CONFLICT

   ⑭ 존재하지 않는 일정 수정
      → 404

   ⑮ 인증 없이 접근
      → 401

   [Phase 5: 싱크]

   ⑯ 싱크 — last_sync_at을 과거로 설정, 변경사항 없음
      → server_changes에 현재 일정 2개 + deleted_on_server에 부산 uid

   ⑰ 싱크 — 새 일정 1개 created + 서울 일정 updated 포함
      → 서버 반영 확인

   ⑱ 목록 조회
      → 싱크로 추가된 일정 포함 3개

   [Phase 6: LWW 검증]

   ⑲ 수정 — 서울 일정에 과거 updated_at 전송
      → 서버 버전 유지 (LWW: 서버가 더 최신)

   ⑳ 상세 조회
      → ⑲의 변경이 적용 안 됐는지 확인

   [정리]

   ㉑ 전체 삭제 — 남은 일정 전부 DELETE
      → 깔끔하게 정리

   핵심 검증:
   - ①~⑦: CRUD 정상 동작
   - ⑧~⑨: 순서 변경 반영
   - ⑩~⑫: soft delete + 목록 필터링
   - ⑬~⑮: 에러 핸들링
   - ⑯~⑱: 싱크 프로토콜
   - ⑲~⑳: LWW 충돌 해결
 */
