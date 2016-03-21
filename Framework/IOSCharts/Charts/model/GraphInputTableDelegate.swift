//
//  GraphInputTableDelegate.swift
//  ChartsApp
//
//  Created by Gil Eluard on 19/02/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import Foundation

protocol GraphInputTableDelegate: NSObjectProtocol {
    func tableValuesDidChange(table: GraphInputTable);
    func tableColumnsDidChange(table: GraphInputTable);
    func tableRowsDidChange(table: GraphInputTable);
    func tableRowTintColorDidChange(table: GraphInputTable, rowIndex: Int);
}
