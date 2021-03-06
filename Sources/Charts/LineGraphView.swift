//
//  LineGraphView.swift
//  ChartsApp
//
//  Created by Flaviu Silaghi on 23/02/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit

public class LineGraphView: UIView,GraphInputTableDelegate {
    
    private var graphInset: UIEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0)
    private var renderer: AxisRenderer?
    private let animationDuration: CFTimeInterval = 0.5
    private let plotWidth: CGFloat = 6
    private var backLayers: [CAShapeLayer] = []
    private var lineLayers: [CAShapeLayer] = []
    
    private var gridDataSource = LineOverlayDataSource()
    private var overlayLayer = OverlayLayer()
    private var graphContainerLayer = CAShapeLayer()
    private var backgroundLayer = CALayer()
    
    private var controldistanceFactor: CGFloat = 0.5 {
        didSet {
            updateGraphs(animated: false)
        }
    }
    
    /// Change graph line smoothness by setting the curving value betweend 0.0 and 1.0, where 1.0 is the maximum smoothness
    @IBInspectable public var curving: Float = 1 {
        didSet {
            controldistanceFactor = fmin(fmax(CGFloat(curving), 0), 1) / 2
        }
    }
    
    /// Data source for Line Graph 
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
    
   public override init(frame: CGRect) {
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
        
        for lineLayer in lineLayers {
            lineLayer.frame = graphFrame
        }
        
        for backLayer in backLayers {
            backLayer.frame = graphFrame
            if let maskLayout = backLayer.mask {
                maskLayout.frame = backLayer.bounds
            }
        }
        
        backgroundLayer.frame = bounds
        graphContainerLayer.frame = bounds
        overlayLayer.frame = graphFrame
        
        updateGraphs(animated: false)
        renderer?.render(minValue: inputTable?.min ?? Double(0), maxValue: inputTable?.max ?? Double(0))
    }
    
    // MARK : - Touch Handling
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first?.location(in: self)
        let graphFrame = UIEdgeInsetsInsetRect(self.bounds, graphInset)
        if graphFrame.contains(point!) {
            overlayLayer.opacity = 1 - overlayLayer.opacity
        }
    }
    
    // MARK: - GraphInputTableDelegate
    
    public func tableValuesDidChange(table: GraphInputTable) {
        updateGraphs(animated: true)
        renderer?.render(minValue: inputTable?.min ?? Double(0), maxValue: inputTable?.max ?? Double(0))
    }
    
    public func tableColumnsDidChange(table: GraphInputTable) {
        updateGraphs(animated: true)
        renderer?.render(minValue: inputTable?.min ?? Double(0), maxValue: inputTable?.max ?? Double(0))
    }
    
    public func tableRowsDidChange(table: GraphInputTable) {
        removeLayers()
        
        for row in table.rows {
            addLayers(row: row)
        }
        updateGraphs(animated: true)
    }
    
    public func tableRowTintColorDidChange(table: GraphInputTable, rowIndex: Int) {
        lineLayers[rowIndex].strokeColor = table.rows[rowIndex].tintColor.cgColor
    }
    
    // MARK: - Private methods
    
    private func setupGraph() {
        self.layer.addSublayer(backgroundLayer)
        self.layer.addSublayer(graphContainerLayer)
        self.layer.addSublayer(overlayLayer)
        overlayLayer.dataSource = gridDataSource
        overlayLayer.opacity = 0.0
    }
    
    private func removeLayers() {
        for lineLayer in lineLayers {
            lineLayer.removeFromSuperlayer()
        }
        
        for backLayer in backLayers {
            backLayer.removeFromSuperlayer()
        }
        
        backLayers = []
        lineLayers = []
    }
    
    private func addLayers(row: GraphInputRow) {
        let backLayer = CAShapeLayer()
        backLayer.fillColor = row.tintColor.withAlphaComponent(0.6).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0, 0.9, 1]
        backLayer.mask = gradientLayer
        
        let lineLayer = CAShapeLayer()
        lineLayer.strokeColor = row.tintColor.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineCap = kCALineCapRound
        lineLayer.lineJoin = kCALineJoinRound
        lineLayer.lineWidth = 3
        
        graphContainerLayer.addSublayer(backLayer)
        graphContainerLayer.addSublayer(lineLayer)
        
        backLayers.append(backLayer)
        lineLayers.append(lineLayer)
        
    }
    
    private func updateGraphs(animated: Bool) {
        overlayLayer.reloadData(animated: false)
        for (index, _) in lineLayers.enumerated() {
            updateGraph(index: index, animated: animated)
        }
    }
    
    private func updateGraph(index: Int, animated: Bool) {
        guard let points = inputTable?[index].values else {
            return
        }
        let lineLayer = lineLayers[index]
        let backLayer = backLayers[index]
        
        let count = points.count
        if count < 2 {
            lineLayer.path = nil
            backLayer.path = nil
            return
        }
        
        let bezierPath = UIBezierPath()
        let stepWidth = lineLayer.frame.width / (CGFloat(count) - 1)
        let startPoint = CGPoint(x: 0, y: (1 - points[Int(0)]) * lineLayer.frame.height)
        bezierPath.move(to: startPoint)
        
        for i in 0..<count - 1 {
            let startPoint = CGPoint(x: stepWidth * CGFloat(i), y: (1 - points[Int(i)]) * lineLayer.frame.height)
            let endPoint = CGPoint(x: stepWidth * (CGFloat(i) + 1), y: (1 - points[Int(i+1)]) * lineLayer.frame.height)
            let controlPoint1 = CGPoint(x: startPoint.x + stepWidth * controldistanceFactor, y: startPoint.y)
            let controlPoint2 = CGPoint(x: endPoint.x - stepWidth * controldistanceFactor, y: endPoint.y)
            bezierPath.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
        
        lineLayer.path = bezierPath.cgPath
        
        if animated {
            let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathAnimation.duration = animationDuration
            pathAnimation.fromValue = 0
            pathAnimation.toValue = 1
            lineLayer.add(pathAnimation, forKey: "strokeEndAnimation")
        }
        
        bezierPath.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
        bezierPath.addLine(to: CGPoint(x: 0, y: self.bounds.size.height))
        bezierPath.addLine(to: CGPoint(x: 0, y: points.first! * self.bounds.size.height))
        bezierPath.close()
        
        backLayer.path = (bezierPath.copy() as AnyObject).cgPath
        
        if animated {
            let gradientAnimation = CABasicAnimation(keyPath: "locations")
            gradientAnimation.duration = animationDuration
            gradientAnimation.fromValue = [0, 0, 0]
            gradientAnimation.toValue = [0, 0.9, 1]
            backLayer.mask!.add(gradientAnimation, forKey: "locations")
        }
    }
    
    func addAxis() {
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

}
