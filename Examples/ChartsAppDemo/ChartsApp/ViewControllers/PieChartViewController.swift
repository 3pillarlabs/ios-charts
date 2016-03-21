//
//  PieChartViewController.swift
//  ChartsApp
//
//  Created by Valentina Iancu on 22/02/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit
import IOSCharts

class PieChartViewController: UIViewController {
    @IBOutlet weak var graphView: PieChartView!
    var inputTable:GraphInputTable?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "Pie Graph"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = "Pie Graph"

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        graphView.inputTable = inputTable
    }
}
