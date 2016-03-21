//
//  StackedBarOverlayDataSource.swift
//  ChartsApp
//
//  Created by Norbert Agoston on 04/03/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit

let kMinValueOveralyHeight = CGFloat(15.0)
let kMinValueOverlayWidth = CGFloat(18.0)
let kEmptyString = ""

class StackedBarOverlayDataSource: NSObject,OverlayDataSource {
    var inputTable: GraphInputTable?
    
    func gridProperties(bounds: CGRect) -> [ValueProperties] {
        var propertiesArray: [ValueProperties] = []
        
        guard let inputTable = inputTable else {
            return []
        }
        
        var x: CGFloat = 0.0
        let segmentWidth = (CGRectGetWidth(bounds) - kStackedBarChartPadding * (CGFloat(inputTable.columnNames.count) - 1) ) / CGFloat(inputTable.columnNames.count)
        
        for (columnIndex, _) in inputTable.columnNames.enumerate() {
            let columnFrame = CGRect(x: x, y: 0, width: segmentWidth, height: CGRectGetHeight(bounds))
            x += segmentWidth + kStackedBarChartPadding
            
            var heightSum: CGFloat = 0
            let normalizedValues = inputTable.normalizedValuesForColumn(columnIndex)
            
            for (rowIndex, row) in inputTable.rows.enumerate() {
                let normalizedValue = normalizedValues[rowIndex]
                let segmentHeight = CGRectGetHeight(bounds) * normalizedValue
                
                let xCenteredOffset = columnFrame.origin.x + CGRectGetWidth(columnFrame) / 2
                let yCenteredOffset = CGRectGetHeight(columnFrame) - heightSum - (segmentHeight / 2)
                let startPoint = CGPoint(x: xCenteredOffset , y: yCenteredOffset)
                heightSum += segmentHeight
                
                let barColor = row.tintColor
                
                var property = ValueProperties()
                property.startPoint = startPoint
                property.textPosition = .Centered
                property.textAttributes = [NSForegroundColorAttributeName: barColor.determineAReadableTextColor(),NSFontAttributeName: UIFont.systemFontOfSize(8)]
                property.pointColor = UIColor.clearColor()
                property.text = segmentHeight > kMinValueOveralyHeight && segmentWidth > kMinValueOverlayWidth ? "\(row.values[columnIndex])" : kEmptyString
                propertiesArray.append(property)
            }
        }
        
        return propertiesArray
    }
}