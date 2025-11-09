//
//  ManualPicker.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 11/4/25.
//

import SwiftUI

/// UIViewController exercise
struct ManualPicker: View {
    @State var isPresented = false
    @State var image: UIImage? = nil
    
    var body: some View {
        VStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            
            Spacer()
            
            Text("pick god damn image!")
                .onTapGesture {
                    isPresented = true
                }
                .sheet(isPresented: $isPresented) {
                    UIPickerRepresentable(image: $image, isPresented: $isPresented)
                }
        }
    }
}

struct UIPickerRepresentable: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    @Binding var isPresented: Bool

    // UIKIT -> SWIFTUI
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let vc = UIImagePickerController()
        vc.allowsEditing = false
        vc.delegate = context.coordinator
        return vc
    }
    
    // SwiftUI -> UIKIT
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
   
    //UIKIT -> SWIFTUI
    func makeCoordinator() -> Coordinator {
        return Coordinator(image: $image, isPresented: $isPresented)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        @Binding var image: UIImage?
        @Binding var isPresented: Bool

        
        init(image: Binding<UIImage?>, isPresented: Binding<Bool>) {
            self._image = image
            self._isPresented = isPresented
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let newImage = info[.originalImage] as? UIImage
            else { return }
            
            image = newImage
            isPresented = false
        }
    }
}

#Preview {
    ManualPicker()
}
