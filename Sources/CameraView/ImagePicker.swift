//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || targetEnvironment(macCatalyst)

import SwiftUI

/// A SwiftUI port of `UIImagePickerController`.
public struct ImagePicker: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIImagePickerController
    
    @Environment(\.presentationMode) var presentationMode
    
    let info: Binding<[UIImagePickerController.InfoKey: Any]?>?
    let image: Binding<UIImage?>?
    let data: Binding<Data?>?
    

    var allowsEditing = false
    var cameraDevice: UIImagePickerController.CameraDevice?
    var sourceType: UIImagePickerController.SourceType = .savedPhotosAlbum
    var mediaTypes: [String]?
    var onCancel: (() -> Void)?
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        let controller = UIImagePickerController()
        controller.delegate = context.coordinator

        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        context.coordinator.base = self
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().backgroundColor = .systemBackground
    
        uiViewController.allowsEditing = allowsEditing
        uiViewController.sourceType = sourceType
        uiViewController.modalPresentationStyle = .fullScreen
        if let mediaTypes = mediaTypes, uiViewController.mediaTypes != mediaTypes  {
            uiViewController.mediaTypes = mediaTypes
        }
        
        if uiViewController.sourceType == .camera {
            uiViewController.cameraDevice = cameraDevice ?? .rear
        }
    }
    
    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var base: ImagePicker
        
        init(base: ImagePicker) {
            self.base = base
        }
        
        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = (info[UIImagePickerController.InfoKey.editedImage] as? UIImage) ?? (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)
            
            base.info?.wrappedValue = info
            base.image?.wrappedValue = image
            base.data?.wrappedValue = (image?._fixOrientation() ?? image)?.pngData()
            
            base.presentationMode.wrappedValue.dismiss()
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            if let onCancel = base.onCancel {
                onCancel()
            } else {
                base.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        .init(base: self)
    }
}

// MARK: - API -

extension ImagePicker {
    public init(
        info: Binding<[UIImagePickerController.InfoKey: Any]?>,
        onCancel: (() -> Void)? = nil
    ) {
        self.info = info
        self.image = nil
        self.data = nil
        
        self.onCancel = onCancel
    }
    
    public init(
        image: Binding<UIImage?>,

        onCancel: (() -> Void)? = nil
    ) {
        self.info = nil
        self.image = image
        self.data = nil
      
        self.onCancel = onCancel
    }
    
    public init(
        data: Binding<Data?>,
      
        onCancel: (() -> Void)? = nil
    ) {
        self.info = nil
        self.image = nil
        self.data = data
      
        self.onCancel = onCancel
    }
}



// MARK: - Helpers -

extension UIImage {

    
    func _fixOrientation() -> UIImage? {
        guard imageOrientation != .up else {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

#endif
