//
//  UIColor+Extension.swift
//  ChartsApp
//
//  Created by Norbert Agoston on 09/03/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit

extension UIColor {
    
    /**
     Create UIColor with RGB values and alpha
     */
    public convenience init(r: Int, g: Int, b: Int, a: CGFloat) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    
    /**
     Create UIColor with a hex value and alpha
     */
    public convenience init(hex: Int, a: CGFloat) {
        self.init(r: (hex >> 16) & 0xFF, g: (hex >> 8) & 0xFF, b: hex & 0xFF, a: a)
    }
    
    /**
     Determine a high contrast text color based on the background color
     */
    public func determineAReadableTextColor() -> UIColor {
        var d = CGFloat(0.0)
        let rgba = self.rgba
        let a = 1 - ( 0.299 * rgba.r + 0.587 * rgba.g + 0.114 * rgba.b)
        if a < 0.5 {
            d = 0
        } else {
            d = 255
        }
        d = d / 255.0
        return  UIColor(red: d, green: d, blue: d, alpha: 1.0)
    }
    
    var rgba:(r: CGFloat, g: CGFloat,b: CGFloat,a: CGFloat) {
        var rgba:(r: CGFloat, g: CGFloat,b: CGFloat,a: CGFloat) = (0,0,0,0)
        self.getRed(&(rgba.r), green: &(rgba.g), blue: &(rgba.b), alpha: &(rgba.a))
        return rgba
    }
}
