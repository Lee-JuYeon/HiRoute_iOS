//
//  PlanOptionBar.swift
//  HiRoute
//
//  Created by Jupond on 1/25/26.
//

import SwiftUI

struct PlanOptionBar : View {
    
    let onBack : () -> Void
    let onSave : () -> Void
    let onEdit : () -> Void
    let getModeType : ModeType

    
    @ViewBuilder
    private func backButton() -> some View {
        ImageButton(imageURL : "icon_back",imageSize: 30) {
            onBack()
        }
    }
    
    @ViewBuilder
    private func editButton() -> some View {
        TextButton(
            text: "편집",
            textSize: 16,
            textColour: Color.blue
        ) {
            onEdit()
        }
    }
 
    @ViewBuilder
    private func saveButton() -> some View {
        TextButton(
            text: "저장",
            textSize: 16,
            textColour: Color.blue
        ) {
            onSave()
        }
    }
    
    var body: some View {
        HStack(){
            backButton()
            
            Spacer()
          
            switch getModeType {
            case .READ:
                editButton()
            case .CREATE:
                saveButton()
            case .UPDATE:
                saveButton()
            }
        }
        .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
       
    }
}
