//
//  SegmentedStackView.swift
//  ChartsApp
//
//  Created by Norbert Agoston on 22/02/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit

let kStackedBarChartPadding = CGFloat(5.0)

public class SegmentedStackView: UIView, GraphInputTableDelegate {
    
    private let animationDuration: CFTimeInterval = 0.5
    private var graphInset: UIEdgeInsets = UIEdgeInsetsMake(0, 35, 0, 0)
    private var columnLayers: [SegmentedColumnLayer] = []
    private var renderer: AxisRenderer?
    private var gridDataSource = StackedBarOverlayDataSource()
    private var overlayLayer = OverlayLayer()
    private var graphContainerLayer = CAShapeLayer()
    private var backgroundLayer = CALayer()
    
    /// Data source for Segmented Stack Graph 
    public var inputTable: GraphInputTable? {
        didSet {
            if let inputTable = inputTable {
                inputTable.delegate = self
                gridDataSource.inputTable = inputTable
                tableRowsDidChange(table: inputTable)
            } else {
                removeLayers()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addAxis()
        setupGraph()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addAxis()
        setupGraph()
    }
    
    // MARK: - Business methods
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let graphFrame = UIEdgeInsetsInsetRect(self.bounds, graphInset)
        
        guard let inputTable = inputTable else {
            return
        }
        
        let numberOfBars = CGFloat(inputTable.columnNames.count)
        
        arrangeHorizontally(numberOfBars: numberOfBars, toFit: graphFrame)
        backgroundLayer.frame = bounds
        graphContainerLayer.frame = bounds
        overlayLayer.frame = graphFrame
        addGradientToGraph()
        updateGraphs(animated: false)
        renderer?.render( minValue: Double(0), maxValue: inputTable.maxTotalPerColumn )
    }
    
    // MARK: - GraphInputTableDelegate
    
    public func tableValuesDidChange(table: GraphInputTable) {
        updateGraphs(animated: true)
        renderer?.render( minValue: Double(0), maxValue: inputTable!.maxTotalPerColumn )
    }
    
    public func tableColumnsDidChange(table: GraphInputTable) {
        removeLayers()
        addLayers()
        updateGraphs(animated: true)
        renderer?.render( minValue: Double(0), maxValue: inputTable!.maxTotalPerColumn )
    }
    
    public func tableRowsDidChange(table: GraphInputTable) {
        addLayers()
        updateGraphs(animated: true)
    }
    
    public func tableRowTintColorDidChange(table: GraphInputTable, rowIndex: Int) {
        updateGraphs(animated: false)
    }
    
    // MARK: - Private methods
    
    private func addAxis() {
        var properties:AxisProperties = AxisProperties()
        properties.lineColor = UIColor.orange.cgColor
        properties.lineWidth = 1
        properties.displayGrid = true
        properties.gridLines = 7
        properties.axisInset = graphInset
        
        if renderer == nil {
            renderer = AxisRenderer(chartLayer: backgroundLayer, axisProperties: properties)
        }
    }
    
    private func setupGraph() {
        self.layer.addSublayer(backgroundLayer)
        self.layer.addSublayer(graphContainerLayer)
        self.layer.addSublayer(overlayLayer)
        overlayLayer.dataSource = gridDataSource
        overlayLayer.opacity = 1.0
    }
    
    private func arrangeHorizontally(numberOfBars:CGFloat, toFit graphFrame: CGRect) {
        var x: CGFloat = graphFrame.origin.x
        let segmentWidth = (graphFrame.width - kStackedBarChartPadding * (numberOfBars - 1) ) / numberOfBars
        for columnLayer in columnLayers {
            columnLayer.frame = CGRect(x: x, y: 0, width: segmentWidth, height: graphFrame.height)
            x += segmentWidth + kStackedBarChartPadding
        }
    }
    
    private func addGradientToGraph() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = graphContainerLayer.bounds
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor,
                                UIColor.clear.cgColor]
        gradientLayer.locations = [0.0, 0.9, 1.0]
        graphContainerLayer.mask = gradientLayer
    }
    
    private func removeLayers() {
        for columnLayer in columnLayers {
            columnLayer.removeFromSuperlayer()
        }
        columnLayers = []
    }
    
    private func addLayers() {
        guard let inputTable = inputTable else {
            return
        }
        
        while (columnLayers.count < inputTable.columnNames.count) {
            let columnLayer = SegmentedColumnLayer()
            columnLayer.animationDuration = animationDuration
            graphContainerLayer.addSublayer(columnLayer)
            columnLayers.append(columnLayer)
        }
        self.setNeedsLayout()
    }
    
    private func updateGraphs(animated: Bool) {
        overlayLayer.reloadData(animated: true)
        for (index, _) in columnLayers.enumerated() {
            updateGraph(index: index, animated: animated)
        }
    }
    
    private func updateGraph(index: Int, animated: Bool) {
        guard let points = inputTable?.normalizedValuesForColumn(index: index) else {
            return
        }
        
        let columnLayer = columnLayers[index]
        
        var index = -1
        columnLayer.values = points.map({
            index += 1
            return SegmentedColumnInfo(value: $0, color: (inputTable?.rows[index].tintColor)!)
        })
    }
}
