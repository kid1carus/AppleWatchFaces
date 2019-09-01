//
//  SKColor.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 11/6/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import SpriteKit

extension UIColor {
    public convenience init(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        self.init(red: 0, green: 0, blue: 0, alpha: 1.0)
    }
}

#if canImport(SwiftUI)

import SwiftUI

extension Color {
    init(hexString: String) {
        let uC = UIColor.init(hexString: hexString)
        
        self.init(uC)
    }
    
}

#endif
