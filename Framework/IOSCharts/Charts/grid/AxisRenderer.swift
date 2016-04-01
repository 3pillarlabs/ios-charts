//
//  AxisRenderer.swift
//  ChartsApp
//
//  Created by Flaviu Silaghi on 24/02/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit

let kMinAnimationDuration = 0.15

struct AxisProperties {
    var lineColor: CGColorRef = UIColor.blackColor().CGColor
    var lineWidth: CGFloat = 1
    var displayGrid: Bool = false
    var gridLines: Int = 5
    var axisInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
}

class AxisRenderer: NSObject {
    
    private let layer: CALayer
    private let properties: AxisProperties
    private var yAxis = CAShapeLayer()
    private var xAxis = CAShapeLayer()
    private var gridLayer = CALayer()
    private var min: Double = 0
    private var max: Double = 0
    
    init(chartLayer: CALayer, axisProperties: AxisProperties) {
        layer = chartLayer
        properties = axisProperties
    }
    
    func render(minValue: Double, maxValue: Double) {
        min = minValue
        max = maxValue
        renderXAxis(layer.frame)
        renderYAxis(layer.frame)
        if properties.displayGrid { renderGrid(layer.frame) }
    }
    
    //MARK: Private
    
    private func renderYAxis(frame: CGRect) {
        yAxis.frame = CGRectMake(0, 0, 1, CGRectGetHeight(frame))
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: properties.axisInset.left, y: 0))
        path.addLineToPoint(CGPoint(x: properties.axisInset.left, y: CGRectGetHeight(frame) - properties.axisInset.bottom))
        path.closePath()
        yAxis.path = path.CGPath
        yAxis.lineWidth = 1
        yAxis.strokeColor = properties.lineColor
        layer.addSublayer(yAxis)
    }
    
    private func renderXAxis(frame: CGRect) {
        xAxis.frame = CGRectMake(0, 0, CGRectGetWidth(frame), 1)
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: properties.axisInset.left, y: CGRectGetHeight(frame) - properties.axisInset.bottom))
        path.addLineToPoint(CGPoint(x: CGRectGetWidth(frame), y: CGRectGetHeight(frame) - properties.axisInset.bottom))
        path.closePath()
        xAxis.path = path.CGPath
        xAxis.lineWidth = 1
        xAxis.strokeColor = properties.lineColor
        layer.addSublayer(xAxis)
    }
    
    private func renderGrid(frame: CGRect) {
        let maxAnimationDuration = kMinAnimationDuration * Double(properties.gridLines + 1)
        gridLayer.sublayers?.removeAll()
        gridLayer.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))
        
        let step: CGFloat = (CGRectGetHeight(frame) - properties.axisInset.bottom) / CGFloat(properties.gridLines + 1)
        let value = (max - min) / Double(properties.gridLines + 1)
        for i in 1...properties.gridLines {
            let y = step * CGFloat(i)
            let textFrame = CGRectMake(0, y, properties.axisInset.left - 5, 15)
            let labelValue = min + (value * Double(properties.gridLines + 1 - i))
            let textLayer = renderLabel(formatValue(labelValue))
            textLayer.frame = textFrame
            animate(textLayer, duration: maxAnimationDuration - kMinAnimationDuration * Double(i))
            
            let lineFrame = CGRectMake(0, y, CGRectGetWidth(frame), 1)
            let lineLayer = renderLine(CGRectGetWidth(frame))
            lineLayer.frame = lineFrame
            
            gridLayer.addSublayer(textLayer)
            gridLayer.addSublayer(lineLayer)
        }
        
        self.layer.addSublayer(gridLayer)
    }
    
    private func renderLabel(string: String) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.contentsScale = UIScreen.mainScreen().scale
        textLayer.alignmentMode = kCAAlignmentRight
        textLayer.string = string
        textLayer.fontSize = 12
        textLayer.foregroundColor = UIColor.blackColor().CGColor
        return textLayer
    }
    
    func renderLine(width: CGFloat) -> CAShapeLayer {
        let lineLayer = CAShapeLayer()
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: properties.axisInset.left, y: 0))
        path.addLineToPoint(CGPoint(x: width, y: 0 ))
        path.closePath()
        lineLayer.path = path.CGPath
        lineLayer.fillColor = UIColor.clearColor().CGColor
        lineLayer.strokeColor = properties.lineColor
        lineLayer.lineWidth = 0.2
        return lineLayer
    }
    
    func formatValue(value: Double) -> String {
        return value < 10 ? String(format: "%.0f", value) : String(format: "%.1f",value)
    }
    
    private func animate(layer: CALayer, duration: Double) {
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.duration = duration
        animation.fromValue = -100.0
        animation.toValue = layer.frame.origin.x
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        layer.addAnimation(animation, forKey: "position.x")
    }
}
