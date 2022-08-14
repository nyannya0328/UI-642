//
//  CustomColorFinderView.swift
//  UI-642
//
//  Created by nyannyan0328 on 2022/08/14.
//

import SwiftUI

struct CustomColorFinderView<Content : View>: UIViewRepresentable {
    
    @EnvironmentObject var model : LockScreenViewModel
    
    var content : Content
    var onLoad : (UIView) -> ()
    
    
    init(@ViewBuilder content : @escaping()->Content,onLoad : @escaping(UIView) -> ()) {
        
        self.content = content()
        self.onLoad = onLoad
    }
    
    
    func makeUIView(context: Context) -> UIView {
        
        let size = UIApplication.shared.scrrenSize()
        let host = UIHostingController(rootView: content.frame(width: size.width,height: size.height)
            .environmentObject(model)
        )
        
        host.view.frame = CGRect(origin: .zero, size: size)
        
        return host.view
        
        
        
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        
        
        DispatchQueue.main.async {
            onLoad(uiView)
            
        }
    }
}

