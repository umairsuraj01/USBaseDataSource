//
//  USCollectionViewController.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 11/07/2023.
//

import UIKit

//class USCollectionViewController: UICollectionViewController {
//    private var dataSource: USArrayDataSource!
//    
//    init() {
//        let layout = UICollectionViewFlowLayout()
//        layout.minimumInteritemSpacing = 4.0
//        layout.minimumLineSpacing = 10.0
//        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//        layout.itemSize = kColoredCollectionCellSize
//        layout.headerReferenceSize = CGSize(width: 320, height: 40)
//        layout.footerReferenceSize = CGSize(width: 320, height: 40)
//        
//        super.init(collectionViewLayout: layout)
//        
//        var items = [Any]()
//        
//        for _ in 0..<15 {
//            items.append(arc4random_uniform(10000))
//        }
//        
//        dataSource = USArrayDataSource(items: items)
//        dataSource.cellClass = USSolidColorCollectionCell.self
//        dataSource.collectionViewSupplementaryElementClass = USCollectionViewSectionHeader.self
//        dataSource.cellConfigureBlock = { cell, number, collectionView, indexPath in
//            if let cell = cell as? USSolidColorCollectionCell {
//                cell.label.text = number.stringValue
//            }
//        }
//        dataSource.collectionSupplementaryConfigureBlock = { header, kind, collectionView, indexPath in
//            if let header = header as? USCollectionViewSectionHeader {
//                header.label.text = (kind == UICollectionView.elementKindSectionHeader) ? "A section header" : "A section footer"
//            }
//        }
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        navigationItem.rightBarButtonItems = [
//            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem)),
//            UIBarButtonItem(title: "Remove Cell", style: .plain, target: self, action: #selector(removeItem))
//        ]
//        
//        collectionView.backgroundColor = .white
//        
//        collectionView.register(USSolidColorCollectionCell.self, forCellWithReuseIdentifier: USSolidColorCollectionCell.identifier())
//        collectionView.register(USCollectionViewSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: USCollectionViewSectionHeader.identifier())
//        collectionView.register(USCollectionViewSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: USCollectionViewSectionHeader.identifier())
//        
//        dataSource.collectionView = collectionView
//        
//        let noItemsLabel = UILabel()
//        noItemsLabel.text = "No Items"
//        noItemsLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
//        noItemsLabel.textAlignment = .center
//        
//        dataSource.emptyView = noItemsLabel
//    }
//    
//    @objc func addItem() {
//        dataSource.appendItem(arc4random_uniform(10000))
//    }
//    
//    @objc func removeItem() {
//        if dataSource.numberOfItems() > 0 {
//            dataSource.removeItem(atIndex: Int(arc4random_uniform(UInt32(dataSource.numberOfItems()))))
//        }
//    }
//    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let item = dataSource.item(atIndexPath: indexPath)
//        print("selected item \(item)")
//    }
//}

