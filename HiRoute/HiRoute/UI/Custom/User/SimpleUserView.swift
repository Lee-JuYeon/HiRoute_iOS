//
//  SimpleUserView.swift
//  HiRoute
//
//  Created by Jupond on 7/1/25.
//
import SwiftUI

struct SimpleUserView : View {
    
    var selfieURL : String?
    var selfieSize : CGFloat? = 50
    var userName : String?
    var textSize : CGFloat? = 24
    init(
        setSelfieURL : String?,
        setUserName : String?,
        setSelfieSize : CGFloat? = 50,
        setTextSize : CGFloat? = 24
    ){
        self.selfieURL = setSelfieURL
        self.selfieSize = setSelfieSize
        self.userName = setUserName
        self.textSize = setTextSize
    }
    
    var body: some View {
        HStack(){
            SelfieView(
                imageURL: selfieURL ?? "",
                size: selfieSize ?? 24,
                placeholderIcon: "person.fill",
                backgroundColor: Color.green
            )
            
            Text(userName ?? "")
                .font(.system(size: textSize ?? 24, weight: .bold))
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
        }
    }
}
