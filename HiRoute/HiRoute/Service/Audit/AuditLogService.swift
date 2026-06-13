//
//  AuditLogService.swift
//  HiRoute
//
//  Created by Claude on 5/26/26.
//
//  [2026-05-26 Phase 3] 데이터 삭제 감사 로그.
//  Why: chatHistory wipe 사고(8건 손실, 복구 불가)를 계기로 도입.
//   - 대량 삭제 시 디스크에 한 줄 기록 → 다음 앱 실행/RecoveryView에서 사용자 인지 가능
//   - DAO의 의도치 않은 삭제 패턴을 사후 감지
//

import Foundation

/// 감사 이벤트 한 건.
struct AuditEvent: Codable {
    enum Kind: String, Codable {
        case bulkChatDeletion
        case bulkPlanDeletion
        case bulkFileDeletion
    }
    let kind: Kind
    let scheduleUID: String?
    let count: Int
    let createdAt: Date
}

/// 디스크 기반 단순 감사 로거 (JSON Lines, append-only).
/// 파일 위치: Documents/audit_log.jsonl
/// 보존: 최근 100개만 (rotate). 그 이상이면 oldest부터 drop.
final class AuditLogService {
    static let shared = AuditLogService()

    private let queue = DispatchQueue(label: "com.nunulala.audit", qos: .utility)
    private let fileName = "audit_log.jsonl"
    private let maxEntries = 100

    private var fileURL: URL? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return dir.appendingPathComponent(fileName)
    }

    private init() {}

    /// 대량 채팅 삭제(≥3건) 발생 시 호출. DAO에서 invoke.
    func logBulkChatDeletion(scheduleUID: String, deletedCount: Int) {
        let event = AuditEvent(kind: .bulkChatDeletion, scheduleUID: scheduleUID, count: deletedCount, createdAt: Date())
        append(event)
    }

    func logBulkPlanDeletion(scheduleUID: String, deletedCount: Int) {
        let event = AuditEvent(kind: .bulkPlanDeletion, scheduleUID: scheduleUID, count: deletedCount, createdAt: Date())
        append(event)
    }

    /// 최근 이벤트 (최신순). RecoveryView가 사용자에게 표시.
    func recentEvents(limit: Int = 20) -> [AuditEvent] {
        let all = readAll()
        return Array(all.suffix(limit).reversed())
    }

    func clear() {
        guard let url = fileURL else { return }
        queue.sync {
            try? FileManager.default.removeItem(at: url)
        }
    }

    // MARK: - Internals

    private func append(_ event: AuditEvent) {
        queue.async { [weak self] in
            guard let self = self else { return }
            var all = self.readAll()
            all.append(event)
            // rotate
            if all.count > self.maxEntries {
                all = Array(all.suffix(self.maxEntries))
            }
            self.writeAll(all)
            print("AuditLogService, append // \(event.kind.rawValue) count=\(event.count) schedule=\(event.scheduleUID ?? "-")")
        }
    }

    private func readAll() -> [AuditEvent] {
        guard let url = fileURL, FileManager.default.fileExists(atPath: url.path) else { return [] }
        guard let data = try? Data(contentsOf: url),
              let text = String(data: data, encoding: .utf8) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return text.split(separator: "\n").compactMap { line in
            guard let lineData = line.data(using: .utf8) else { return nil }
            return try? decoder.decode(AuditEvent.self, from: lineData)
        }
    }

    private func writeAll(_ events: [AuditEvent]) {
        guard let url = fileURL else { return }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let lines = events.compactMap { event -> String? in
            guard let data = try? encoder.encode(event),
                  let str = String(data: data, encoding: .utf8) else { return nil }
            return str
        }
        let body = lines.joined(separator: "\n")
        try? body.write(to: url, atomically: true, encoding: .utf8)
    }
}
