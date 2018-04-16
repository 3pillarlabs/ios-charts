//
//  GridDataSource.swift
//  ChartsApp
//
//  Created by Flaviu Silaghi on 02/03/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit

protocol OverlayDataSource {
    func gridProperties(bounds: CGRect) -> [ValueProperties]
}
