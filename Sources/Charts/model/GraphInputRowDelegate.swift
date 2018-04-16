//
//  GraphInputRowDelegate.swift
//  ChartsApp
//
//  Created by Gil Eluard on 19/02/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import Foundation

protocol GraphInputRowDelegate: NSObjectProtocol {
    func rowValuesDidChange(row: GraphInputRow);
    func rowTintColorDidChange(row: GraphInputRow);
}
