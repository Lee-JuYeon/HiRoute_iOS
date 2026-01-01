//
//  MultiLineMemoView.swift
//  HiRoute
//
//  Created by Jupond on 11/29/25.
//
import SwiftUI

struct SheetTextFieldView: View {
    
    private var getToolBarTitle : String
    private var getCallBackCancel : () -> Void
    private var getCallBackSave : () -> Void
    private var getHint : String
    @Binding private var getText : String
    
    init(
        setHint : String,
        setText : Binding<String>,
        setToolBarTitle: String,
        callBackCancel: @escaping () -> Void,
        callBackSave: @escaping () -> Void,
    ) {
        self.getHint = setHint
        self._getText = setText
        self.getToolBarTitle = setToolBarTitle
        self.getCallBackCancel = callBackCancel
        self.getCallBackSave = callBackSave
    }
    
    

    @ViewBuilder
    private func customToolBar() -> some View {
        HStack {
            Button("취소") {
                getCallBackCancel()
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            .foregroundColor(.gray)
            
            Spacer()
            
            Text(getToolBarTitle)
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                .font(.headline)
            
            Spacer()
            
            Button("확인") {
                getCallBackSave()
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            .foregroundColor(.blue)
        }
    }
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.center, spacing: 0){
        
            customToolBar()
            
            TextField(getHint, text: $getText, onCommit: {
                getCallBackSave()
            })
            .font(.system(size: 16))
            .customElevation(.normal)
            .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
        }
    }
}
