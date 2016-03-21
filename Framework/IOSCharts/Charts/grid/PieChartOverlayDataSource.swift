//
//  PieChartOverlayDataSource.swift
//  ChartsApp
//
//  Created by Valentina Iancu on 03/03/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit

struct PieDataSourceInfo {
    var value: CGFloat
    var color: UIColor
    var text: String
}

class PieChartOverlayDataSource: NSObject, OverlayDataSource {
    var inputTable: GraphInputTable?
    var lineWidth: CGFloat = 50
    
    func gridProperties(bounds: CGRect) -> [ValueProperties] {
        guard let inputTable = inputTable else {
            return []
        }
        
        var propertiesArray: [ValueProperties] = []
        
        let center = CGPointMake(CGRectGetWidth(bounds) / 2, CGRectGetHeight(bounds) / 2)
        let columnRadius:CGFloat = (fmin(bounds.size.height, bounds.size.width)) / 2
        let rowRadius:CGFloat = columnRadius - lineWidth * 1.5
        
        var rowInfos: [PieDataSourceInfo] = []
        var columnInfos: [PieDataSourceInfo] = []
        for (rowIndex, row) in inputTable.rows.enumerate() {
            if row.values.count > 0 {
                rowInfos.append(PieDataSourceInfo(value:inputTable.percentOfRowAtIndex(rowIndex), color: row.tintColor, text: row.name))
                for (columnIndex, _) in inputTable.columnNames.enumerate() {
                    columnInfos.append(PieDataSourceInfo(value: inputTable.percentOfColumn(columnIndex, rowIndex: rowIndex), color: row.tintColor, text: "\(row.values[columnIndex])"))
                }
            }
        }
        
        propertiesArray.appendContentsOf(propertiesForPieInfos(rowInfos, center: center, radius: rowRadius, extern: false))
        propertiesArray.appendContentsOf(propertiesForPieInfos(columnInfos, center: center, radius: columnRadius, extern: true))
        
        return propertiesArray
    }
    
    // MARK: - Private methods

    private func propertiesForPieInfos(infos: [PieDataSourceInfo], center: CGPoint, radius: CGFloat, extern: Bool) -> [ValueProperties] {
        var propertiesArray: [ValueProperties] = []
        var startAngle: CGFloat = 0
        let maxArcAngle = infos.reduce(0, combine: {fmaxf($0, Float($1.value))}) * Float(M_PI * 2)
        
        for info in infos {
            let angle = fmin(CGFloat(Double(info.value) * M_PI * 2), CGFloat(maxArcAngle))
            
            if info.value < 0.01 {
                startAngle += angle
                continue
            }
            
            var property = ValueProperties()
            let labelAngle = startAngle + angle / 2
            let labelX = center.x + radius * cos(labelAngle)
            let labelY = center.y + radius * sin(labelAngle)
            let startPoint = CGPoint(x:  labelX, y: labelY )
            
            property.text = info.text
            property.textAttributes.updateValue(UIColor.blackColor().CGColor, forKey: NSForegroundColorAttributeName)
            property.pointColor = UIColor.clearColor()
            property.lineColor = info.color
            if extern {
                let onTheLeft = center.x - startPoint.x >= 0
                property.startPoint = startPoint
                property.endPoint = onTheLeft ? CGPoint(x: startPoint.x - 20, y: startPoint.y) : CGPoint(x: startPoint.x + 20, y: startPoint.y)
                property.textPosition = onTheLeft ? .Left : .Right
            } else {
                property.startPoint = startPoint
                property.textPosition = .Centered
            }
            propertiesArray.append(property)
            
            startAngle += angle
        }
        
        return propertiesArray
    }
}
