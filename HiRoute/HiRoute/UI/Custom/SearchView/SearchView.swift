//
//  SearchView.swift
//  HiRoute
//
//  Created by Jupond on 11/12/25.
//
import SwiftUI

struct SearchView: View {
    
    let onClickSearchButton: (String) -> Void
    let hint: String
    
    @Binding var searchText: String 
    
    var body: some View {
        HStack {
            // 검색 텍스트필드 + 버튼
            HStack {
                TextField(hint, text: $searchText, onCommit: {
                    onClickSearchButton(searchText)
                    hideKeyboard()
                })
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16))
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .foregroundColor(Color.primary) // 다크모드에서 글자 색상 자동 변경
                
                
                Button {
                    onClickSearchButton(searchText) // Binding이 아닌 값 전달
                    hideKeyboard() // 키보드 자동 종료 (아래 확장 참고)
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.secondary) // 아이콘 색상 자동 조절
                        .font(.system(size: 16))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                Color(UIColor.systemBackground) // 라이트/다크모드 자동 대응
            )
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
    }
}

// 키보드 닫기 유틸
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
