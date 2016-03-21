//
//  BezierViewController.swift
//  ChartsApp
//
//  Created by Gil Eluard on 10/02/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit
import IOSCharts

class BezierViewController: UIViewController {
    
    @IBOutlet weak var graphView: LineGraphView!
    var inputTable:GraphInputTable?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "Line Graph"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = "Line Graph"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        graphView.inputTable = inputTable
    }
    
    @IBAction func curvingValueChanged(sender: UISlider) {
        graphView.curving = sender.value
    }
}
