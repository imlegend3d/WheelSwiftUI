//
//  QueueCarousel.swift
//  WheelSwiftUI
//
//  Created by Johan David Gonzalez on 2022-05-22.
//

import SwiftUI
import CoreMedia

struct QueueCarousel<Content: View,T: Identifiable>: View {
    var content: (T) -> Content
    var list: [T]
    var spacing: CGFloat
    var trailingSpace: CGFloat
    @Binding var index: Int
    
    init(spacing:CGFloat = 5, trailingSpace: CGFloat = 10, index: Binding<Int>, items: [T], @ViewBuilder content: @escaping (T)-> Content){
        self.list = items
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
        self.content = content
    }
    
    @GestureState var offset: CGFloat = 0
    @State var currentIndex: Int = 0
    
    var body: some View {
        return GeometryReader{ proxy in

            let width = proxy.size.width / 4
            HStack(spacing: spacing){
                ForEach(list) { item in
                    content(item)
                        .offset(y: getOffset(item: item, width: width, index: index))
                        .animation(.easeInOut(duration: 1))
                }
            }
            .padding(.horizontal, spacing)
            .offset(x: (CGFloat(currentIndex) * -width) + offset)
        }
    }
    
    func getOffset(item: T, width: CGFloat, index: Int) -> CGFloat {
        
        let progress = (offset / width) * 60
        let topOffset = -progress < 60 ? progress : -(progress + 120)
        let previous = getIndex(item: item) - 1 == index ? topOffset : 0
        let next = getIndex(item: item) + 1 == index ? topOffset : 0
        
        let checkBetween = index >= 0 && index < list.count ? (getIndex(item: item) - 1 == index ? previous : next) : 0
        return  getIndex(item: item) == index ? -60 - topOffset : checkBetween
    }

    func getIndex(item: T) -> Int{
        let index = list.firstIndex { currentItem in
            return currentItem.id == item.id
        } ?? 0

        return index
    }
}

