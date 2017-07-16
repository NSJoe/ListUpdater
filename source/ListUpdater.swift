//
//  ListUpdater.swift
//  ListUpdater
//
//  Created by Joe's MacBook Pro on 2017/7/9.
//  Copyright © 2017年 joe. All rights reserved.
//

import UIKit

let defaultThrottle : Float = 0.1

open class ListUpdater {
    
    public var dataSource = [SectionDiffable]()
    private let throttle = ThrottleTask(throttle: defaultThrottle)
    
    public func update(dataSource:[SectionDiffable], animation:@escaping ((DiffIndexResult, DiffSectionResult)) -> Void) -> Void {
        throttle.add {
            let diff = sectionedDiff(from: self.dataSource, to: dataSource)
            self.dataSource = dataSource
            DispatchQueue.main.sync {
                animation(diff)
            }
        }
        
    }
    
}

open class TableViewUpdater: ListUpdater {
    
    public var tableView:UITableView
    
    public init(tableView:UITableView) {
        self.tableView = tableView
    }
    
    public func animateReload(newData:[SectionDiffable]) -> Void {
        if self.tableView.window == nil {
            self.immedateReload(newData: newData)
            return
        }
        self.update(dataSource: newData) { (result) in
            self.tableView.beginUpdates()
            let indexDiff = result.0
            let sectionDiff = result.1
            self.tableView.deleteSections(indexDiff.deletes, with: .top)
            self.tableView.insertSections(indexDiff.inserts, with: .top)
            for move in indexDiff.moveIndexes {
                self.tableView.moveSection(move.from, toSection: move.to)
            }
            self.tableView.deleteRows(at: sectionDiff.deletes, with: .top)
            self.tableView.insertRows(at: sectionDiff.inserts, with: .top)
            for move in sectionDiff.moveRows {
                self.tableView.moveRow(at: move.from, to: move.to)
            }
            self.tableView.endUpdates()
        }
    }
    
    public func immedateReload(newData:[SectionDiffable]) -> Void {
        self.dataSource = newData
        self.tableView.reloadData()
    }
    
}

open class CollectionViewUpdater: ListUpdater {
    
    public var collectionView:UICollectionView
    
    public init(collectionView:UICollectionView) {
        self.collectionView = collectionView
    }
    
    public func animateReload(newData:[SectionDiffable]) -> Void {
        if self.collectionView.window == nil {
            self.immedateReload(newData: newData)
            return
        }
        self.update(dataSource: newData) { (result) in
            self.collectionView.performBatchUpdates({
                let indexDiff = result.0
                let sectionDiff = result.1
                self.collectionView.deleteSections(indexDiff.deletes)
                self.collectionView.insertSections(indexDiff.inserts)
                for move in indexDiff.moveIndexes {
                    self.collectionView.moveSection(move.from, toSection: move.to)
                }
                self.collectionView.deleteItems(at: sectionDiff.deletes)
                self.collectionView.insertItems(at: sectionDiff.inserts)
                for move in sectionDiff.moveRows {
                    self.collectionView.moveItem(at: move.from, to: move.to)
                }
            }, completion: nil)
        }
    }
    
    public func immedateReload(newData:[SectionDiffable]) -> Void {
        self.dataSource = newData
        self.collectionView.reloadData()
    }
    
}
