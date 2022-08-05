# CameraView

Custom SwiftUI Camera Photo Picker View. based on this Library [CameraManager](http://https://github.com/imaginary-cloud/CameraManager)

# Installation
Installation with Swift Package Manager
The Swift Package Manager is a tool for managing the distribution of Swift code.

 Add CameraView as a dependency in your Package.swift file:
```
let package = Package(
    dependencies: [
        .Package(url: "https://github.com/BugMonkey/SwiftUI_CameraView_Picker").branch("master")) 
```

# How to use

```
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
```

# Preview
![输入图片说明](ScreenShotIMG_5539.PNG)
![输入图片说明](ScreenShotIMG_5540.PNG)
