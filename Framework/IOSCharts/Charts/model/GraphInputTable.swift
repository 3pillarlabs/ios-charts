//
//  GraphInputTable.swift
//  ChartsApp
//
//  Created by Gil Eluard on 16/02/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit

/// GraphInputTable plays the role of the data source for our graphs

public class GraphInputTable: NSObject, GraphInputRowDelegate {
    
    /// Table name
    public var name = ""
    
    /// Array with all the column names
    public var columnNames: [String] = [] {
        didSet {
            delegate?.tableColumnsDidChange(table: self)
        }
    }
    
   /// Array with all the rows in our data source
   public var rows: [GraphInputRow] = [] {
        didSet {
            computeMinMax()
            computeMaxTotalPerColumn()
            delegate?.tableRowsDidChange(table: self)
        }
    }
    private(set) var min: Double = 0
    private(set) var max: Double = 0
    private(set) var total: Double = 0
    private(set) var maxTotalPerColumn: Double = 0
    
    /// Array with all the row names
    public var rowNames: [String] {
        return rows.map({$0.name})
    }
    
    subscript(index: Int) -> (rowName: String, values:[CGFloat]) {
        let row = rows[index]
        return (row.name, row.values.map({CGFloat(($0 - min) / (max - min))}))
    }
    
    subscript(rowIndex: Int, columnIndex: Int) -> CGFloat {
        return CGFloat((rows[rowIndex].values[columnIndex] - min) / (max - min))
    }
    
    weak var delegate: GraphInputTableDelegate?
    
    // MARK: - Business methods
    
   public convenience init(name: String) {
        self.init(name: name, columnNames:[])
    }
    
   public init(name: String, columnNames:[String]) {
        super.init()
        
        self.name = name
        self.columnNames = columnNames
        computeMinMax()
        computeMaxTotalPerColumn()
    }
    /**
     Append a new column with the values specified in the rowValues array.
     
     - parameter columnName: add a custom name to the column
     - parameter rowValues: each array element is appended to its corresponding row by index
     */
   public func addColumn(columnName: String, rowValues: [Double]) {
        guard rowValues.count == rows.count else {
            print("GraphInputTable[addColumn]: wrong number of values \(rowValues.count) (expected \(rows.count))")
            return
        }
        
        let delegate = self.delegate
        self.delegate = nil;
        
        for (index, row) in rows.enumerated() {
            row.values.append(rowValues[index])
        }
        
        self.columnNames.append(columnName)
        
        computeMinMax()
        computeMaxTotalPerColumn()
        
        self.delegate = delegate
        delegate?.tableColumnsDidChange(table: self)
    }
    /**
     Remove a column at the specified index
     
     - parameter index: index of column that needs to be deleted
     */
    public func removeColumnAtIndex(index: Int) {
        guard index < rows.count && index >= 0 else {
            print("GraphInputTable[removeColumn]: wrong index \(index) for an array of \(rows.count) elements")
            return
        }
        
        let delegate = self.delegate
        self.delegate = nil
        
        for (index, row) in rows.enumerated() {
            row.values.remove(at: index)
        }
        
        self.columnNames.remove(at: index)
        
        if (rows.count > 0) {
            computeMinMax()
            computeMaxTotalPerColumn()
        } else {
            min = 0
            max = 0
            maxTotalPerColumn = 0
        }
        self.delegate = delegate
        delegate?.tableColumnsDidChange(table: self)
    }
    /**
     This will clean the entire data source
     */
    public func removeAllColumns() {
        let delegate = self.delegate
        self.delegate = nil
        
        for row in rows {
            row.values.removeAll()
        }
        
        min = 0
        max = 0
        maxTotalPerColumn = 0
        
        self.delegate = delegate
        self.columnNames.removeAll()
    }
    
    // MARK: - private methods
    
    private func computeMinMax() {
        var min: Double = .greatestFiniteMagnitude
        var max: Double = 0
        var total: Double = 0
        
        for row in rows {
            min = fmin(min, row.min)
            max = fmax(max, row.max)
            total += row.total
        }
        self.total = total
        self.min = min != .greatestFiniteMagnitude ? min : 0
        self.max = max
    }
    
    private func computeMaxTotalPerColumn() {
        maxTotalPerColumn = 0
        for (index, _) in columnNames.enumerated() {
            maxTotalPerColumn = fmax(maxTotalPerColumn, rows.reduce(0, {$0 + $1.values[index]}))
        }
    }
    
    func percentOfRowAtIndex(index: Int) -> CGFloat {
        let row = rows[index]
        return CGFloat(row.total/total)
    }

	func percentOfColumn(columnIndex: Int, rowIndex: Int) -> CGFloat {
        let value = rows[rowIndex].values[columnIndex]
        return CGFloat(value / total)
    }
    
    func normalizedValuesForColumn(index: Int) -> [CGFloat] {
        return (rows.map({
            normalize(value: $0.values[index])
        }))
    }
    
    func normalize(value: Double) -> CGFloat {
        return CGFloat(maxTotalPerColumn != 0 ? value / maxTotalPerColumn : 0)
    }
    
    // MARK: - GraphInputRowDelegate
    
    func rowValuesDidChange(row: GraphInputRow) {
        delegate?.tableValuesDidChange(table: self)
    }
    
    func rowTintColorDidChange(row: GraphInputRow) {
        if let index = rows.index(of: row) {
            delegate?.tableRowTintColorDidChange(table: self, rowIndex: index)
        }
    }
}
