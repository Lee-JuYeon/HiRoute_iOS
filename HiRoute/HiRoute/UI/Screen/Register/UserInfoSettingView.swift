//
//  NicknameView.swift
//  HiRoute
//
//  Created by Jupond on 2/12/26.
//

import SwiftUI

struct UserInfoSettingView: View {

    @State private var nickname = ""
    @State private var selectedNationality: NationalityDTO = NationalityDTO(displayName: "🇯🇵 Japan", code: "JAPAN")
    @State private var tempNationality: NationalityDTO = NationalityDTO(displayName: "🇯🇵 Japan", code: "JAPAN")
    @State private var selectedGender: String = "male"
    @State private var selectedAge: Int? = nil
    @State private var tempAge: Int? = nil
    @State private var showNationalitySheet = false
    @State private var showAgeSheet = false
    @State private var isCreatingUser = false
    @State private var ageValidationMessage: String? = nil
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var naviVM : NavigationVM
    @EnvironmentObject private var userVM : UserVM
    // [2026-05-27 Phase A.10] PIPA 22조 — 만 14세 미만 가입 불가.
    // 일본 사용자 고려해 14~80 범위. 80+는 "선택 안함"으로 처리 (드물고 UI 정리).
    private let ages = Array(14...80)
    private let minimumAge = 14
    
    // 다크테마 색상
    private var backgroundColor: Color {
        colorScheme == .dark ?
        Color.getColour(.label_strong) : Color.getColour(.background_yellow_white)
    }
    
    private var labelColor: Color {
        colorScheme == .dark ?
        Color.getColour(.background_white) : Color.getColour(.label_strong)
    }
    
    private var textFieldBackground: Color {
        colorScheme == .dark ?
        Color.black : Color.getColour(.background_white)
    }
    
    var body: some View {
        ZStack {
        VStack(spacing: 20) {

            // 이름 (필수)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("이름")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(labelColor)
                    
                    Text("*")
                        .foregroundColor(.red)
                }
                
                TextField("이름을 설정해주세요", text: $nickname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .colorScheme(colorScheme)
            }
            
            // 국적 (필수)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("국적")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(labelColor)
                    
                    Text("*")
                        .foregroundColor(.red)
                }
                
                Button {
                    tempNationality = selectedNationality
                    showNationalitySheet = true
                } label: {
                    HStack {
                        Text(selectedNationality.displayName)
                            .font(.system(size: 16))
                            .foregroundColor(labelColor)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(textFieldBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            
            // 성별, 나이
            HStack {
                Text("성별")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(labelColor)

                CustomToggleView(
                    items: [
                        ToggleModel(key: "male", icon: "icon_male"),
                        ToggleModel(key: "female", icon: "icon_female")
                    ],
                    iconSize: 20,
                    selectedKey: $selectedGender
                )

                Spacer()

                Text("나이")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(labelColor)

                Button {
                    tempAge = selectedAge
                    showAgeSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedAge != nil ? "만 \(selectedAge!)세" : "필수 선택")
                            .font(.system(size: 16))
                            .foregroundColor(labelColor)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(textFieldBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }

            // [2026-05-27 Phase A.10] 연령 안내 + 14세 미만 차단 메시지.
            Text("만 14세 미만은 본 서비스에 가입할 수 없습니다 (개인정보보호법 제22조).")
                .font(.system(size: 12))
                .foregroundColor(Color.getColour(.label_alternative))

            if let msg = ageValidationMessage {
                Text(msg)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
            }

            Spacer()

            // 완료 버튼
            Button("완료") {
                // [2026-05-27 Phase A.10] 연령 검증.
                guard let age = selectedAge else {
                    ageValidationMessage = "나이를 선택해주세요."
                    return
                }
                guard age >= minimumAge else {
                    ageValidationMessage = "만 14세 미만은 가입할 수 없습니다."
                    return
                }
                ageValidationMessage = nil
                isCreatingUser = true
                userVM.createUser(
                    name: nickname,
                    nationality: selectedNationality.code,
                    gender: GenderType(rawValue: selectedGender) ?? .male,
                    age: age
                ) { _ in
                    isCreatingUser = false
                    naviVM.navigateTo(setDestination: .main)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                nickname.isEmpty || selectedAge == nil || isCreatingUser ? Color.gray :
                (colorScheme == .dark ? Color.white : Color.black)
            )
            .cornerRadius(8)
            .disabled(nickname.isEmpty || selectedAge == nil || isCreatingUser)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(backgroundColor)

        if isCreatingUser {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        }
        } // ZStack
        .bottomSheet(isOpen: $showNationalitySheet) {
            VStack(spacing: 0) {
                HStack {
                    Text("국적 선택")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    Button("완료") {
                        selectedNationality = tempNationality
                        showNationalitySheet = false
                    }
                    .font(.system(size: 16, weight: .medium))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

                Picker("국적 선택", selection: $tempNationality) {
                    ForEach(NationalityDTO.allNationalities, id: \.self) { nationality in
                        Text(nationality.displayName).tag(nationality)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 200)
            }
            .padding(.bottom, 20)
        }
        .bottomSheet(isOpen: $showAgeSheet) {
            VStack(spacing: 0) {
                HStack {
                    Text("나이 선택")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    Button("완료") {
                        selectedAge = tempAge
                        showAgeSheet = false
                    }
                    .font(.system(size: 16, weight: .medium))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

                // [2026-05-27 Phase A.10] 14세 미만 picker에 표시 안 함.
                Picker("나이 선택", selection: $tempAge) {
                    ForEach(ages, id: \.self) { age in
                        Text("만 \(age)세").tag(age as Int?)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 200)
            }
            .padding(.bottom, 20)
        }
    }
}
