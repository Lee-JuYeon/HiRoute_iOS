//
//  MarkdownTextView.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

import SwiftUI

/// iOS 14 호환 마크다운 렌더러.
/// 블록: H1~H3 (#), 리스트 (-, *), 코드블록 (```), 단락
/// 인라인: **bold**, *italic*, `inline code`
/// 외부 라이브러리 없이 Text concatenation 방식.
struct MarkdownTextView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(parseBlocks(text).enumerated()), id: \.offset) { _, block in
                renderBlock(block)
            }
        }
    }

    @ViewBuilder
    private func renderBlock(_ block: MarkdownBlock) -> some View {
        switch block {
        case .h1(let s):
            renderInline(s)
                .font(.title2.weight(.bold))
                .foregroundColor(Color.getColour(.label_strong))
        case .h2(let s):
            renderInline(s)
                .font(.title3.weight(.semibold))
                .foregroundColor(Color.getColour(.label_strong))
        case .h3(let s):
            renderInline(s)
                .font(.headline)
                .foregroundColor(Color.getColour(.label_strong))
        case .listItem(let s):
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("•")
                    .font(.subheadline)
                    .foregroundColor(Color.getColour(.label_neutral))
                renderInline(s)
                    .font(.subheadline)
                    .foregroundColor(Color.getColour(.label_normal))
                    .fixedSize(horizontal: false, vertical: true)
            }
        case .code(let s):
            Text(s)
                .font(.system(.callout, design: .monospaced))
                .foregroundColor(Color.getColour(.label_normal))
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.getColour(.background_alternative))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        case .paragraph(let s):
            renderInline(s)
                .font(.subheadline)
                .foregroundColor(Color.getColour(.label_normal))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Inline rendering (Text concatenation)

    private func renderInline(_ s: String) -> Text {
        let tokens = MarkdownInlineParser.parse(s)
        var result = Text("")
        var first = true
        for token in tokens {
            let segment: Text
            switch token.style {
            case .plain:
                segment = Text(token.text)
            case .bold:
                segment = Text(token.text).bold()
            case .italic:
                segment = Text(token.text).italic()
            case .code:
                segment = Text(token.text).font(.system(.body, design: .monospaced))
            }
            result = first ? segment : (result + segment)
            first = false
        }
        return result
    }

    // MARK: - Block parsing

    private func parseBlocks(_ text: String) -> [MarkdownBlock] {
        var blocks: [MarkdownBlock] = []
        var paragraphBuffer: [String] = []
        var codeBuffer: [String] = []
        var inCodeBlock = false

        func flushParagraph() {
            if !paragraphBuffer.isEmpty {
                blocks.append(.paragraph(paragraphBuffer.joined(separator: "\n")))
                paragraphBuffer.removeAll()
            }
        }

        let lines = text.components(separatedBy: "\n")
        for line in lines {
            if line.hasPrefix("```") {
                if inCodeBlock {
                    blocks.append(.code(codeBuffer.joined(separator: "\n")))
                    codeBuffer.removeAll()
                    inCodeBlock = false
                } else {
                    flushParagraph()
                    inCodeBlock = true
                }
                continue
            }

            if inCodeBlock {
                codeBuffer.append(line)
                continue
            }

            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty {
                flushParagraph()
                continue
            }

            if trimmed.hasPrefix("### ") {
                flushParagraph()
                blocks.append(.h3(String(trimmed.dropFirst(4))))
            } else if trimmed.hasPrefix("## ") {
                flushParagraph()
                blocks.append(.h2(String(trimmed.dropFirst(3))))
            } else if trimmed.hasPrefix("# ") {
                flushParagraph()
                blocks.append(.h1(String(trimmed.dropFirst(2))))
            } else if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") {
                flushParagraph()
                blocks.append(.listItem(String(trimmed.dropFirst(2))))
            } else {
                paragraphBuffer.append(line)
            }
        }

        if inCodeBlock {
            blocks.append(.code(codeBuffer.joined(separator: "\n")))
        }
        flushParagraph()

        return blocks
    }
}
