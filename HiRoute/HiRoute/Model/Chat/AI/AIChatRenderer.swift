//
//  AIChatRenderer.swift
//  HiRoute
//
//  [2026-06-07] AI 턴 응답 → 말풍선 텍스트(markdown) + 첨부 장소 + (코스카드용)추천.
//  첨부 장소는 uid 중복 제거(같은 맛집이 여러 stop 근처일 수 있어 pageview ID 충돌 방지).
//
import Foundation

enum AIChatRenderer {
    struct Output {
        let text: String
        let places: [PlaceModel]
        let recommendation: AIRecommendation?
    }

    private static func dedup(_ places: [PlaceModel]) -> [PlaceModel] {
        var seen = Set<String>()
        return places.filter { seen.insert($0.uid).inserted }
    }

    static func render(_ r: AITurnResponse) -> Output {
        switch r.kind {
        case .rejected:
            return Output(text: r.message ?? "여행 관련 질문만 도와드릴 수 있어요! 🇰🇷", places: [], recommendation: nil)
        case .answer:
            return Output(text: r.text ?? "잘 모르겠어요. 다시 물어봐 주세요!", places: [], recommendation: nil)
        case .clarify:
            return Output(text: r.question ?? "조금만 더 알려주시면 딱 맞는 코스를 짜드릴게요!", places: [], recommendation: nil)
        case .nearPlace:
            let rs = r.restaurants ?? []
            let lines = rs.map { "- \($0.name) (\(String(format: "%.1f", $0.distKm))km)" }.joined(separator: "\n")
            let text = "**\(r.anchor ?? "근처")** 근처 맛집이에요!\n\(lines)"
            return Output(text: text, places: dedup(rs.map(AIChatPlaceFactory.fromRestaurant)), recommendation: nil)
        case .recommendation, .none:
            guard let rec = r.recommendation else {
                return Output(text: "추천을 준비하지 못했어요. 다시 시도해 주세요.", places: [], recommendation: nil)
            }
            var lines = ["## \(rec.theme)"]
            for s in rec.course.sorted(by: { $0.order < $1.order }) {
                lines.append("\(s.order). **\(s.name)** — \(s.reason)")
            }
            if !rec.diningNearCourse.isEmpty {
                lines.append("\n🍽️ 근처 맛집")
                for d in rec.diningNearCourse {
                    lines.append("- \(d.name) (\(d.nearStop) 근처 \(String(format: "%.1f", d.distKm))km)")
                }
            }
            let places = rec.course.compactMap(AIChatPlaceFactory.fromCourse)
                + rec.diningNearCourse.map(AIChatPlaceFactory.fromDining)
            return Output(text: lines.joined(separator: "\n"), places: dedup(places), recommendation: rec)
        }
    }
}
