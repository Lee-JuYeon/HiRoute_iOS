//
//  DoneTextField.swift
//  HiRoute
//
//  Created by Jupond on 2/6/26.
//
import SwiftUI

struct DoneTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let onCommit: () -> Void
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.returnKeyType = .done  // Done 버튼
        textField.delegate = context.coordinator
        
        textField.contentVerticalAlignment = .center
        textField.borderStyle = .none  // 기본 보더 제거
        textField.font = UIFont.systemFont(ofSize: 16) // 폰트 크기 조정
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        let parent: DoneTextField
        
        init(_ parent: DoneTextField) {
            self.parent = parent
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.onCommit()
            textField.resignFirstResponder()
            return true
        }
    }
}
