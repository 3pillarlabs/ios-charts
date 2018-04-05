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
                layer.backgroundColor = info.color.cgColor
                self.addSublayer(layer)
            }
        }
    }
    
    // MARK: - Business layer
    
    override func layoutSublayers() {
        super.layoutSublayers()

        let maxHeight = values.reduce(0, { max($0, $1.value)  })
        maxSegmentHeight = round(maxHeight * self.bounds.size.height)
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "maxSegmentHeight" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    override func action(forKey event: String) -> CAAction? {
        if event == "maxSegmentHeight" {
            let animation = CABasicAnimation(keyPath: event)
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animation.duration = animationDuration
            animation.fromValue = self.maxSegmentHeight
            return animation
        }
        return super.action(forKey: event)
    }
    
    override func display() {
        let maxSegmentHeight = self.presentation()?.maxSegmentHeight ?? 0
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        var heightSum: CGFloat = 0
        if let sublayers = self.sublayers {
            for (index, layer) in sublayers.enumerated() {
                let height = fmin(self.bounds.height * values[index].value, maxSegmentHeight)
                layer.frame = CGRect(x: 0, y: self.bounds.height - heightSum - height + kSeparatorLineHeight,
                                     width: self.bounds.width, height: height - kSeparatorLineHeight)
                heightSum += height
            }
        }
        
        CATransaction.commit()
    }
}
