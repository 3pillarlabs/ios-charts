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
        let numberOfRows: Int = inputTable?.rows.count ?? 0
        for index in 0..<numberOfRows {
            guard let points = inputTable?[index].values else {
                break
            }
            let count = points.count
            let stepWidth = bounds.width / (CGFloat(count) - 1)
            for i in 1  ..< count  {
                let startPoint = CGPoint(x: stepWidth * CGFloat(i), y: (1 - CGFloat(points[Int(i)])) * bounds.height)
                var property = ValueProperties()
                property.startPoint = startPoint
                let row = inputTable?.rows[index]
                let value = inputTable?.rows[index].values[Int(i)] ?? 0
                property.text = "\(value)"
                let color = row?.tintColor ?? UIColor.black
                property.textAttributes = [.foregroundColor: color, .font: UIFont.systemFont(ofSize: 8)]
                property.pointColor = color
                propertiesArray.append(property)
            }
        }
        
        return propertiesArray
    }
}
