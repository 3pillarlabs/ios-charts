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
    
    fileprivate static let cellId = "MenuViewControllerCellId"
    fileprivate static let headerReuseIdentifier = "ColumnHeader"
    fileprivate let collectionLayout = MatrixCollectionViewFlowLayout()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet var viewGraphsButtonCollection: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = collectionLayout
        
        title = "Graphs"
        let addColumnButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(MenuViewController.addColumn))
        navigationItem.leftBarButtonItem = addColumnButton
        
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: MenuViewController.cellId)
        collectionView.register(CustomReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: MenuViewController.headerReuseIdentifier)
        
        
        let cellNib: UINib = UINib(nibName: "CustomCollectionViewCell", bundle: Bundle.main)
        collectionView.register(cellNib, forCellWithReuseIdentifier: MenuViewController.cellId)
        
        let headerNib: UINib = UINib(nibName: "CustomReusableView", bundle: Bundle.main)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: MenuViewController.headerReuseIdentifier)
        
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: MenuViewController.headerReuseIdentifier)
        
        collectionView?.backgroundColor = UIColor.white
        
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
    
    @objc func addColumn() {
        let values: [Double] = collectionLayout.inputTable.rows.map {_ in return Double(arc4random_uniform(100))}
        collectionLayout.inputTable.addColumn(columnName: "col #\(collectionLayout.inputTable.columnNames.count + 1)", rowValues: values)
        
        collectionView.reloadData()
    }
    
    //MARK: Main Action
    
    @IBAction func viewGraph(_ sender: UIButton) {
        guard let myButtonIndex = viewGraphsButtonCollection.index(of: sender) else {
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionLayout.inputTable.rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionLayout.inputTable.columnNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MenuViewController.headerReuseIdentifier, for: indexPath) as? CustomReusableView

            headerView?.backgroundColor = UIColor.lightGray
            headerView?.titleLabel?.text = "\(collectionLayout.inputTable.columnNames[indexPath.row])"
            return headerView!
        case UICollectionElementKindSectionFooter:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MenuViewController.headerReuseIdentifier, for: indexPath) as? CustomReusableView
            
            headerView?.backgroundColor = UIColor.lightGray
            let row:GraphInputRow = collectionLayout.inputTable.rows[indexPath.section]
            headerView?.titleLabel?.text = row.name
            return headerView!
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuViewController.cellId, for: indexPath) as! CustomCollectionViewCell
        cell.backgroundColor = collectionLayout.inputTable.rows[indexPath.section].tintColor
        let row = collectionLayout.inputTable.rows[indexPath.section]
        cell.titleLabel.text = "\(row.values[indexPath.row])"
        return cell
    }
    
}
