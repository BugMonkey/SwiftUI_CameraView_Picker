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
            NavigationLink {
                CustomCameraView(image: $image)
            } label: {
                Text("去选择")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
