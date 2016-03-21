//
//  PieChartView.swift
//  ChartsApp
//
//  Created by Valentina Iancu on 22/02/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit

public class PieChartView: UIView, GraphInputTableDelegate {
    
    private let animationDuration: CFTimeInterval = 0.5
    private var contentLayer = CALayer()
    private var rowSliceLayer = PieArcLayer()
    private var columnSliceLayer = PieArcLayer()
    private var overlayLayer = OverlayLayer()
    private var gridDataSource = PieChartOverlayDataSource()
    
    /// Data source for Pie Chart 
    public var inputTable: GraphInputTable? {
        didSet {
            if let inputTable = inputTable {
                inputTable.delegate = self
                gridDataSource.inputTable = inputTable
                tableRowsDidChange(inputTable)
            }
        }
    }
    
    // MARK: - Business methods
    
   public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        setupView()
    }
    
   public override  func layoutSubviews() {
        super.layoutSubviews()
        
        let lineWidth = fmin(self.bounds.size.width, self.bounds.size.height) / 6
        let graphFrame = self.bounds
        contentLayer.frame = graphFrame
        if let mask = contentLayer.mask {
            mask.frame = contentLayer.bounds
        }
        columnSliceLayer.frame = contentLayer.bounds
        columnSliceLayer.lineWidth = lineWidth
        rowSliceLayer.frame = CGRectInset(contentLayer.bounds, lineWidth + 1, lineWidth + 1)
        rowSliceLayer.lineWidth = lineWidth
        gridDataSource.lineWidth = lineWidth
        overlayLayer.frame = graphFrame
        
        updateSlices(false)
    }
    
    // MARK: - GraphInputTableDelegate
    
    public func tableValuesDidChange(table: GraphInputTable) {
        updateSlices(true)
    }
    
    public func tableColumnsDidChange(table: GraphInputTable) {
        updateSlices(true)
    }
    
    public func tableRowsDidChange(table: GraphInputTable) {
        updateSlices(true)
    }
    
    public func tableRowTintColorDidChange(table: GraphInputTable, rowIndex: Int) {
        updateSlices(true)
    }
    
    // MARK: - Private methods
    
    private func updateSlices(animated: Bool) {
        guard let inputTable = inputTable else {
            rowSliceLayer.values = []
            return
        }
        overlayLayer.reloadData(animated: true)
        var rowInfos: [PieArcInfo] = []
        var columnInfos: [PieArcInfo] = []
        for (rowIndex, row) in inputTable.rows.enumerate() {
            rowInfos.append(PieArcInfo(value: inputTable.percentOfRowAtIndex(rowIndex), color: row.tintColor))
            for (columnIndex, _) in inputTable.columnNames.enumerate() {
                columnInfos.append(PieArcInfo(value: inputTable.percentOfColumn(columnIndex, rowIndex: rowIndex), color: row.tintColor))
            }
        }
        rowSliceLayer.values = rowInfos
        columnSliceLayer.values = columnInfos
    }
    
    private func setupView() {
        rowSliceLayer.animationDuration = animationDuration
        rowSliceLayer.extern = false
        
        columnSliceLayer.animationDuration = animationDuration
        columnSliceLayer.extern = true
        
        contentLayer.addSublayer(rowSliceLayer)
        contentLayer.addSublayer(columnSliceLayer)
        
        let gradientLayer = RadialGradientLayer()
        gradientLayer.colors = [UIColor.clearColor().CGColor, UIColor(white: 1, alpha: 0.6).CGColor, UIColor.whiteColor().CGColor]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.frame = contentLayer.bounds
        contentLayer.mask = gradientLayer
        
        self.layer.addSublayer(contentLayer)
        
        self.layer.addSublayer(overlayLayer)
        overlayLayer.dataSource = gridDataSource
        overlayLayer.opacity = 1.0
    }
    
    private func DegreesToRadians (value:Double) -> Double {
        return value * M_PI / 180.0
    }
    
    private func minSize(rect: CGRect) -> CGFloat {
        return CGFloat(fminf(Float(CGRectGetWidth(rect)), Float(CGRectGetHeight(rect))))
    }
}
