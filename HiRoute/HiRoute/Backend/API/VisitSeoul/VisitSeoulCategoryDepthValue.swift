//
//  VisitSeoulCategoryDepthValue.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//

struct VisitSeoulCategoryDepthValue: Decodable {
    let values: [String]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let array = try? container.decode([String].self) {
            values = array
            return
        }
        if let string = try? container.decode(String.self) {
            values = string
                .split(separator: ">")
                .map { String($0) }
            return
        }
        values = []
    }

    var joinedText: String {
        values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " > ")
    }

    var leafText: String? {
        values.last?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
