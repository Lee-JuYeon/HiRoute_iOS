//
//  ScheduleCreateScreen.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct CustomTabView<Content: View>: View {
    
    enum CustomTabViewStyle {
        case BottomNavigation
        case TabView
    }
    
    struct CustomTabItemModel: Hashable {
        let image: String?
        let title: String
        
        // 기본 이니셜라이저 추가
        init(title: String, image: String? = nil) {
            self.title = title
            self.image = image
        }
    }
    
    private var getTabItemModels: [CustomTabItemModel]
    private var getTabViewStyle: CustomTabViewStyle
    private var getTabBackgroundColour: Color
    @Binding var getSelectedIndex: Int
    @ViewBuilder private let getContent: (Int) -> Content
    
    @State private var currentTitle: String = ""
    
    // 탭 높이 상수 추가
    private let tabHeight: CGFloat = 44
    private let bottomNavTabHeight: CGFloat = 60
    
    init(
        setTabViewStyle: CustomTabViewStyle,
        setTabBackgroundColour: Color,
        setTabItemModels: [CustomTabItemModel],
        setSelectedIndex: Binding<Int>,
        @ViewBuilder setContent: @escaping (Int) -> Content
    ) {
        self.getTabItemModels = setTabItemModels
        self.getTabBackgroundColour = setTabBackgroundColour
        self._getSelectedIndex = setSelectedIndex
        self.getContent = setContent
        self.getTabViewStyle = setTabViewStyle
    }
    
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        GeometryReader { geo in
            VStack(
                alignment: .center,
                spacing: 0
            ) {
                switch getTabViewStyle {
                case .BottomNavigation:
                    TabScreenView(geo: geo)
                    TabNavigationView(geo: geo)
                case .TabView:
                    TabNavigationView(geo: geo)
                    TabScreenView(geo: geo)
                }
            }
            .background(Color.clear)
        }
    }
    
    private func TabScreenView(geo: GeometryProxy) -> some View {
        let currentTabHeight = getTabViewStyle == .TabView ? tabHeight : bottomNavTabHeight
        let contentHeight = geo.size.height - currentTabHeight - 1 // 1은 구분선 높이
        
        return getContent(getSelectedIndex)
            .frame(height: contentHeight)
            .onAppear {
                if currentTitle.isEmpty {
                    currentTitle = getTabItemModels.first?.title ?? ""
                }
            }
    }
    
    private func TabNavigationView(geo: GeometryProxy) -> some View {
        let currentTabHeight = getTabViewStyle == .TabView ? tabHeight : bottomNavTabHeight
        
        return VStack(alignment: .center, spacing: 0) {
            switch getTabViewStyle {
            case .BottomNavigation:
                Rectangle()
                    .fill(Color.black)
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: 1
                    )
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(
                        alignment: .center,
                        spacing: 0
                    ) {
                        ForEach(getTabItemModels, id: \.self) { model in
                            TabItemView(setModel: model)
                        }
                    }
                    .frame(height: currentTabHeight)
                }
            case .TabView:
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(
                        alignment: .center,
                        spacing: 0
                    ) {
                        ForEach(getTabItemModels, id: \.self) { model in
                            TabItemView(setModel: model)
                        }
                    }
                    .frame(height: currentTabHeight)
                }
            
            }
        }
        .background(getTabBackgroundColour)
        .frame(
            width: UIScreen.main.bounds.width,
            height: currentTabHeight + 1 // 1은 구분선 높이
        )
    }
    
    private func TabItemView(setModel getModel: CustomTabItemModel) -> some View {
        let isSelected = getModel.title == currentTitle
        
        return VStack(alignment: .center, spacing: 0) {
            // 상단 여백
            Spacer()
            
            // 아이콘과 텍스트
            VStack(alignment: .center, spacing: 4) {
                if let image = getModel.image {
                    Image(image)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundColor(isSelected ? (scheme == .dark ? Color.white : Color.black) : Color.gray)
                        .frame(height: getTabViewStyle == .TabView ? 16 : 20)
                }
                
                Text(getModel.title)
                    .font(.system(size: getTabViewStyle == .TabView ? 14 : 14))
                    .foregroundColor(isSelected ? (scheme == .dark ? Color.white : Color.getColour(.label_strong)) : Color.getColour(.label_alternative))
                    .fontWeight(isSelected ? .bold : .light)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 선택된 탭 아래에 검은색 줄 표시
            Rectangle()
                .fill(isSelected ? Color.black : Color.clear)
                .frame(height: 2)
        }
        .background(Color.clear) // 배경색 clear로 통일
        .onTapGesture {
            currentTitle = getModel.title
            if let index = getTabItemModels.firstIndex(where: { $0.title == getModel.title }) {
                getSelectedIndex = index
            } else {
                getSelectedIndex = 0
            }
        }
        .frame(
            width: UIScreen.main.bounds.width / CGFloat(getTabItemModels.count),
            height: getTabViewStyle == .TabView ? tabHeight : bottomNavTabHeight
        )
    }
}
