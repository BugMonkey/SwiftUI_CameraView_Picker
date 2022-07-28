//
//  ContentView.swift
//  Shared
//
//  Created by Mac on 2022/7/27.
//

import SwiftUI
import CameraView

struct ContentView: View {
    @State private var image:UIImage?
    var body: some View {
        NavigationView{
            CustomCameraView(image: $image)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
