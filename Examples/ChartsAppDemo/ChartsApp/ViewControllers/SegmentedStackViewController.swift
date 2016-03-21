//
//  SegmentedStackViewController.swift
//  ChartsApp
//
//  Created by Norbert Agoston on 22/02/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit
import IOSCharts

class SegmentedStackViewController: UIViewController{
    @IBOutlet weak var segmentedStackView: SegmentedStackView!
    var inputTable:GraphInputTable?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "Segmented Stack Graph"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = "Segmented Stack Graph"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedStackView.inputTable = inputTable        
    }
}
