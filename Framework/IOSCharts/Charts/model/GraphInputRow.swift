//
//  GraphInputRow.swift
//  ChartsApp
//
//  Created by Gil Eluard on 16/02/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit

public class GraphInputRow: NSObject {
   /// Set row name
   public var name = ""
    
   /// Set tint color for Row
   public var tintColor = UIColor.blackColor() {
        didSet {
            delegate?.rowTintColorDidChange(self)
        }
    }
    
   /// Array of values in a row
   public var values: [Double] = [] {
        didSet {
            computeMinMax()
            delegate?.rowValuesDidChange(self)
        }
    }
    private(set) var min: Double = 0
    private(set) var max: Double = 0
    private(set) var total: Double = 0
    
    weak var delegate: GraphInputRowDelegate?
    
    // MARK: - business methods
    
   public convenience init(name: String) {
        self.init(name: name, tintColor: nil)
    }
    
   public convenience init(name: String, tintColor: UIColor?) {
        self.init(name: name, tintColor: tintColor, values:[])
    }
    
   public init(name: String, tintColor: UIColor?, values:[Double]) {
        super.init()
        
        self.name = name
        self.values = values
        self.tintColor = tintColor ?? UIColor.blackColor()
        computeMinMax()
    }
    
    // MARK: - private methods
    
    private func computeMinMax() {
        var min: Double = DBL_MAX
        var max: Double = 0
        var total: Double = 0
        
        for value in values {
            min = fmin(min, value)
            max = fmax(max, value)
            total += value
        }
        
        self.min = min
        self.max = max
        self.total = total
    }
}
