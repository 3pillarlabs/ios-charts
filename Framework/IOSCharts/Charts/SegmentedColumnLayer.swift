//
//  SegmentedColumnLayer.swift
//  ChartsApp
//
//  Created by Gil Eluard on 29/02/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit

let kSeparatorLineHeight = CGFloat(1.0)

struct SegmentedColumnInfo {
    var value: CGFloat
    var color: UIColor
}

class SegmentedColumnLayer: CALayer {
    @NSManaged var maxSegmentHeight: CGFloat
    
    var animationDuration: CFTimeInterval = 0.5
    var values: [SegmentedColumnInfo] = [] {
        willSet {
            if let sublayers = self.sublayers {
                for layer in sublayers {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        didSet {
            for info in values {
                let layer = CALayer()
                layer.backgroundColor = info.color.CGColor
                self.addSublayer(layer)
            }
        }
    }
    
    // MARK: - Business layer
    
    override func layoutSublayers() {
        super.layoutSublayers()
        maxSegmentHeight = round(values.reduce(0, combine: {CGFloat(fmaxf(Float($0), Float($1.value)))}) * self.bounds.size.height)
    }
    
    override class func needsDisplayForKey(key: String) -> Bool {
        if key == "maxSegmentHeight" {
            return true
        }
        return super.needsDisplayForKey(key)
    }
    
    override func actionForKey(event: String) -> CAAction? {
        if event == "maxSegmentHeight" {
            let animation = CABasicAnimation(keyPath: event)
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animation.duration = animationDuration
            animation.fromValue = self.maxSegmentHeight
            return animation
        }
        return super.actionForKey(event)
    }
    
    override func display() {
        let maxSegmentHeight = self.presentationLayer()?.maxSegmentHeight ?? 0
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        var heightSum: CGFloat = 0
        if let sublayers = self.sublayers {
            for (index, layer) in sublayers.enumerate() {
                let height = fmin(CGRectGetHeight(self.bounds) * values[index].value, maxSegmentHeight)
                layer.frame = CGRect(x: 0, y: CGRectGetHeight(self.bounds) - heightSum - height + kSeparatorLineHeight, width: CGRectGetWidth(self.bounds), height: height - kSeparatorLineHeight)
                heightSum += height
            }
        }
        
        CATransaction.commit()
    }
}
