//
//  LockScreenViewModel.swift
//  UI-642
//
//  Created by nyannyan0328 on 2022/08/14.
//

import SwiftUI
import PhotosUI
import SDWebImageSwiftUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

class LockScreenViewModel: ObservableObject {
   
    @Published var pickedItem : PhotosPickerItem?{
        
        didSet{
        
            extractImage()
            
            segmetnPersonOnImage()
            
        }
    }
    
    @Published var compresedImage : UIImage?
    @Published var detectedPerson : UIImage?
    
    @Published var scale : CGFloat = 1
    @Published var lastScale : CGFloat = 0
    
    @Published var textRect : CGRect = .zero
    
    @Published var onLoad : Bool = false
    
    @Published var view : UIView = .init()
    
    @Published var placeTextAbove : Bool = false
    
 
    func verifyScreenColor(){
        
        let rgba = view.color(at: CGPoint(x: textRect.midX, y: textRect.midY * 5))
        
        withAnimation(.easeOut){
            
            
            if rgba.0 == 1 && rgba.1 == 1 && rgba.2 == 1 && rgba.3 == 1{
                
                placeTextAbove = false
            }
            
            else{
                
                
                placeTextAbove = true
            }
            
            
        }
        
    }
 
    func segmetnPersonOnImage(){
        
        guard let image = compresedImage?.cgImage else{return}
        
        let request = VNGeneratePersonSegmentationRequest()
        
     //   request.usesCPUOnly = true
        
        let task = VNImageRequestHandler(cgImage: image)
        
        do{
            
            try task.perform([request])
            
            if let result = request.results?.first{
                
                let buffer = result.pixelBuffer
            
                maskWidtOriginalImage(buffer: buffer)
                
            }
            
        }
        catch{
            
            print(error.localizedDescription)
        }
        
    }
    
    func maskWidtOriginalImage(buffer : CVPixelBuffer){
        
        
        guard let cgImage = compresedImage?.cgImage else{return}
        
        let original = CIImage(cgImage: cgImage)
        
        let mask = CIImage(cvImageBuffer: buffer)
        
        
        let maskX = original.extent.width / mask.extent.width
        let maskY = original.extent.height / mask.extent.height
        
        let resizedMask = mask.transformed(by: CGAffineTransform(scaleX: maskX, y: maskY))
        
        let filter = CIFilter.blendWithMask()
        filter.inputImage = original
        filter.maskImage = resizedMask
        
        
        if let maskedImage = filter.outputImage{
            
            let context = CIContext()
            guard let image = context.createCGImage(maskedImage, from: mask.extent) else{return}
            
            self.detectedPerson = UIImage(cgImage: image)
            self.onLoad = true
            
        }
        
    
        
        
    }
    
    func extractImage(){
        
        if let pickedItem{
            
            Task{
                
                guard let imageData = try? await pickedItem.loadTransferable(type: Data.self) else{return}
                
                let size = await UIApplication.shared.scrrenSize()
                
                
                let image = UIImage(data: imageData)?.sd_resizedImage(with: CGSize(width: size.width * 2, height: size.height * 2), scaleMode: .aspectFill)
                await MainActor.run(body: {
                    
                    self.compresedImage = image
                })
                
            }
        }
        
        
    }
}

extension UIApplication{
    
    func scrrenSize()->CGSize{
        
        guard let window = connectedScenes.first as? UIWindowScene else {return .zero}
        
        return window.screen.bounds.size
        
        
    }
    
    
    
}

extension UIView{
    
    func color(at point : CGPoint)->(CGFloat,CGFloat,CGFloat,CGFloat){
        
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        var pixelData : [UInt8] = [0,0,0,0]
        
        let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context!.translateBy(x: -point.x, y: -point.y)
        
        
        self.layer.render(in: context!)
        
        let red = CGFloat(pixelData[0]) / 255
        let blue = CGFloat(pixelData[1]) / 255
        let green = CGFloat(pixelData[2]) / 255
        let alpha =  CGFloat(pixelData[3]) / 255
        
        return (red,blue,green,alpha)
    }
}

