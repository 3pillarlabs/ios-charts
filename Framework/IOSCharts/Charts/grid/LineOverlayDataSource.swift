//
//  LineGridDataSource.swift
//  ChartsApp
//
//  Created by Flaviu Silaghi on 02/03/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit

class LineOverlayDataSource: NSObject,OverlayDataSource {
    var inputTable: GraphInputTable?
    
    func gridProperties(bounds: CGRect) -> [ValueProperties] {
        var propertiesArray: [ValueProperties] = []
        for(var index = 0; index < inputTable?.rows.count; index++){
            guard let points = inputTable?[index].values else {
                break
            }
            let count = CGFloat(points.count)
            let stepWidth = CGRectGetWidth(bounds) / (count - 1)
            for var i = CGFloat(1) ; i < count ; i++ {
                let startPoint = CGPoint(x: stepWidth * i, y: (1 - CGFloat(points[Int(i)])) * CGRectGetHeight(bounds))
                var property = ValueProperties()
                property.startPoint = startPoint
                let row = inputTable?.rows[index]
                let value = inputTable?.rows[index].values[Int(i)] ?? 0
                property.text = "\(value)"
                let color = row?.tintColor ?? UIColor.blackColor()
                property.textAttributes = [NSForegroundColorAttributeName: color, NSFontAttributeName: UIFont.systemFontOfSize(8)]
                property.pointColor = color
                propertiesArray.append(property)
            }
        }
        
        return propertiesArray
    }
}
