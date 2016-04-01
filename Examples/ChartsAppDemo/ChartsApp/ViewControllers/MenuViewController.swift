//
//  MenuViewController.swift
//  ChartsApp
//
//  Created by Gil Eluard on 10/02/16.
//  Copyright © 2016 3PillarGlobal. All rights reserved.
//

import UIKit
import IOSCharts

class MenuViewController: UIViewController {
    
    private static let cellId = "MenuViewControllerCellId"
    private static let headerReuseIdentifier = "ColumnHeader"
    private let collectionLayout = MatrixCollectionViewFlowLayout()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet var viewGraphsButtonCollection: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = collectionLayout
        
        title = "Graphs"
        let addColumnButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(MenuViewController.addColumn))
        navigationItem.leftBarButtonItem = addColumnButton
        
        collectionView.registerClass(CustomCollectionViewCell.self, forCellWithReuseIdentifier: MenuViewController.cellId)
        collectionView.registerClass(CustomReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: MenuViewController.headerReuseIdentifier)
        
        
        let cellNib: UINib = UINib(nibName: "CustomCollectionViewCell", bundle: NSBundle.mainBundle())
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: MenuViewController.cellId)
        
        let headerNib: UINib = UINib(nibName: "CustomReusableView", bundle: NSBundle.mainBundle())
        collectionView.registerNib(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: MenuViewController.headerReuseIdentifier)
        
        collectionView.registerNib(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: MenuViewController.headerReuseIdentifier)
        
        collectionView?.backgroundColor = UIColor.whiteColor()
        
        collectionLayout.inputTable.rows = [
            GraphInputRow(name: "row 1", tintColor: UIColor(hex: 0x263D8D, a: 1.0)),
            GraphInputRow(name: "row 2", tintColor: UIColor(hex: 0x5E73EB, a: 1.0)),
            GraphInputRow(name: "row 3", tintColor: UIColor(hex: 0x00ADFF, a: 1.0)),
            GraphInputRow(name: "row 4", tintColor: UIColor(hex: 0xF68920, a: 1.0)),
            GraphInputRow(name: "row 5", tintColor: UIColor(hex: 0xCC4314, a: 1.0)),
        ]
        
        addColumn()
    }
    
    //MARK: Private method
    
    func addColumn() {
        let values: [Double] = collectionLayout.inputTable.rows.map {_ in return Double(arc4random_uniform(100))}
        collectionLayout.inputTable.addColumn("col #\(collectionLayout.inputTable.columnNames.count + 1)", rowValues: values)
        
        collectionView.reloadData()
    }
    
    //MARK: Main Action
    
    @IBAction func viewGraph(sender: UIButton) {
        guard let myButtonIndex = viewGraphsButtonCollection.indexOf(sender) else {
            return
        }
        var viewController: UIViewController?
        switch myButtonIndex {
        case 0:
            let vc = BezierViewController(nibName: "BezierViewController", bundle: nil)
            vc.inputTable = collectionLayout.inputTable
            viewController = vc
        case 1:
            let vc = SegmentedStackViewController(nibName: "SegmentedStackViewController", bundle: nil)
            vc.inputTable = collectionLayout.inputTable
            viewController = vc
        case 2:
            let vc = PieChartViewController(nibName: "PieChartViewController", bundle: nil)
            vc.inputTable = collectionLayout.inputTable
            viewController = vc
        default: break
        }
        
        if let viewController = viewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}

//MARK: UICollectionViewDataSource
extension MenuViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return collectionLayout.inputTable.rows.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionLayout.inputTable.columnNames.count
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: MenuViewController.headerReuseIdentifier, forIndexPath: indexPath) as? CustomReusableView

            headerView?.backgroundColor = UIColor.lightGrayColor()
            headerView?.titleLabel?.text = "\(collectionLayout.inputTable.columnNames[indexPath.row])"
            return headerView!
        case UICollectionElementKindSectionFooter:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: MenuViewController.headerReuseIdentifier, forIndexPath: indexPath) as? CustomReusableView
            
            headerView?.backgroundColor = UIColor.lightGrayColor()
            let row:GraphInputRow = collectionLayout.inputTable.rows[indexPath.section]
            headerView?.titleLabel?.text = row.name
            return headerView!
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MenuViewController.cellId, forIndexPath: indexPath) as! CustomCollectionViewCell
        cell.backgroundColor = collectionLayout.inputTable.rows[indexPath.section].tintColor
        let row = collectionLayout.inputTable.rows[indexPath.section]
        cell.titleLabel.text = "\(row.values[indexPath.row])"
        return cell
    }
    
}
