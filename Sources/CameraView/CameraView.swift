import SwiftUI
import CameraManager
import Photos

let SMALL_HEIGHT:CGFloat = UIScreen.main.bounds.width / 3.0 * 4.0

let BIG_HEIGHT:CGFloat = UIScreen.main.bounds.height

///底部安全区域高度
let BOTTOM_HEIGHT = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0

public struct CustomCameraView:View{
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var image:UIImage?
    
    @State var cameraManager:CameraManager = CameraManager()
    
    @State var firstPhoto:UIImage?
    
    @State var isFullPreview:Bool = true
    
    @State var flashMode:CameraFlashMode = .auto
    
    @State var cameraDevice = CameraDevice.back
    
    @State var selectedImage:UIImage?
    
    public init(image:Binding<UIImage?>){
        self._image = image
        setupCameraManager()
    }
    public func setupCameraManager(){
        cameraManager.cameraDevice = cameraDevice
        cameraManager.imageAlbumName =  "ZNet 春军扫网"
        cameraManager.shouldEnableExposure = true
        cameraManager.writeFilesToPhoneLibrary = true
        cameraManager.showErrorsToUsers = true
        cameraManager.cameraOutputQuality = .hd1920x1080

    }
    
    public var body: some View{
        if selectedImage != nil {
            SelectedImageView(selectedImage: $selectedImage){image in
                self.image = image
            }.navigationBarHidden(true)
        }else{
            ZStack(alignment: .center){
                CameraViewControllerRepresentable(cameraManager: cameraManager).frame(width: UIScreen.main.bounds.width, height: isFullPreview ? BIG_HEIGHT : SMALL_HEIGHT, alignment: .center).id(isFullPreview)
                
                VStack(spacing:0){
                    HStack(alignment: .bottom){
//                        Group{
//                            switch flashMode{
//                                case .auto:
//                                    Image(systemName: "bolt.badge.a").resizable()
//                                case .off:
//                                    Image(systemName:"bolt.slash").resizable()
//                                case .on:
//                                    Image(systemName:"bolt").resizable()
//                            }
//                        }.scaledToFit().frame(width: 30, height: 30, alignment: .center).contentShape(Rectangle())
//                            .highPriorityGesture(TapGesture().onEnded({ _ in
//
//                                flashMode = cameraManager.changeFlashMode()
//
//                            }))
                        Image(systemName: "xmark.circle").resizable().frame(width: 30, height: 30, alignment: .center).contentShape(Rectangle()).highPriorityGesture(TapGesture().onEnded({ _ in
                            
                            presentationMode.wrappedValue.dismiss()
                            
                        }))
                        
                        Spacer()
                        Image(systemName:isFullPreview ? "arrow.down.right.and.arrow.up.left.circle.fill" : "arrow.up.backward.and.arrow.down.forward.circle.fill").resizable().frame(width: 30, height: 30, alignment: .center).contentShape(Rectangle()).highPriorityGesture(TapGesture().onEnded({ _ in
                            
                            isFullPreview.toggle()
                            cameraManager = CameraManager()
                            setupCameraManager()
                            
                            
                        }))
                        
                        
                    }.padding(.bottom,5).padding(.horizontal,15).frame(width: nil, height: 86, alignment: .bottom).foregroundColor(.white)
                    
                    
                    Spacer()
                    
                    HStack{
                        NavigationLink {
                            ImagePicker(image: $selectedImage).navigationBarHidden(true)
                        } label: {
                            Image(uiImage: firstPhoto ?? UIImage.init().withTintColor(.darkGray)).resizable().scaledToFill().frame(width: 45, height: 45).cornerRadius(2).clipShape(Rectangle())
                        }

                       
                        
                        Spacer()
                        
                        Button(action: {
                            cameraManager.cameraOutputQuality = isFullPreview ? .hd1920x1080 : .high
                            cameraManager.capturePictureWithCompletion { result in
                                switch result {
                                    case .success(let value):
                                        firstPhoto = value.asImage
                                        selectedImage = value.asImage
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                }
                            }
                        }, label: {
                            Color.white.frame(width: 50, height: 50, alignment: .center).clipShape(Circle()).padding(4).overlay(Circle().stroke(lineWidth: 2).foregroundColor(.white))
                        })
                        Spacer()
                        
                        Button(action: {
                            cameraManager.cameraDevice = cameraManager.cameraDevice == .back ? .front : .back
                            cameraDevice = cameraManager.cameraDevice
                        }, label: {
                            Image(systemName: "arrow.triangle.2.circlepath").foregroundColor(.white).frame(width: 45, height: 45, alignment: .center).background(Color.white.opacity(0.1).clipShape(Circle()))
                        })
                        
                    }.padding(15).padding(.bottom,BOTTOM_HEIGHT).background(Color.black.opacity(0.2))
                }.onAppear {
                    fetchFirstPhoto()
                }
                
            }.background(Color.black).edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        }
        
    }
    
    
    ///获取系统相册第一张照片
    fileprivate func fetchFirstPhoto(){
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image,options: fetchOptions)
        
        if let phasset = fetchResult.firstObject{
            PHImageManager.default().requestImage(for: phasset, targetSize: CGSize(width: 120, height: 120), contentMode: .aspectFill, options: nil) { (image, info) in
                firstPhoto = image
            }
        }
    }
}

struct CameraViewRepresentable:UIViewRepresentable {
    let cameraManager:CameraManager
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.setNeedsUpdateConstraints()
    }
    
    typealias UIViewType = UIView
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .infinite)
        view.backgroundColor = .black
        view.contentMode = .scaleAspectFit
        if cameraManager.currentCameraStatus() == .ready{
            cameraManager.addPreviewLayerToView(view)
        }
        return view
    }
    
}

struct CameraViewControllerRepresentable : UIViewControllerRepresentable {
  
    let cameraManager : CameraManager?

    func makeUIViewController(context: Context) -> CMViewController {
        let vc = CMViewController(coordinator: context.coordinator)
        return vc
    }
    func updateUIViewController(_ uiViewController: CMViewController, context: Context) {
        print("Updated")
      
    }
    func makeCoordinator() -> Coordinator {
        
        let coordinator = Coordinator(cameraManager : self.cameraManager ?? CameraManager())
        return coordinator
    }
    

    class Coordinator : NSObject {
        init(cameraManager: CameraManager) {
            self.cameraManager = cameraManager
        }
        
        let cameraManager : CameraManager
    }
    
    class CMViewController : UIViewController {

        let coordinator : Coordinator
        
        init(coordinator : Coordinator) {
            self.coordinator = coordinator
            super.init(nibName: nil, bundle: nil)
        }

        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.coordinator.cameraManager.addLayerPreviewToView(self.view, newCameraOutputMode: .stillImage) {
                print("CMViewController DONE")
            }
            
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            self.coordinator.cameraManager.stopCaptureSession()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.coordinator.cameraManager.resumeCaptureSession()
        }
        
        
    }
    
}


struct CameraView_Preview:PreviewProvider {
    static var previews: some View{
        CustomCameraView(image: .constant(nil))
    }
}
