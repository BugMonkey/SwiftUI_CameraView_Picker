import SwiftUI
import CameraManager
import Photos

let SMALL_HEIGHT:CGFloat = UIScreen.main.bounds.width / 3.0 * 4.0

let BIG_HEIGHT:CGFloat = (UIScreen.main.bounds.width / 9.0 * 16.0).rounded()

let STATUS_BAR_HEIGHT = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 5

///底部安全区域高度
let BOTTOM_HEIGHT = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0

public struct CustomCameraView:View{
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var image:UIImage?
    
    @State var cameraManager:CameraManager = CameraManager()
    
    @State var firstPhoto:UIImage?
    
    @State var isFullPreview:Bool = false
    
    @State var flashMode:CameraFlashMode = .auto
    
    @State var cameraDevice = CameraDevice.back
    
    @State var selectedImage:UIImage?
    
    @State var height:Double = SMALL_HEIGHT
    
    public init(image:Binding<UIImage?>){
        self._image = image
        setupCameraManager()
    }
    public func setupCameraManager(){
        cameraManager.cameraDevice = cameraDevice
        cameraManager.imageAlbumName =  "ZNet 春军扫网"
        cameraManager.writeFilesToPhoneLibrary = false
        cameraManager.showErrorsToUsers = true
        cameraManager.shouldEnableExposure = false
        cameraManager.shouldRespondToOrientationChanges = false
        
    }
    
    public var body: some View{
        if selectedImage != nil {
            SelectedImageView(selectedImage: $selectedImage){image in
                self.image = image
            }.navigationBarHidden(true)
        }else{
            
            ZStack(alignment: .top){
                if UIScreen.main.bounds.height > BIG_HEIGHT + 48{
                    //相机预览最大高度 + 顶部控制区域高度 48 < 屏幕高度 ，此时预览区域可以放在顶部控制的下方，否则顶部区域悬浮在预览区域上
                    cameraPreviewView().padding(.top,48)

                    VStack(spacing:0){
                        
                        topControlView()
                        
                        Color.clear.frame(height:SMALL_HEIGHT)
                        
                        GeometryReader{proxy in
                            bottomControlView().frame(height: proxy.size.height)
                            
                        }
                    }
                }else{

                    
                    cameraPreviewView().padding(.top,isFullPreview ? 0 : 48 + STATUS_BAR_HEIGHT).edgesIgnoringSafeArea(.top)
                    
                    VStack(spacing:0){
                        topControlView().padding(.top,STATUS_BAR_HEIGHT)
                        
                        Color.clear.frame(height:SMALL_HEIGHT)
                        
                        GeometryReader{proxy in
                            bottomControlView().frame(height: proxy.size.height).offset(x: 0, y: BOTTOM_HEIGHT)
                            
                        }
                    }.edgesIgnoringSafeArea(.top)
                }
                
                
            }.onAppear {
                fetchFirstPhoto()
            }.background(Color.black.edgesIgnoringSafeArea(.all)).navigationBarHidden(true)
        }
        
        
    }
    
    ///相机预览
    func cameraPreviewView() -> some View{
        CameraViewControllerRepresentable(cameraManager: cameraManager, height:$height).frame(width: UIScreen.main.bounds.width, height: BIG_HEIGHT).aspectRatio(contentMode: .fill).frame(width: UIScreen.main.bounds.width, height: height).clipped()
//        CameraViewControllerRepresentable(cameraManager: cameraManager, height:$height)
//            .frame(height:height)
    }
    
    
    ///头部按钮布局
    func topControlView() -> some View{
        HStack{
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
            Image(systemName: "xmark.circle").resizable().frame(width: 30, height: 30).padding(.horizontal,15).contentShape(Rectangle()).highPriorityGesture(TapGesture().onEnded({ _ in
                presentationMode.wrappedValue.dismiss()
                
            }))
            
            Spacer()
            Image(systemName:isFullPreview ? "arrow.down.right.and.arrow.up.left.circle.fill" : "arrow.up.backward.and.arrow.down.forward.circle.fill").resizable().frame(width: 30, height: 30).padding(.horizontal,15).contentShape(Rectangle()).highPriorityGesture(TapGesture().onEnded({ _ in
                isFullPreview.toggle()
                
                withAnimation(.default) {
                    height = isFullPreview ? BIG_HEIGHT : SMALL_HEIGHT
                }
                
                setupCameraManager()

                
            }))
            
            
        }.frame(width: nil, height: 48).foregroundColor(.white)
    }
    
    
    /// 底部按钮布局
    func bottomControlView() -> some View {
        HStack{
            NavigationLink {
                ImagePicker(image: $selectedImage).navigationBarHidden(true)
            } label: {
                Image(uiImage: firstPhoto ?? UIImage.init().withTintColor(.darkGray)).resizable().scaledToFill().frame(width: 45, height: 45).cornerRadius(2).clipShape(Rectangle())
            }.buttonStyle(PlainButtonStyle())
            
            
            
            Spacer()
            
            Button(action: {
                if !cameraManager.cameraIsReady{
                    return
                }
                let newPreset:AVCaptureSession.Preset = isFullPreview ? .hd4K3840x2160 : .high
                if cameraManager.canSetPreset(preset: newPreset) ?? false{
                    cameraManager.cameraOutputQuality = newPreset
                }else{
                    
                    cameraManager.cameraOutputQuality = .high
                }
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
                cameraDevice = cameraManager.cameraDevice == .back ? .front : .back
                cameraManager.cameraDevice = cameraDevice
                
            }, label: {
                Image(systemName: "arrow.triangle.2.circlepath").foregroundColor(.white).frame(width: 45, height: 45, alignment: .center).background(Color.gray.opacity(0.5).clipShape(Circle())).rotationEffect(cameraDevice == .back ? .init(degrees: 0) : .init(degrees: 180)).animation(.default, value: cameraDevice)
            })
            
        }.padding(.horizontal,15)
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

        cameraManager.resumeCaptureSession()
        
    }
    
    typealias UIViewType = UIView
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .infinite)
        view.backgroundColor = .black
        view.contentMode = .scaleAspectFit
        cameraManager.addPreviewLayerToView(view)
        return view
    }
    
}

struct CameraViewControllerRepresentable : UIViewControllerRepresentable {
    
    let cameraManager : CameraManager?
    
    @Binding var height:Double
    
    func makeUIViewController(context: Context) -> CMViewController {
        print("CameraViewControllerRepresentable","makeUIViewController")

        return CMViewController(coordinator: context.coordinator)
    }
    func updateUIViewController(_ uiViewController: CMViewController, context: Context) {
        print("CameraViewControllerRepresentable","updateUIViewController")
        context.coordinator.cameraManager.resumeCaptureSession()
        if let uiView = uiViewController.view {

            if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer{
                if height > uiView.bounds.height{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                        layer.frame = .init(x:0,y:0,width: uiView.bounds.width, height: height)

//                        context.coordinator.cameraManager.resumeCaptureSession()
                    }
                }else{
//                    layer.frame = .init(x:0,y:0,width: uiView.bounds.width, height: height)

//                    context.coordinator.cameraManager.resumeCaptureSession()
                }
                
                
            }
            
        }
        
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

