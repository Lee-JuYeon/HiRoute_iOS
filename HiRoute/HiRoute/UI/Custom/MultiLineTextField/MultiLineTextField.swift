//
//  MultiLineTextField.swift
//  HiRoute
//
//  Created by Jupond on 11/27/25.
//
import SwiftUI

struct MultiLineTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var onTextChanged: (String) -> Void
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.clear
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        
        // 플레이스홀더 설정
        if text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
        } else {
            textView.text = text
            textView.textColor = UIColor.label
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if text.isEmpty && uiView.textColor == UIColor.label {
            uiView.text = placeholder
            uiView.textColor = UIColor.lightGray
        } else if !text.isEmpty && uiView.text != text {
            uiView.text = text
            uiView.textColor = UIColor.label
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        let parent: MultiLineTextField
        
        init(_ parent: MultiLineTextField) {
            self.parent = parent
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == UIColor.lightGray {
                textView.text = ""
                textView.textColor = UIColor.label
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.lightGray
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.onTextChanged(textView.text)
        }
    }
}
