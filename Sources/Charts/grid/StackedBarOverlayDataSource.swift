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
        let segmentWidth = (bounds.width - kStackedBarChartPadding * (CGFloat(inputTable.columnNames.count) - 1) ) / CGFloat(inputTable.columnNames.count)
        
        for (columnIndex, _) in inputTable.columnNames.enumerated() {
            let columnFrame = CGRect(x: x, y: 0, width: segmentWidth, height: bounds.height)
            x += segmentWidth + kStackedBarChartPadding
            
            var heightSum: CGFloat = 0
            let normalizedValues = inputTable.normalizedValuesForColumn(index: columnIndex)
            
            for (rowIndex, row) in inputTable.rows.enumerated() {
                let normalizedValue = normalizedValues[rowIndex]
                let segmentHeight = bounds.height * normalizedValue
                
                let xCenteredOffset = columnFrame.origin.x + columnFrame.width / 2
                let yCenteredOffset = columnFrame.height - heightSum - (segmentHeight / 2)
                let startPoint = CGPoint(x: xCenteredOffset , y: yCenteredOffset)
                heightSum += segmentHeight
                
                let barColor = row.tintColor
                
                var property = ValueProperties()
                property.startPoint = startPoint
                property.textPosition = .Centered
                property.textAttributes = [.foregroundColor: barColor.determineAReadableTextColor(),
                                           .font: UIFont.systemFont(ofSize: 8)]
                property.pointColor = UIColor.clear
                property.text = segmentHeight > kMinValueOveralyHeight && segmentWidth > kMinValueOverlayWidth ? "\(row.values[columnIndex])" : kEmptyString
                propertiesArray.append(property)
            }
        }
        
        return propertiesArray
    }
}
