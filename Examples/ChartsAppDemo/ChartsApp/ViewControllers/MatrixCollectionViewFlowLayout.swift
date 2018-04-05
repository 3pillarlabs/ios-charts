//
//  MatrixCollectionViewFlowLayout.swift
//  ChartsApp
//
//  Created by Gil Eluard on 17/03/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit
import IOSCharts

class MatrixCollectionViewFlowLayout: UICollectionViewLayout {
    let inputTable: GraphInputTable = GraphInputTable(name: "The Matrix")
    
    var cellSize = CGSize(width: 50, height: 50)
    fileprivate let padding:CGFloat = 2
    
    override var collectionViewContentSize : CGSize {
        return CGSize(width: CGFloat(inputTable.columnNames.count) * (cellSize.width + padding) + cellSize.width,
            height: CGFloat(inputTable.rows.count) * (cellSize.height + padding) + cellSize.height)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let minRow = Int(max(0, floor(rect.minX / cellSize.width)))
        let maxRow = Int(min(CGFloat(inputTable.columnNames.count - 1), ceil(rect.maxX / cellSize.width)))
        let minSection = Int(max(0, floor(rect.minY / cellSize.height)))
        let maxSection = Int(min(CGFloat(inputTable.rows.count - 1), ceil(rect.maxY / cellSize.height)))
        
        var attributes:[UICollectionViewLayoutAttributes] = []
        for section in minSection...maxSection {
            for row in minRow...maxRow {
                if let attribute = layoutAttributesForItem(at: IndexPath(row: row, section: section)) {
                    attributes.append(attribute)
                }
                
                if let attribute = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: IndexPath(row: row, section: section)) {
                    attributes.append(attribute)
                }
                if row == minRow {
                    if let attribute = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionFooter, at: IndexPath(row: row, section: section)) {
                        attributes.append(attribute)
                    }
                }
            }
            
            
        }
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = CGRect(x: cellSize.width + CGFloat(indexPath.row) * (cellSize.width + padding), y: CGFloat(indexPath.section) * (cellSize.height + padding) + cellSize.width, width: cellSize.width, height: cellSize.height)
        return attributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        switch elementKind {
        case UICollectionElementKindSectionHeader:
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
            attributes.frame = CGRect(x: 50 +  CGFloat(indexPath.row) * (cellSize.width + padding), y: 0, width: cellSize.width, height: cellSize.height)
            return attributes
            
        case UICollectionElementKindSectionFooter:
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
            attributes.frame = CGRect(x: CGFloat(indexPath.row) * (cellSize.width + padding), y: CGFloat(indexPath.section) * (cellSize.height + padding) + cellSize.width, width: cellSize.width, height: cellSize.height)
            return attributes
        default:
            assert(false, "Unexpected element kind")
            return nil
        }
    }
}
