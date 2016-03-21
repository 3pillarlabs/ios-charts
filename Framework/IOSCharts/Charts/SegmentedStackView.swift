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
                tableRowsDidChange(inputTable)
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
        
        arrangeHorizontally(numberOfBars, toFit: graphFrame)
        backgroundLayer.frame = bounds
        graphContainerLayer.frame = bounds
        overlayLayer.frame = graphFrame
        addGradientToGraph()
        updateGraphs(false)
        renderer?.render( Double(0), maxValue: inputTable.maxTotalPerColumn ?? Double(0))
    }
    
    // MARK: - GraphInputTableDelegate
    
    public func tableValuesDidChange(table: GraphInputTable) {
        updateGraphs(true)
        renderer?.render( Double(0), maxValue: inputTable!.maxTotalPerColumn ?? Double(0))
    }
    
    public func tableColumnsDidChange(table: GraphInputTable) {
        removeLayers()
        addLayers()
        updateGraphs(true)
        renderer?.render( Double(0), maxValue: inputTable!.maxTotalPerColumn ?? Double(0))
    }
    
    public func tableRowsDidChange(table: GraphInputTable) {
        addLayers()
        updateGraphs(true)
    }
    
    public func tableRowTintColorDidChange(table: GraphInputTable, rowIndex: Int) {
        updateGraphs(false)
    }
    
    // MARK: - Private methods
    
    private func addAxis() {
        var properties:AxisProperties = AxisProperties()
        properties.lineColor = UIColor.orangeColor().CGColor
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
        let segmentWidth = (CGRectGetWidth(graphFrame) - kStackedBarChartPadding * (numberOfBars - 1) ) / numberOfBars
        for columnLayer in columnLayers {
            columnLayer.frame = CGRect(x: x, y: 0, width: segmentWidth, height: CGRectGetHeight(graphFrame))
            x += segmentWidth + kStackedBarChartPadding
        }
    }
    
    private func addGradientToGraph() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = graphContainerLayer.bounds
        gradientLayer.colors = [UIColor.blackColor().CGColor,UIColor.blackColor().colorWithAlphaComponent(0.7).CGColor ,UIColor.clearColor().CGColor]
        gradientLayer.locations = [0.0,0.9,1.0]
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
        for (index, _) in columnLayers.enumerate() {
            updateGraph(index, animated: animated)
        }
    }
    
    private func updateGraph(index: Int, animated: Bool) {
        guard let points = inputTable?.normalizedValuesForColumn(index) else {
            return
        }
        
        let columnLayer = columnLayers[index]
        
        var index = -1
        columnLayer.values = points.map({
            index++
            return SegmentedColumnInfo(value: $0, color: (inputTable?.rows[index].tintColor)!)
        })
    }
}