//
//  HomeViewModel.swift
//  WheelSwiftUI
//
//  Created by Johan David Gonzalez on 2022-05-22.
//

import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    
    @Published var dogPhotos: [String] = []
    var requests = Set<AnyCancellable>()
    
    func onChanged(value: CGPoint, center: CGPoint) -> Int{
        withAnimation(.linear){

            let dx = value.x - center.x
            let dy = value.y - center.y
            let radians = atan2(dy, dx)
            let angle = 90 + radians * 180 / .pi
            if angle < 0 {
                return Int(angle) + 360
            }
            return Int(angle)
        }
    }
    
    func onEnded(value: DragGesture.Value){
        withAnimation(.linear){

        }
    }
}
