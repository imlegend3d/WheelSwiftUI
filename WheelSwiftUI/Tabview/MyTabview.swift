//
//  Drawer.swift
//  WheelSwiftUI
//
//  Created by Johan David Gonzalez on 2022-05-22.
//

import SwiftUI

struct MyTabview: View {
    @State private var selection = 0
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.black.withAlphaComponent(0.5)
        UITabBar.appearance().isTranslucent = true
    }
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.title)
                }
                .tag(0)
                .background(BackgroundHelper())
            
            PhotosFromAPiView()
                .font(.title)
                .tabItem {
                    Image(systemName: "network")
                        .font(.title)
                }
                .tag(1)
                .background(BackgroundHelper())
        }
        .ignoresSafeArea()
        .statusBar(hidden: true)
    }
}

struct BackgroundHelper: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            // find first superview with color and make it transparent
            var parent = view.superview
            repeat {
                if parent?.backgroundColor != nil {
                    parent?.backgroundColor = UIColor.clear
                    break
                }
                parent = parent?.superview
            } while (parent != nil)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

