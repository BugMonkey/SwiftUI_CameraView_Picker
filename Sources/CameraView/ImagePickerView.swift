
//
//  ImagePickerView.swift
//
//
//  Created by Alex Nagy on 19.01.2021.
//

import SwiftUI
import UIKit
import PhotosUI

@available(iOS 14, *)
public struct ImagePickerView: UIViewControllerRepresentable {
    
    public typealias UIViewControllerType = PHPickerViewController
    
    public init(filter: PHPickerFilter = .images, selectionLimit: Int = 1, delegate: PHPickerViewControllerDelegate) {
        self.filter = filter
        self.selectionLimit = selectionLimit
        self.delegate = delegate

        UINavigationBar.appearance().backgroundColor = .systemBackground
    }
    
    private let filter: PHPickerFilter
    private let selectionLimit: Int
    private let delegate: PHPickerViewControllerDelegate
    
    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.filter = filter
        configuration.selectionLimit = selectionLimit
        configuration.preferredAssetRepresentationMode = .current
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = delegate
        return controller
    }
    
    public func updateUIViewController(_ controller: PHPickerViewController, context: Context) {
        controller.findNestedUINavigationController()?.navigationBar.backgroundColor = .systemBackground
        controller.findNestedUINavigationController()?.navigationBar.tintColor = .AccentColor
//        controller.navigationController?.navigationBar.isHidden = true
//        UINavigationBar.appearance().backgroundColor = .systemBackground
//        UINavigationBar.appearance().tintColor = .AccentColor
//        let appearance = UINavigationBarAppearance()
//                appearance.backgroundColor = .white
//                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
//                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//
//        controller.navigationController?.navigationBar.tintColor = .white
//        controller.navigationController?.navigationBar.standardAppearance = appearance
//        controller.navigationController?.navigationBar.compactAppearance = appearance
//        controller.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    public static func dismantleUIViewController(_ uiViewController: PHPickerViewController, coordinator: ()) {
        UINavigationBar.appearance().backgroundColor = .clear

    }

}

@available(iOS 14, *)
extension ImagePickerView {
    public class Delegate: NSObject, PHPickerViewControllerDelegate {
        
        public init(isPresented: Binding<Bool>, didCancel: @escaping (PHPickerViewController) -> (), didSelect: @escaping (ImagePickerResult) -> (), didFail: @escaping (ImagePickerError) -> ()) {
            self._isPresented = isPresented
            self.didCancel = didCancel
            self.didSelect = didSelect
            self.didFail = didFail
        }
        
        @Binding var isPresented: Bool
        private let didCancel: (PHPickerViewController) -> ()
        private let didSelect: (ImagePickerResult) -> ()
        private let didFail: (ImagePickerError) -> ()
        
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
           
            if results.count == 0 {
                self.isPresented = false
                self.didCancel(picker)
                return
            }
            var images = [UIImage]()
            for i in 0..<results.count {
                let result = results[i]
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { newImage, error in
                        if let error = error {
                            self.isPresented = false
                            self.didFail(ImagePickerError(picker: picker, error: error))
                        } else if let image = newImage as? UIImage {
                            images.append(image)
                        }
                        if images.count == results.count {
                            self.isPresented = false
                            if images.count != 0 {
                                self.didSelect(ImagePickerResult(picker: picker, images: images))
                            } else {
                                self.didCancel(picker)
                            }
                        }
                    }
                } else {
                    self.isPresented = false
                    self.didFail(ImagePickerError(picker: picker, error: ImagePickerViewError.cannotLoadObject))
                }
            }
            
            
        }
    }
}

@available(iOS 14, *)
public struct ImagePickerResult {
    public let picker: PHPickerViewController
    public let images: [UIImage]
}
@available(iOS 14, *)
public struct ImagePickerError {
    public let picker: PHPickerViewController
    public let error: Error
}
@available(iOS 14, *)
public enum ImagePickerViewError: Error {
    case cannotLoadObject
    case failedToLoadObject
}
