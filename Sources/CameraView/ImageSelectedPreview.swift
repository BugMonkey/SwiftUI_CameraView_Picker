//
//  SwiftUIView.swift
//  
//
//  Created by Mac on 2022/7/28.
//

import SwiftUI

struct SelectedImageView: View {
    
    @Binding var selectedImage:UIImage?
    
    let confirmed:(UIImage?)->Void
    
    var body: some View {
        ZStack{
            Image(uiImage: selectedImage ?? UIImage()).resizable().scaledToFit().frame(width: UIScreen.main.bounds.width, height: nil, alignment: .center).edgesIgnoringSafeArea(.all)
            VStack(spacing:0){
                Spacer()
                
                HStack{
                    Text("取消").onTapGesture {
                        selectedImage = nil
                    }
                    
                    Spacer()
                    
                    Text("使用照片").onTapGesture {
                        confirmed(selectedImage)
                    }
                }.font(.system(size: 16)).padding(15).foregroundColor(.white).background(Color.black.opacity(0.8)).frame(width: UIScreen.main.bounds.width, height: nil, alignment: .center)
            }
        }.background(Color.black.edgesIgnoringSafeArea(.all))
    }
}


