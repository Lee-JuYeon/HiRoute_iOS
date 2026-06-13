//
//  MarkdownInlineToken.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

/// 인라인 파싱 결과 조각 — 텍스트 + 적용 스타일
struct MarkdownInlineToken {
    let text: String
    let style: MarkdownInlineStyle
}
