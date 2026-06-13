//
//  ChatSanitizer.swift
//  HiRoute
//
//  Created by Claude on 5/27/26.
//
//  [2026-05-27 Phase C.5+C.6] 채팅 입력 안전 전처리.
//  WHY: 자체 모델 전까지 Gemini/ChatGPT 사용 → 사용자가 PII 적으면 외부로 leak.
//  + Prompt injection 패턴(system 프롬프트 유출, 페르소나 변경 시도) 차단.
//

import Foundation

enum ChatSanitizer {

    /// 입력 메시지를 외부 LLM에 보내기 전 안전 처리.
    /// - PII 패턴 마스킹 (전화/주민번호/카드/이메일)
    /// - prompt injection 시도 키워드 제거
    /// - 길이 제한 (500자)
    static func sanitizeForLLM(_ raw: String) -> String {
        var s = raw
        s = maskPII(s)
        s = stripInjectionAttempts(s)
        if s.count > 500 {
            s = String(s.prefix(500)) + "…"
        }
        return s
    }

    /// 로컬 표시·저장용 — PII 마스킹만 (사용자가 본인 메시지에서 자기 정보는 봐도 됨).
    /// 단 저장 시 외부 leak 방지 차원에서 PII 마스킹된 ver만 보관 권장.
    static func maskPIIForDisplay(_ raw: String) -> String {
        maskPII(raw)
    }

    // MARK: - PII

    /// 한국·일본 PII 패턴 정규식.
    private static let piiPatterns: [(NSRegularExpression, String)] = {
        let patterns: [(String, String)] = [
            // 한국 휴대폰 010-XXXX-XXXX, 010 XXXX XXXX, 01012345678
            ("01[016789][-\\s]?\\d{3,4}[-\\s]?\\d{4}", "[전화번호]"),
            // 일본 휴대폰 070/080/090-XXXX-XXXX
            ("0[789]0[-\\s]?\\d{4}[-\\s]?\\d{4}", "[電話番号]"),
            // 일반 일본 번호 0X-XXXX-XXXX
            ("0\\d{1,3}[-\\s]?\\d{2,4}[-\\s]?\\d{4}", "[電話番号]"),
            // 주민등록번호 XXXXXX-XXXXXXX
            ("\\b\\d{6}[-]\\d{7}\\b", "[주민번호]"),
            // 일본 My Number 12자리 (단순 12연속 숫자는 false positive 위험)
            ("\\b\\d{4}\\s?\\d{4}\\s?\\d{4}\\b", "[マイナンバー]"),
            // 카드번호 (4-4-4-4 패턴)
            ("\\b\\d{4}[-\\s]?\\d{4}[-\\s]?\\d{4}[-\\s]?\\d{4}\\b", "[카드번호]"),
            // 이메일 (선택 — 본인 이메일 입력 시 차단할지 의견 갈림. 일단 마스킹)
            ("[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", "[이메일]"),
        ]
        return patterns.compactMap { (pattern, replacement) in
            (try? NSRegularExpression(pattern: pattern)).map { ($0, replacement) }
        }
    }()

    private static func maskPII(_ raw: String) -> String {
        var s = raw
        for (regex, replacement) in piiPatterns {
            let range = NSRange(s.startIndex..., in: s)
            s = regex.stringByReplacingMatches(in: s, range: range, withTemplate: replacement)
        }
        return s
    }

    // MARK: - Prompt Injection

    /// LLM 시스템 프롬프트 무력화 시도 키워드 제거.
    /// 단순 키워드 매칭 — 100% 차단은 아님. 2-stage classifier가 정답.
    private static let injectionPatterns: [String] = [
        "ignore previous", "ignore above", "disregard previous", "disregard above",
        "이전 지시 무시", "위 지시 무시", "前の指示", "上の指示",
        "###\\s*system", "###\\s*instruction", "###\\s*assistant",
        "you are now", "act as", "pretend you are",
        "당신은 이제", "이제부터 당신은",
        "あなたは", "今からあなたは",
    ]

    private static let injectionRegexes: [NSRegularExpression] = {
        injectionPatterns.compactMap {
            try? NSRegularExpression(pattern: $0, options: [.caseInsensitive])
        }
    }()

    private static func stripInjectionAttempts(_ raw: String) -> String {
        var s = raw
        for regex in injectionRegexes {
            let range = NSRange(s.startIndex..., in: s)
            s = regex.stringByReplacingMatches(in: s, range: range, withTemplate: "[차단된 지시]")
        }
        return s
    }
}
