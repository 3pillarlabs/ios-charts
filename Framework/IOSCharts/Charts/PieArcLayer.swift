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
    let arcPadding = CGFloat.pi / 360
    var extern: Bool?
    var values: [PieArcInfo] = [] {
        didSet {
            maxArcAngle = values.reduce(0, { max($0, $1.value) }) * CGFloat.pi * 2
        }
    }
    var lineWidth: CGFloat = 50
    
    override func layoutSublayers() {
        super.layoutSublayers()
        self.setNeedsDisplay()
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "maxArcAngle" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    override func action(forKey event: String) -> CAAction? {
        if event == "maxArcAngle" {
            let animation = CABasicAnimation(keyPath: event)
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animation.duration = animationDuration
            animation.fromValue = 0
            return animation
        }
        return super.action(forKey: event)
    }
    
    override func display() {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()
        
        var startAngle: CGFloat = 0
        
        ctx!.setLineWidth(lineWidth)

        let radius:CGFloat = (fmin(self.bounds.size.height, self.bounds.size.width)) / 2
        
        for info in values {
            startAngle = drawArcForInfo(info: info, ctx: ctx, startAngle: startAngle, center: self.bounds.center,
                                        radius: radius)
        }
        
        self.contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        UIGraphicsEndImageContext()
    }
    
    private func drawArcForInfo(info: PieArcInfo, ctx: CGContext?, startAngle: CGFloat, center: CGPoint, radius: CGFloat) -> CGFloat {
        let maxArcAngle = self.presentation()?.maxArcAngle ?? 0
        let angle = fmin(CGFloat(Double(info.value) * .pi * 2), maxArcAngle)
        let padding = fmin(angle, arcPadding)
        let endAngle = startAngle + angle - padding
        
        if extern! {
            ctx!.setStrokeColor(info.color.cgColor)

            ctx?.addArc(center: center, radius: radius - lineWidth/2, startAngle: startAngle, endAngle: endAngle,
                        clockwise: false)
            ctx!.drawPath(using: .stroke)
        } else {
            ctx!.setFillColor(info.color.cgColor)
            ctx?.move(to: center)
            ctx?.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            ctx?.fillPath()
        }
        
        return endAngle + padding
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: minX + width / 2, y: minY + height / 2)
    }
}
