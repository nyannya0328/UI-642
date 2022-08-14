//
//  Home.swift
//  UI-642
//
//  Created by nyannyan0328 on 2022/08/14.
//

import SwiftUI
import PhotosUI
import SDWebImageSwiftUI

struct Home: View {
    @EnvironmentObject var model : LockScreenViewModel
    var body: some View {
        VStack{
            
            if let compressdImage = model.compresedImage{
                
                
                GeometryReader{proxy in
                    
                     let size = proxy.size
                    
                    Image(uiImage: compressdImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size.width,height: size.height)
                        .scaleEffect(model.scale)
                        .overlay {
                            
                            if let detextedPerson = model.detectedPerson{
                                
                                TimeView()
                                    .environmentObject(model)
                                
                                Image(uiImage: detextedPerson)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .scaleEffect(model.scale)
                                
                            }
                        }
                    
                }
                
                
            }
            else{
                
    
                PhotosPicker(selection: $model.pickedItem,matching: .images,preferredItemEncoding: .automatic,photoLibrary: .shared()) {
                    
                    VStack(spacing:15){
                        
                         Image(systemName: "plus.viewfinder")
                            .font(.largeTitle)
                        
                        Text("Add Image")
                    }
                    .foregroundColor(.primary)
                }
                
                
            }
            
            
        }
        .ignoresSafeArea()
        .overlay(alignment: .topLeading) {
            
            Button("Cancel"){
                
                withAnimation(.easeOut){
                    
                    model.compresedImage = nil
                    model.detectedPerson = nil
                }
                model.scale = 1
                model.lastScale = 0
                model.placeTextAbove = false
            
                
                
                
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.vertical,6)
            .padding(.horizontal)
            .background{
             
                Capsule()
                    .fill(.ultraThickMaterial)
            }
            .padding()
            .opacity(model.compresedImage == nil ? 0 : 1)
            
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TimeView : View{
    @EnvironmentObject var model : LockScreenViewModel
    var body: some View{
        
        HStack(spacing:0){
            
            Text(Date.now.convertToString(.hour))
                .font(.system(size: 95))
                .fontWeight(.semibold)
            
            VStack(spacing:10){
                
                Capsule()
                    .fill(.white)
                    .frame(width: 15,height: 15)
                
                Capsule()
                    .fill(.white)
                    .frame(width: 15,height: 15)
                    .overlay {
                        
                        GeometryReader{proxy in
                            
                      
                            let frame = proxy.frame(in: .global)
                            Color.clear
                                .preference(key :RectKey.self, value: frame)
                                .onPreferenceChange(RectKey.self) { value in
                                    
                                    model.textRect = value
                                    
                                }
                          
                            
                        
                        }
                    }
            }
            
            
            Text(Date.now.convertToString(.minute))
                .font(.system(size: 95))
                .fontWeight(.semibold)
            
            VStack(spacing:10){
                
                Capsule()
                    .fill(.white)
                    .frame(width: 15,height: 15)
                
                Capsule()
                    .fill(.white)
                    .frame(width: 15,height: 15)
            }
            
            
            Text(Date.now.convertToString(.sec))
                .font(.system(size: 95))
                .fontWeight(.semibold)
            
            
            
            
            
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .top)
        .padding(.top,100)
    }
    
}
enum DateFormat : String{
    
    case hour = "hh"
    case minute = "mm"
    case sec = "ss"
    
    
}

extension Date{
    
    func convertToString(_ format : DateFormat) -> String{
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
}

struct RectKey : PreferenceKey{
    
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
