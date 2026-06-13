//
//  MarkdownInlineParser.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

/// `**bold**`, `*italic*`, `` `code` `` 인라인 파서.
/// 중첩 미지원, 라인 단위로만 동작. iOS 14 호환 (외부 라이브러리 없음).
struct MarkdownInlineParser {

    static func parse(_ input: String) -> [MarkdownInlineToken] {
        var tokens: [MarkdownInlineToken] = []
        var buffer = ""
        let chars = Array(input)
        var i = 0

        func flushPlain() {
            if !buffer.isEmpty {
                tokens.append(MarkdownInlineToken(text: buffer, style: .plain))
                buffer = ""
            }
        }

        while i < chars.count {
            // ** bold **
            if i + 1 < chars.count, chars[i] == "*", chars[i + 1] == "*" {
                if let end = findEnd(in: chars, from: i + 2, delimiter: "**") {
                    flushPlain()
                    let inner = String(chars[(i + 2)..<end])
                    tokens.append(MarkdownInlineToken(text: inner, style: .bold))
                    i = end + 2
                    continue
                }
            }

            // * italic *
            if chars[i] == "*" {
                if let end = findEnd(in: chars, from: i + 1, delimiter: "*") {
                    flushPlain()
                    let inner = String(chars[(i + 1)..<end])
                    tokens.append(MarkdownInlineToken(text: inner, style: .italic))
                    i = end + 1
                    continue
                }
            }

            // ` code `
            if chars[i] == "`" {
                if let end = findEnd(in: chars, from: i + 1, delimiter: "`") {
                    flushPlain()
                    let inner = String(chars[(i + 1)..<end])
                    tokens.append(MarkdownInlineToken(text: inner, style: .code))
                    i = end + 1
                    continue
                }
            }

            buffer.append(chars[i])
            i += 1
        }

        flushPlain()
        if tokens.isEmpty {
            tokens.append(MarkdownInlineToken(text: input, style: .plain))
        }
        return tokens
    }

    private static func findEnd(in chars: [Character], from start: Int, delimiter: String) -> Int? {
        let delimChars = Array(delimiter)
        let delimLen = delimChars.count
        var i = start
        while i <= chars.count - delimLen {
            var matched = true
            for j in 0..<delimLen {
                if chars[i + j] != delimChars[j] {
                    matched = false
                    break
                }
            }
            if matched { return i }
            i += 1
        }
        return nil
    }
}
