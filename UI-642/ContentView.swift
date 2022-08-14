//
//  ContentView.swift
//  UI-642
//
//  Created by nyannyan0328 on 2022/08/14.
//

import SwiftUI

struct ContentView: View {
    @StateObject var model : LockScreenViewModel = .init()
    var body: some View {
        CustomColorFinderView(content: {
            Home()
        }, onLoad: { view in
            
            model.view = view
        })
        .overlay(alignment:.top){
            
        TimeView()
                .environmentObject(model)
                .opacity(model.placeTextAbove ? 1 : 0)
                
            
            
        }
        .ignoresSafeArea()
            .gesture(
            
                MagnificationGesture(minimumScaleDelta: 0.01)
                
                    .onChanged({ value in
                        
                        model.scale = value + model.lastScale
                        
                    })
                    
                    .onEnded({ value in
                        
                        if model.scale < 1{
                            
                            withAnimation(.easeOut(duration: 0.3)){
                                
                                model.scale = 1
                            
                            }
                          
                        }
                        model.lastScale = model.scale - 1
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                            
                            model.verifyScreenColor()
                        }
                        
                    })
              
            
            
                    
                
                
                
            )
            .ignoresSafeArea()
            .environmentObject(model)
            .onChange(of: model.onLoad) { newValue in
                if newValue{model.verifyScreenColor()}
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
