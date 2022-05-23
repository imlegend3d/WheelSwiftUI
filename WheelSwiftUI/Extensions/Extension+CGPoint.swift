//
//  Extension+CGPoint.swift
//  WheelSwiftUI
//
//  Created by Johan David Gonzalez on 2022-05-22.
//

import SwiftUI

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow((point.x - x), 2) + pow((point.y - y), 2))
    }
}
