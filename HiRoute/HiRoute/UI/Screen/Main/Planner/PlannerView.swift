//
//  PlannerView.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

import SwiftUI

/*
 ChatGPT webUI 스타일 사이드바 (push 방식)
 - 채팅 == 일정. 모든 상태는 currentSchedule 기반.
 - 레이아웃은 범용 CustomSidebarView가 담당
 - 사이드바 컨텐츠는 ChatSidebarView (일정 목록)
 - 채팅뷰 좌상단 화살표 아이콘(→| 펼침 / |← 접기)으로 토글
 */
struct PlannerView: View {
    @EnvironmentObject private var chatVM: ChatVM
    @EnvironmentObject private var placeVM: PlaceVM
    @EnvironmentObject private var scheduleVM: ScheduleVM
    @EnvironmentObject private var navigationVM: NavigationVM
    @State private var isSidebarOpen: Bool = false
    @State private var showTitleEditor: Bool = false
    @State private var showDateEditor: Bool = false
    @State private var showFullscreenMap: Bool = false
    /// 채팅 아래로 스크롤 시 topBar+storyBar 숨김(탁 트인 화면). 위로 스크롤/최상단이면 복귀.
    @State private var isTopChromeHidden: Bool = false

    private let sidebarWidth: CGFloat = 280
    private let sidebarAnimation: Animation = .easeInOut(duration: 0.22)

    /// d_day 미정 안내 문구.
    private static let undecidedDDayText = "여행 날짜가 아직 정해지지 않았어요"

    var body: some View {
        CustomSidebarView(
            isOpen: $isSidebarOpen,
            sidebarWidth: sidebarWidth,
            edge: .leading,
            sidebar: {
                ChatSidebarView(
                    schedules: chatVM.schedules,
                    currentScheduleUID: chatVM.currentSchedule?.uid,
                    onSelect: { chatVM.selectSchedule(uid: $0) },
                    onDelete: { chatVM.deleteSchedule(uid: $0) }
                )
            },
            main: {
                mainColumn
            }
        )
        .background(Color.getColour(.background_white))
        .onAppear {
            // PlaceView에서 일정에 장소 추가 후 돌아온 경우 DB 재조회 → 스토리바 갱신
            chatVM.refresh()
        }
        .topSheet(isOpen: $showTitleEditor) {
            ScheduleTitleEditSheet(
                initialTitle: chatVM.currentSchedule?.title ?? "",
                onSave: { newTitle in
                    chatVM.updateScheduleTitle(newTitle)
                    showTitleEditor = false
                },
                onCancel: { showTitleEditor = false }
            )
        }
        .topSheet(isOpen: $showDateEditor) {
            ScheduleDDayEditSheet(
                initialDate: chatVM.currentSchedule?.d_day ?? Date(),
                onSave: { newDate in
                    chatVM.updateScheduleDDay(newDate)
                    showDateEditor = false
                },
                onCancel: { showDateEditor = false }
            )
        }
        .fullScreenCover(isPresented: $showFullscreenMap) {
            ScheduleFullscreenMapView(
                plans: chatVM.currentSchedule?.planList ?? [],
                onClose: { showFullscreenMap = false }
            )
        }
    }

    // MARK: - Main Column

    private var mainColumn: some View {
        VStack(spacing: 0) {
            if !isTopChromeHidden {
                topBar

                Divider()
                    .background(Color.getColour(.line_alternative))

                storyBar

                Divider()
                    .background(Color.getColour(.line_alternative))
            }

            content

            ChatTextField(
                text: $chatVM.inputText,
                isStreaming: chatVM.isStreaming,
                onSend: { chatVM.send() },
                onCancel: { chatVM.cancelStreaming() }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.getColour(.background_white))
        // 일정 전환 시 상단 chrome 복귀(새 대화는 항상 보이게).
        .onChange(of: chatVM.currentSchedule?.uid) { _ in
            isTopChromeHidden = false
        }
    }

    /// 일정에 추가된 plan이 있으면 그것들로, 없으면 추천 테마 스토리로.
    @ViewBuilder
    private var storyBar: some View {
        if let plans = chatVM.currentSchedule?.planList, !plans.isEmpty {
            PlanStoryBarView(
                plans: plans,
                dDay: chatVM.currentSchedule?.d_day,
                onSelect: { plan in openPlanDetail(plan) },
                onSelectMapShortcut: { showFullscreenMap = true }
            )
        } else {
            ThemeStoryListView(
                stories: ThemeStory.samples,
                onSelect: { story in chatVM.sendSuggestion(story.prompt) }
            )
        }
    }

    /// 일정이 없으면 첫 진입용 EmptyState, 있으면 chatHistory 복원해서 MessageList.
    /// (일정이 있고 메시지가 비어있어도 MessageList — 이전 채팅창 컨텍스트 유지)
    @ViewBuilder
    private var content: some View {
        if chatVM.currentSchedule == nil && !chatVM.isStreaming {
            EmptyStateView(onTapSuggestion: { suggestion in
                chatVM.sendSuggestion(suggestion)
            })
        } else {
            MessageListView(
                messages: chatVM.messages,
                streamingText: chatVM.streamingText,
                streamingPlaces: chatVM.streamingPlaces,
                isStreaming: chatVM.isStreaming,
                onSelectPlace: openPlaceDetail,
                onScroll: { hide in
                    guard hide != isTopChromeHidden else { return }
                    withAnimation(.easeInOut(duration: 0.22)) {
                        isTopChromeHidden = hide
                    }
                }
            )
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button(action: { toggleSidebar() }) {
                // 펼침: |←(접기), 접힘: →|(펼치기)
                Image(systemName: isSidebarOpen ? "arrow.left.to.line" : "arrow.right.to.line")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.getColour(.label_strong))
            }

            VStack(alignment: .leading, spacing: 2) {
                Button(action: { showTitleEditor = true }) {
                    Text(chatVM.currentSchedule?.title ?? "일정짜기")
                        .font(.headline)
                        .foregroundColor(Color.getColour(.label_strong))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .buttonStyle(.plain)

                Button(action: { showDateEditor = true }) {
                    ddayBadge
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Button(action: { chatVM.startNewSchedule() }) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.getColour(.label_strong))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.getColour(.background_white))
    }

    // MARK: - Helpers

    private func toggleSidebar() {
        withAnimation(sidebarAnimation) {
            isSidebarOpen.toggle()
        }
    }

    /// 상단바 D-day 뱃지 — PlanView와 동일한 `DdayCountingTextView`.
    /// 일정 없으면 미정 안내 회색 텍스트.
    @ViewBuilder
    private var ddayBadge: some View {
        if let dDay = chatVM.currentSchedule?.d_day {
            DdayCountingTextView(setDdayDate: dDay)
        } else {
            Text(Self.undecidedDDayText)
                .font(.caption2)
                .foregroundColor(Color.getColour(.label_assistive))
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }

    /// AI 채팅 카드 등 **일정에 아직 추가 안 된 장소** 진입 → `.OTHER` 모드.
    /// place를 임시 PlanModel로 감싸 currentPlanModel에 세팅 후 navigate.
    private func openPlaceDetail(_ place: PlaceModel) {
        placeVM.selectPlace(place)
        scheduleVM.currentPlanModel = PlanModel(
            uid: UUID().uuidString,
            index: 0,
            memo: "",
            placeModel: place,
            files: []
        )
        navigationVM.currentPlaceModeType = .OTHER
        navigationVM.navigateTo(setDestination: .place)
    }

    /// PlanStoryBar 셀 → 이미 일정에 추가된 plan 진입.
    /// **일정 탭 흐름 그대로 재현**:
    ///   1. ScheduleView.onClickScheduleModel: currentModeType + selectSchedule
    ///   2. PlanView.onAppear: currentPlaceModeType = .MY + startEditing
    ///   3. PlanBottomSection cell click: planEvent.selectPlan + navigateTo(.place)
    /// PlannerView는 PlanView를 건너뛰고 직접 .place로 가므로 (2)단계의 onAppear가
    /// 안 도는 점을 명시 세팅으로 보상.
    private func openPlanDetail(_ plan: PlanModel) {
        guard let schedule = chatVM.currentSchedule else { return }

        // (1) — ScheduleView.onClickScheduleModel과 동일.
        navigationVM.currentModeType = .UPDATE
        scheduleVM.selectSchedule(schedule)
        scheduleVM.startEditing(schedule)

        // (2) — PlanView.onAppear가 세팅하는 값.
        navigationVM.currentPlaceModeType = .MY

        // (3) — PlanBottomSection cell click과 동일 canonical API.
        scheduleVM.planEvent.selectPlan(plan)
        placeVM.selectPlace(plan.placeModel)

        navigationVM.navigateTo(setDestination: .place)
    }
}
