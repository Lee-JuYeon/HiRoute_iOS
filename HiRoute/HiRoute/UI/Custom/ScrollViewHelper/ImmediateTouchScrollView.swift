//
//  ImmediateTouchScrollView.swift
//  HiRoute
//
//  Created by Jupond on 3/7/26.
//

import SwiftUI

/// ScrollView 내부 버튼 터치 지연을 제거하는 래퍼
/// UIScrollView의 delaysContentTouches = false 설정
///
/// updateToken이 변경될 때만 rootView 갱신 — 외부 리렌더(MapCoordinator 등)에 의한
/// 불필요한 뷰 트리 교체를 방지하여 제스처 인식기 안정성 확보
private class OffsetGuardScrollView: UIScrollView {
    /// 유저가 직접 드래그하기 전까지 layoutSubviews에서 offset을 0으로 강제 보정
    var userHasInteracted = false

    override func layoutSubviews() {
        super.layoutSubviews()
        if !userHasInteracted && contentOffset.x != 0 {
            contentOffset = .zero
        }
    }
}

struct ImmediateTouchScrollView<Content: View>: UIViewRepresentable {
    let axis: Axis.Set
    let showsIndicators: Bool
    let updateToken: Int
    let content: () -> Content

    init(
        _ axis: Axis.Set = .horizontal,
        showsIndicators: Bool = false,
        updateToken: Int = 0,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self.showsIndicators = showsIndicators
        self.updateToken = updateToken
        self.content = content
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = OffsetGuardScrollView()
        scrollView.delegate = context.coordinator
        scrollView.delaysContentTouches = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsHorizontalScrollIndicator = axis == .horizontal ? showsIndicators : false
        scrollView.showsVerticalScrollIndicator = axis == .vertical ? showsIndicators : false
        scrollView.alwaysBounceHorizontal = axis == .horizontal
        scrollView.alwaysBounceVertical = axis == .vertical

        let hostView = UIHostingController(rootView: content())
        hostView.view.translatesAutoresizingMaskIntoConstraints = false
        hostView.view.backgroundColor = .clear
        scrollView.addSubview(hostView.view)

        NSLayoutConstraint.activate([
            hostView.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hostView.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            hostView.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostView.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        ])

        if axis == .horizontal {
            hostView.view.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor).isActive = true
        } else {
            hostView.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
        }

        context.coordinator.hostController = hostView
        context.coordinator.lastToken = updateToken
        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        guard context.coordinator.lastToken != updateToken else { return }
        context.coordinator.lastToken = updateToken
        context.coordinator.hostController?.rootView = content()
        if let guard_ = scrollView as? OffsetGuardScrollView {
            guard_.userHasInteracted = false
        }
        scrollView.setContentOffset(.zero, animated: false)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostController: UIHostingController<Content>?
        var lastToken: Int = -1

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            (scrollView as? OffsetGuardScrollView)?.userHasInteracted = true
        }
    }
}
