//
//  RadialGradientLayer.swift
//  ChartsApp
//
//  Created by Gil Eluard on 10/03/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit

class RadialGradientLayer: CALayer {
    var colors: [CGColor] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var locations: [CGFloat] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        setNeedsDisplay()
    }
    
    override func draw(in ctx: CGContext) {
        guard colors.count > 0 && locations.count == colors.count else {
            return
        }
        
        let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        let radius = min(center.x, center.y)
        
        // Prepare a context and create a color space
        ctx.saveGState();
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // Create gradient object from our color space, color components and locations
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations) {
            // Draw a gradient
            ctx.drawRadialGradient(gradient, startCenter: center, startRadius: 0.0, endCenter: center,
                                   endRadius: radius, options: .drawsBeforeStartLocation)
        }
        ctx.restoreGState();
    }
}
