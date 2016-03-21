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
    
    override func drawInContext(ctx: CGContext) {
        guard colors.count > 0 && locations.count == colors.count else {
            return
        }
        
        let radius = fmin(CGRectGetHeight(self.bounds) / 2, CGRectGetWidth(self.bounds) / 2)
        let center = CGPoint(x: CGRectGetWidth(self.bounds) / 2, y: CGRectGetHeight(self.bounds) / 2)
        
        // Prepare a context and create a color space
        CGContextSaveGState(ctx);
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // Create gradient object from our color space, color components and locations
        let gradient = CGGradientCreateWithColors(colorSpace, colors, locations)
        
        // Draw a gradient
        CGContextDrawRadialGradient(ctx, gradient, center, 0.0, center, radius, .DrawsBeforeStartLocation);
        CGContextRestoreGState(ctx);
    }
}
