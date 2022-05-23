//
//  PhotoModel.swift
//  WheelSwiftUI
//
//  Created by Johan David Gonzalez on 2022-05-22.
//

import SwiftUI

struct Photo: Identifiable {
    var id = UUID().uuidString
    var photo: Image
}
