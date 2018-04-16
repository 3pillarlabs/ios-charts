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
    var lineColor: CGColor = UIColor.black.cgColor
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
        renderXAxis(frame: layer.frame)
        renderYAxis(frame: layer.frame)
        if properties.displayGrid { renderGrid(frame: layer.frame) }
    }
    
    //MARK: Private
    
    private func renderYAxis(frame: CGRect) {
        yAxis.frame = CGRect(x: 0, y: 0, width: 1, height: frame.height)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: properties.axisInset.left, y: 0))
        path.addLine(to: CGPoint(x: properties.axisInset.left, y: frame.height - properties.axisInset.bottom))
        path.close()
        yAxis.path = path.cgPath
        yAxis.lineWidth = 1
        yAxis.strokeColor = properties.lineColor
        layer.addSublayer(yAxis)
    }
    
    private func renderXAxis(frame: CGRect) {
        xAxis.frame = CGRect(x: 0, y: 0, width: frame.width, height: 1)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: properties.axisInset.left, y: frame.height - properties.axisInset.bottom))
        path.addLine(to: CGPoint(x: frame.width, y: frame.height - properties.axisInset.bottom))
        path.close()
        xAxis.path = path.cgPath
        xAxis.lineWidth = 1
        xAxis.strokeColor = properties.lineColor
        layer.addSublayer(xAxis)
    }
    
    private func renderGrid(frame: CGRect) {
        let maxAnimationDuration = kMinAnimationDuration * Double(properties.gridLines + 1)
        gridLayer.sublayers?.removeAll()
        gridLayer.frame = CGRect(origin: CGPoint.zero, size: frame.size)
        
        let step: CGFloat = (frame.height - properties.axisInset.bottom) / CGFloat(properties.gridLines + 1)
        let value = (max - min) / Double(properties.gridLines + 1)
        for i in 1...properties.gridLines {
            let y = step * CGFloat(i)
            let textFrame = CGRect(x: 0, y: y, width: properties.axisInset.left - 5, height: 15)
            let labelValue = min + (value * Double(properties.gridLines + 1 - i))
            let textLayer = renderLabel(string: formatValue(value: labelValue))
            textLayer.frame = textFrame
            animate(layer: textLayer, duration: maxAnimationDuration - kMinAnimationDuration * Double(i))
            
            let lineFrame = CGRect(x: 0, y: y, width: frame.width, height: 1)
            let lineLayer = renderLine(width: frame.width)
            lineLayer.frame = lineFrame
            
            gridLayer.addSublayer(textLayer)
            gridLayer.addSublayer(lineLayer)
        }
        
        self.layer.addSublayer(gridLayer)
    }
    
    private func renderLabel(string: String) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.alignmentMode = kCAAlignmentRight
        textLayer.string = string
        textLayer.fontSize = 12
        textLayer.foregroundColor = UIColor.black.cgColor
        return textLayer
    }
    
    func renderLine(width: CGFloat) -> CAShapeLayer {
        let lineLayer = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: properties.axisInset.left, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0 ))
        path.close()
        lineLayer.path = path.cgPath
        lineLayer.fillColor = UIColor.clear.cgColor
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
        layer.add(animation, forKey: "position.x")
    }
}
