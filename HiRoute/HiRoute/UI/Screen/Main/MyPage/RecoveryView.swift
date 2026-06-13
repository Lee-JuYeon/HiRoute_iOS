//
//  RecoveryView.swift
//  HiRoute
//
//  Created by Claude on 5/26/26.
//
//  [2026-05-26 Phase 3] 최근 삭제 데이터 복구 화면.
//  Why: 코드 결함이나 사용자 실수로 삭제된 일정/채팅/장소/파일을 7일 grace 내에 복구.
//  How: ScheduleDAO.loadDeletedItems가 모든 soft-deleted row 조회, restore로 deletedAt 해제.
//

import SwiftUI

struct RecoveryView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var items: [ScheduleDAO.DeletedItem] = []
    @State private var auditEvents: [AuditEvent] = []
    @State private var isLoading: Bool = true
    @State private var restoringUID: String? = nil

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM/dd HH:mm"
        return f
    }()

    private let gracePeriod: TimeInterval = 7 * 24 * 60 * 60

    var body: some View {
        VStack(spacing: 0) {
            header

            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        if !auditEvents.isEmpty {
                            auditSection
                        }

                        if items.isEmpty {
                            emptyState
                        } else {
                            itemsSection
                        }

                        Spacer(minLength: 24)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .background(Color.getColour(.background_yellow_white))
        .onAppear(perform: load)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color.getColour(.label_strong))
            }

            Spacer()

            Text("최근 삭제 데이터")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color.getColour(.label_strong))

            Spacer()

            // 균형 맞춤
            Image(systemName: "chevron.left").opacity(0)
        }
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        .background(Color.getColour(.background_white))
    }

    // MARK: - Sections

    private var auditSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("최근 알림")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.getColour(.label_alternative))
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                ForEach(auditEvents.prefix(5), id: \.createdAt) { event in
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(auditEventTitle(event))
                                .font(.system(size: 14))
                                .foregroundColor(Color.getColour(.label_strong))
                            Text(dateFormatter.string(from: event.createdAt))
                                .font(.system(size: 12))
                                .foregroundColor(Color.getColour(.label_assistive))
                        }
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    Divider().padding(.leading, 16)
                }
            }
            .background(Color.getColour(.background_white))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
        }
    }

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("복구 가능 (\(items.count)건)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.getColour(.label_alternative))
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                ForEach(items, id: \.entityUID) { item in
                    itemRow(item)
                    if item.entityUID != items.last?.entityUID {
                        Divider().padding(.leading, 16)
                    }
                }
            }
            .background(Color.getColour(.background_white))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "trash.slash")
                .font(.system(size: 40))
                .foregroundColor(Color.getColour(.label_assistive))
            Text("최근 7일 이내 삭제된 데이터가 없습니다")
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_alternative))
            Text("삭제 후 7일이 지나면 자동으로 영구 삭제됩니다")
                .font(.system(size: 12))
                .foregroundColor(Color.getColour(.label_assistive))
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Row

    private func itemRow(_ item: ScheduleDAO.DeletedItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconName(for: item.kind))
                .font(.system(size: 18))
                .foregroundColor(Color.getColour(.label_normal))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(kindLabel(item.kind))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.getColour(.label_alternative))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.getColour(.background_alternative))
                        .clipShape(Capsule())

                    Text(item.scheduleTitle)
                        .font(.system(size: 13))
                        .foregroundColor(Color.getColour(.label_alternative))
                        .lineLimit(1)
                }

                Text(item.preview.isEmpty ? "(빈 내용)" : item.preview)
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_strong))
                    .lineLimit(2)

                Text(remainingTime(deletedAt: item.deletedAt))
                    .font(.system(size: 11))
                    .foregroundColor(Color.getColour(.label_assistive))
            }

            Spacer()

            Button(action: { restore(item) }) {
                if restoringUID == item.entityUID {
                    ProgressView()
                        .frame(width: 56, height: 28)
                } else {
                    Text("복구")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.getColour(.background_white))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.getColour(.label_strong))
                        .clipShape(Capsule())
                }
            }
            .disabled(restoringUID != nil)
        }
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
    }

    // MARK: - Helpers

    private func iconName(for kind: ScheduleDAO.DeletedItem.Kind) -> String {
        switch kind {
        case .schedule: return "calendar"
        case .chat:     return "bubble.left"
        case .plan:     return "mappin.circle"
        case .file:     return "doc"
        }
    }

    private func kindLabel(_ kind: ScheduleDAO.DeletedItem.Kind) -> String {
        switch kind {
        case .schedule: return "일정"
        case .chat:     return "채팅"
        case .plan:     return "장소"
        case .file:     return "파일"
        }
    }

    private func remainingTime(deletedAt: Date) -> String {
        let expiresAt = deletedAt.addingTimeInterval(gracePeriod)
        let remaining = expiresAt.timeIntervalSince(Date())
        if remaining <= 0 { return "곧 영구 삭제됨" }
        let days = Int(remaining / 86400)
        let hours = Int(remaining.truncatingRemainder(dividingBy: 86400) / 3600)
        if days > 0 { return "\(days)일 \(hours)시간 후 영구 삭제" }
        return "\(hours)시간 후 영구 삭제"
    }

    private func auditEventTitle(_ event: AuditEvent) -> String {
        switch event.kind {
        case .bulkChatDeletion:
            return "채팅 \(event.count)건 삭제 감지됨"
        case .bulkPlanDeletion:
            return "장소 \(event.count)건 삭제 감지됨"
        case .bulkFileDeletion:
            return "파일 \(event.count)건 삭제 감지됨"
        }
    }

    // MARK: - Actions

    private func load() {
        isLoading = true
        auditEvents = AuditLogService.shared.recentEvents()
        LocalDB.shared.loadDeletedItems { fetched in
            DispatchQueue.main.async {
                self.items = fetched
                self.isLoading = false
            }
        }
    }

    private func restore(_ item: ScheduleDAO.DeletedItem) {
        restoringUID = item.entityUID
        LocalDB.shared.restoreDeletedItem(item) { success in
            DispatchQueue.main.async {
                if success {
                    self.items.removeAll { $0.entityUID == item.entityUID }
                }
                self.restoringUID = nil
            }
        }
    }
}
