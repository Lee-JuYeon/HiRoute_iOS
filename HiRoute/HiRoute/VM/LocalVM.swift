//
//  LocalVM.swift
//  HiRoute
//
//  Created by Jupond on 11/28/25.
//
import SwiftUI
import Combine
import CoreData

class LocalVM : ObservableObject {
    
    @Published var nationality : NationalityType {
        didSet {
            saveToUserDefaults()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let userDefaultsKey = "local"
    
    
    init() {
        // 앱 시작시 UserDefaults에서 로드
        let savedRawValue = UserDefaults.standard.string(forKey: "local")
                
        if let savedRawValue = savedRawValue,
           let savedType = NationalityType(rawValue: savedRawValue) {
            self.nationality = savedType
        } else {
            self.nationality = NationalityType.systemDefault
        }
                                
        print("LocalVM, init // Success : LocalVM 초기화 완료")
    }
    
    // MARK: - Public Methods
    func updateNationality(_ newType: NationalityType) {
        nationality = newType
        print("🌍 Nationality updated to: \(newType)")
    }
    
    func resetToSystemDefault() {
        nationality = NationalityType.systemDefault
    }
    
    // MARK: - Private Methods
    private func loadFromUserDefaults() -> NationalityType {
        guard let savedRawValue = userDefaults.string(forKey: userDefaultsKey),
              let savedType = NationalityType(rawValue: savedRawValue) else {
            return NationalityType.systemDefault
        }
        return savedType
    }
    
    private func saveToUserDefaults() {
        userDefaults.set(nationality.displayText, forKey: userDefaultsKey)
    }
    

    
    deinit {

        print("LocalVM, deinit // Success : 모든 리소스 해제 완료")
    }
       
}
