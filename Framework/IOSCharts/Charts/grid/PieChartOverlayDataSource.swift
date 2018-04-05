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
        
        let center = bounds.center
        let columnRadius: CGFloat = min(bounds.width, bounds.height) / 2
        let rowRadius:CGFloat = columnRadius - lineWidth * 1.5
        
        var rowInfos: [PieDataSourceInfo] = []
        var columnInfos: [PieDataSourceInfo] = []
        for (rowIndex, row) in inputTable.rows.enumerated() {
            if row.values.count > 0 {
                rowInfos.append(PieDataSourceInfo(value:inputTable.percentOfRowAtIndex(index: rowIndex), color: row.tintColor, text: row.name))
                for (columnIndex, _) in inputTable.columnNames.enumerated() {
                    columnInfos.append(PieDataSourceInfo(value: inputTable.percentOfColumn(columnIndex: columnIndex, rowIndex: rowIndex), color: row.tintColor, text: "\(row.values[columnIndex])"))
                }
            }
        }

        propertiesArray.append(contentsOf: propertiesForPieInfos(infos: rowInfos, center: center, radius: rowRadius, extern: false))
        propertiesArray.append(contentsOf: propertiesForPieInfos(infos: columnInfos, center: center, radius: columnRadius, extern: true))
        
        return propertiesArray
    }
    
    // MARK: - Private methods

    private func propertiesForPieInfos(infos: [PieDataSourceInfo], center: CGPoint, radius: CGFloat, extern: Bool) -> [ValueProperties] {
        var propertiesArray: [ValueProperties] = []
        var startAngle: CGFloat = 0
        let maxArcAngle = infos.reduce(0, { max($0, $1.value) }) * .pi * 2
        
        for info in infos {
            let angle = fmin(CGFloat(Double(info.value) * .pi * 2), CGFloat(maxArcAngle))
            
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
            property.textAttributes.updateValue(UIColor.black, forKey: .foregroundColor)
            property.pointColor = UIColor.clear
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
