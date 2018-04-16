//
//  ValueRenderer.swift
//  ChartsApp
//
//  Created by Flaviu Silaghi on 29/02/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit

enum TextPosition {
    case Top
    case Bottom
    case Left
    case Right
    case Centered
    
    func textPositionToPoint(point: CGPoint,textSize: CGSize, offset: CGFloat) -> CGPoint {
        switch self {
            case .Top:
                return CGPoint(x: point.x - textSize.width/2, y: point.y - textSize.height - offset)
            case .Bottom:
                return CGPoint(x: point.x - textSize.width/2, y: point.y + offset)
            case .Left:
                return CGPoint(x: point.x - textSize.width - offset, y: point.y - textSize.height/2)
            case .Right:
                return CGPoint(x: point.x + offset, y: point.y - textSize.height/2)
            case .Centered:
                return CGPoint(x: point.x - textSize.width/2,y: point.y - textSize.height/2)
        }
    }
}

struct ValueProperties{
    var startPoint: CGPoint?
    var endPoint: CGPoint?
    var lineColor: UIColor = UIColor.black
    var pointColor: UIColor = UIColor.black
    var textPosition: TextPosition = .Top
    var text: String = ""
    var textAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.black,
                                                        .font: UIFont.systemFont(ofSize: 8)]
    var pointSize: CGFloat = 6.0
}

class OverlayLayer: CAShapeLayer {
    
    var dataSource: OverlayDataSource?
    
    func reloadData(animated: Bool) {
        self.sublayers?.removeAll()
        
        let propertiesArray = dataSource?.gridProperties(bounds: frame) ?? []
        for property in propertiesArray {
            if let startPoint = property.startPoint {
                var textPoint = startPoint
                if let endPoint = property.endPoint {
                    renderLine(startPoint: startPoint, endPoint: endPoint, color: property.lineColor)
                    
                    switch (property.textPosition) {
                    case .Left: textPoint = startPoint.x <= endPoint.x ? startPoint : endPoint
                    case .Right: textPoint = startPoint.x > endPoint.x ? startPoint : endPoint
                    case .Centered: textPoint = CGPoint(x: fabs(startPoint.x - endPoint.x) / 2, y: fabs(startPoint.y - endPoint.y) / 2)
                    default: textPoint = startPoint
                    }
                } else {
                    renderPoint(point: startPoint, color: property.pointColor,pointSize: property.pointSize)
                }
                renderText(point: textPoint, text: property.text,textAttributes: property.textAttributes, position: property.textPosition,pointSize: property.pointSize)
            }
        }
        if animated {
            animateLayer()
        }
    }
    
    private func renderLine(startPoint: CGPoint, endPoint: CGPoint, color: UIColor) {
        let lineLayer: CAShapeLayer = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        path.close()
        lineLayer.path = path.cgPath
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = color.cgColor
        lineLayer.lineWidth = 1
        lineLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 1, height: 50))
        addSublayer(lineLayer)
    }
    
    private func renderPoint(point: CGPoint, color: UIColor, pointSize: CGFloat) {
        let pointLayer: CAShapeLayer = CAShapeLayer()
        let pointFrame = CGRect(origin: point, size: CGSize(width: pointSize, height: pointSize))
        let path = UIBezierPath(ovalIn: pointFrame)
        pointLayer.path = path.cgPath
        pointLayer.fillColor = color.cgColor
        pointLayer.frame = CGRect(origin: CGPoint(x: -pointSize/2, y: -pointSize/2), size: CGSize(width: pointSize, height: pointSize))
        addSublayer(pointLayer)
    }
    
    private func renderText(point: CGPoint,text: String,textAttributes:[NSAttributedStringKey: Any],position:TextPosition, pointSize: CGFloat) {
        let textLayer: CATextLayer =  CATextLayer()
        textLayer.contentsScale = UIScreen.main.scale
        let attributedString = NSAttributedString(string: text, attributes: textAttributes)
        textLayer.string = NSAttributedString(string: text, attributes: textAttributes)
        let textSize = attributedString.size()
        let textCenter = position.textPositionToPoint(point: point, textSize: textSize,offset: pointSize)
        textLayer.frame = CGRect(origin: textCenter, size: textSize)
        textLayer.alignmentMode = kCAAlignmentCenter
        addSublayer(textLayer)
    }
    
    private func animateLayer() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration =  1
        self.add(animation, forKey: "opacity")
    }
}
