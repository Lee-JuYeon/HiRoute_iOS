//
//  EventListModel.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import Foundation

enum NationalityType : String, Codable, CaseIterable {
    case KOREA = "한국어"
    case JAPAN = "日本語"
    case INDONESIA = "Bahasa Indonesia"
    case USA = "English"
    case MALAYSIA = "Bahasa Malaysia"
    case SINGAPORE = "English "
    case TAIWAN = "臺灣"
    
    var displayText: String {
        return self.rawValue
    }
    
    static var systemDefault: NationalityType {
        let locale = Locale.current
        let languageCode = locale.languageCode ?? ""
        let regionCode = locale.regionCode ?? ""
        
        // 언어 코드와 지역 코드 조합으로 판단
        switch (languageCode, regionCode) {
        case ("ko", _):  // 한국어
            return .KOREA
            
        case ("ja", _):  // 일본어
            return .JAPAN
            
        case ("id", _):  // 인도네시아어
            return .INDONESIA
            
        case ("ms", _):  // 말레이어
            return .MALAYSIA
            
        case ("zh", "TW"), ("zh", "HK"):  // 번체 중국어 (대만, 홍콩)
            return .TAIWAN
            
        case ("en", "SG"):  // 싱가포르 영어
            return .SINGAPORE
            
        case ("en", _):  // 기타 영어권
            return .USA
            
        default:  // 기본값
            return .USA
        }
    }
    
    var currencySymbol: String {
         switch self {
         case .KOREA:      return "₩"
         case .JAPAN:      return "¥"
         case .INDONESIA:  return "Rp"
         case .USA:        return "$"
         case .MALAYSIA:   return "RM"
         case .SINGAPORE:  return "S$"
         case .TAIWAN:     return "NT$"
         }
     }
     
     var dateFormat: String {
         switch self {
         case .KOREA:      return "yyyy년 M월 d일"
         case .JAPAN:      return "yyyy年M月d日"
         case .INDONESIA:  return "d MMMM yyyy"
         case .USA:        return "MMMM d, yyyy"
         case .MALAYSIA:   return "d MMMM yyyy"
         case .SINGAPORE:  return "d MMM yyyy"
         case .TAIWAN:     return "yyyy年M月d日"
         }
     }
       
}


