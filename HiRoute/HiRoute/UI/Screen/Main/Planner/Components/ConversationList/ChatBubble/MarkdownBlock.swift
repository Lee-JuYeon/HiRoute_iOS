//
//  MarkdownBlock.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

/// 마크다운 블록 단위 (헤더/리스트/코드블록/단락)
enum MarkdownBlock: Hashable {
    case h1(String)
    case h2(String)
    case h3(String)
    case listItem(String)
    case code(String)
    case paragraph(String)
}
