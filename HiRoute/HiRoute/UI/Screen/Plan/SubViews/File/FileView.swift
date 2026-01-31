//
//  MultiLineTextField.swift
//  HiRoute
//
//  Created by Jupond on 11/27/25.
//
import SwiftUI

struct FileView : View {
    
    @Binding private var addButtonVisible: Bool
    @Binding private var fileList: [FileModel]
    private let onFilesChanged: (([FileModel]) -> Void)?

    init(
        visibleAddButton: Binding<Bool>,
        fileList: Binding<[FileModel]>,
        onFilesChanged: (([FileModel]) -> Void)? = nil
    ) {
        self._addButtonVisible = visibleAddButton
        self._fileList = fileList
        self.onFilesChanged = onFilesChanged
    }
    
    @State private var presentDocumentPicker : Bool = false
    
    @ViewBuilder
    private func addFileButton() -> some View {
        Button {
            presentDocumentPicker = true
        } label: {
            HStack(alignment: .center, spacing: 0){
                Text("여행에 관한 문서를 추가해볼까요?")
                    .font(.system(size: 20))
                    .foregroundColor(Color.getColour(.background_white))
                    .fontWeight(.light)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image("icon_arrow")
                    .renderingMode(.template)
                    .resizable()
                    .scaleEffect(x: -1, y: 1)
                    .foregroundColor(Color.getColour(.background_white))
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 16, height: 16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .background(Color.getColour(.label_strong))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
    }
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading, spacing: 10){
            if addButtonVisible { addFileButton() }
                        
            FileListView(
                isPresentDocumentPicker: $presentDocumentPicker,
                fileList: $fileList,
                onFilesChanged: { updatedFiles in  // 변경시마다 호출
                    onFilesChanged?(updatedFiles)
                }
            )
        }
    }
}
