//
//  VisitSeoulMultiLangListValue.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//

struct VisitSeoulMultiLangListValue: Decodable {
    let rawValue: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            rawValue = string
            return
        }
        if let array = try? container.decode([VisitSeoulMultiLangItemDTO].self) {
            rawValue = array.map { "\($0.langCodeId):\($0.cid)" }.joined(separator: ",")
            return
        }
        rawValue = ""
    }
}
