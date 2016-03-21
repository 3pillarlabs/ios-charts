//
//  PieArcLayer.swift
//  ChartsApp
//
//  Created by Gil Eluard on 01/03/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit

struct PieArcInfo {
    var value: CGFloat
    var color: UIColor
}

class PieArcLayer: CALayer {
    @NSManaged var maxArcAngle: CGFloat
    
    var animationDuration: CFTimeInterval = 0.5
    let arcPadding = CGFloat((M_PI * 2) / 720)
    var extern: Bool?
    var values: [PieArcInfo] = [] {
        didSet {
            maxArcAngle = values.reduce(0, combine: {CGFloat(fmaxf(Float($0), Float($1.value)))}) * CGFloat(M_PI * 2)
        }
    }
    var lineWidth: CGFloat = 50
    
    override func layoutSublayers() {
        super.layoutSublayers()
        self.setNeedsDisplay()
    }
    
    override class func needsDisplayForKey(key: String) -> Bool {
        if key == "maxArcAngle" {
            return true
        }
        return super.needsDisplayForKey(key)
    }
    
    override func actionForKey(event: String) -> CAAction? {
        if event == "maxArcAngle" {
            let animation = CABasicAnimation(keyPath: event)
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animation.duration = animationDuration
            animation.fromValue = 0
            return animation
        }
        return super.actionForKey(event)
    }
    
    override func display() {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        
        var startAngle: CGFloat = 0
        
        CGContextSetLineWidth(ctx, lineWidth)
        
        let center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2)
        let radius:CGFloat = (fmin(self.bounds.size.height, self.bounds.size.width)) / 2
        
        for info in values {
            startAngle = drawArcForInfo(info, ctx: ctx, startAngle: startAngle, center: center, radius: radius)
        }
        
        self.contents = UIGraphicsGetImageFromCurrentImageContext().CGImage
        UIGraphicsEndImageContext()
    }
    
    private func drawArcForInfo(info: PieArcInfo, ctx: CGContextRef?, startAngle: CGFloat, center: CGPoint, radius: CGFloat) -> CGFloat {
        let maxArcAngle = self.presentationLayer()?.maxArcAngle ?? 0
        let angle = fmin(CGFloat(Double(info.value) * M_PI * 2), maxArcAngle)
        let padding = fmin(angle, arcPadding)
        let endAngle = startAngle + angle - padding
        
        if extern! {
            CGContextSetStrokeColorWithColor(ctx, info.color.CGColor)
            CGContextAddArc(ctx, center.x, center.y, radius - lineWidth/2, startAngle, endAngle, 0)
            CGContextDrawPath(ctx, .Stroke)
        } else {
            CGContextSetFillColorWithColor(ctx, info.color.CGColor)
            CGContextMoveToPoint(ctx, center.x,center.y)
            CGContextAddArc(ctx, center.x, center.y, radius, startAngle, endAngle, 0)
            CGContextFillPath(ctx)
        }
        
        return endAngle + padding
    }
}
