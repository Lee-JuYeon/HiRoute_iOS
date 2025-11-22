//
//  BookmarkSyncResponse.swift
//  HiRoute
//
//  Created by Jupond on 7/28/25.
//
import SwiftUI

struct PlaceTopSection : View {
    
    private var model : PlaceModel
    private var callBackEditInfo : (String) -> Void
    private var callBackCopyAddress : (AddressModel) -> Void
    private var callBackBookMark : (String) -> Void
    private var callBackNavigate : (AddressModel) -> Void
    private var callBackAddPlace : (PlaceModel) -> Void
    
    init(
        setPlaceModel : PlaceModel,
        onCallBackEditInfo : @escaping (String) -> Void,
        onCallBackCopyAddress : @escaping (AddressModel) -> Void,
        onCallBackBookMark : @escaping (String) -> Void,
        onCallBackNavigate : @escaping (AddressModel) -> Void,
        onCallBackAddPlace : @escaping (PlaceModel) -> Void
    ){
        self.model = setPlaceModel
        self.callBackEditInfo = onCallBackEditInfo
        self.callBackCopyAddress = onCallBackCopyAddress
        self.callBackBookMark = onCallBackBookMark
        self.callBackNavigate = onCallBackNavigate
        self.callBackAddPlace = onCallBackAddPlace
    }
    
    @ViewBuilder
    private func placeThumbNailImage(imageURL : String) -> some View {
        ServerImageView(
            setImageURL: imageURL
        )
        .background(Color.getColour(.background_alternative))
        .frame(
            maxWidth: .infinity,
            minHeight: 0,
            idealHeight: 200,
            maxHeight: 200
        )
        .clipped()
    }
    
    @ViewBuilder
    private func placeTitleWithType(title : String, type : String) -> some View{
        HStack(alignment: VerticalAlignment.center, spacing: 4){
            PlaceTitle(title: title)
            PlaceTypeView(type: type)
        }
        .frame(
            alignment: .leading
        )
        .padding(
            EdgeInsets(top: 16, leading: 12, bottom: 4, trailing: 12)
        )
    }
   
    private let cornerRadius : CGFloat = 20
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading, spacing: 0){
            placeThumbNailImage(imageURL: model.thumbanilImageURL ?? "")
            placeTitleWithType(
                title: model.title,
                type: model.type.displayText
            )
            
            PlaceStarReviewBookMarkCountView(
                starCount: model.stars.count,
                reviewCount: model.reviews.count,
                bookMarkCount: model.bookMarks.count
            )
            
            PlaceAddressView(
                address: model.address,
                onCallBackCopyAddress: { addressModel in
                    callBackCopyAddress(addressModel)
                }
            )
            
            WorkingTimeList(
                setList: model.workingTimes,
                setPlaceType: model.type
            )
            
            PlaceInfoEditRequestView(
                onCallBackInfoEditRequest: {
                    callBackEditInfo(model.uid)
                }
            )
            
            PlaceButtons(
                setModel: model,
                onCallBackPlaceNavigation: { addressModel in
                    callBackNavigate(addressModel)
                },
                onCallBackAddPlace: { placeModel in
                    callBackAddPlace(placeModel)
                    
                },
                onCallBackBookMark: { bookMarkedUID in
                    callBackBookMark(bookMarkedUID)
                }
            )
        }
        .background(Color.getColour(.background_white))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .padding(
            EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        )
        .customElevation(.normal)

    }
}


