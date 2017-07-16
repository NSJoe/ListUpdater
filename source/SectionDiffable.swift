//
//  SectionDiffable.swift
//  ListUpdater
//
//  Created by Joe's MacBook Pro on 2017/7/9.
//  Copyright © 2017年 joe. All rights reserved.
//

import Foundation

public protocol SectionDiffable : Diffable {
    var sectionItems : Array<Diffable> { get }
    
}

public struct RowsMovement : Hashable {
    public var from = IndexPath()
    public var to = IndexPath()
    
    public var hashValue: Int {
        get {
            return "\(from.section)-\(from.row)-\(from.item)-\(to.row)-\(to.item)".hashValue
        }
    }
    
    public static func ==(lhs: RowsMovement, rhs: RowsMovement) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

public struct DiffSectionResult {
    public var deletes = [IndexPath]()
    public var inserts = [IndexPath]()
    public var reloads = [IndexPath]()
    public var moveRows = Set<RowsMovement>()
    
    public var changedCount : Int {
        get{
            return deletes.count + inserts.count + moveRows.count
        }
    }
    
    public mutating func deletes(at indexPath:IndexPath) -> Void {
        deletes.append(indexPath)
    }
    
    public mutating func insert(at indexPath:IndexPath) -> Void {
        inserts.append(indexPath)
    }
    
    public mutating func reloads(at indexPath:IndexPath) -> Void {
        reloads.append(indexPath)
    }
    
    public mutating func moveRow(at move:RowsMovement) -> Void {
        moveRows.insert(move)
    }
}

public func sectionedDiff(from:Array<SectionDiffable>, to:Array<SectionDiffable>) -> (DiffIndexResult, DiffSectionResult) {
    
    //计算一级数组的变化
    let indexedResult = indexedDiff(from: from, to: to)
    var sectionedResult = DiffSectionResult()
    
    for (section, item) in from.enumerated() {
        if indexedResult.deletes.contains(section) {
            continue
        }
        let fromArray = item.sectionItems
        var toArray:[Diffable]?
        var toSection = NSNotFound
        for (index, sectionInfo) in to.enumerated() {
            if sectionInfo.diffIdentifier == item.diffIdentifier {
                toArray = sectionInfo.sectionItems
                toSection = index
                break
            }
        }
        assert(toArray != nil && toSection != NSNotFound, "toArray在这里不可能为空, 第一个if判断已经排除了")
        let diffRowResult = indexedDiff(from: fromArray, to: toArray!)
        for (_, row) in diffRowResult.deletes.enumerated() {
            sectionedResult.deletes(at: IndexPath(row: row, section: section))
        }
        for (_, row) in diffRowResult.inserts.enumerated() {
            sectionedResult.insert(at: IndexPath(row: row, section: toSection))
        }
        for move in diffRowResult.moveIndexes {
            let indexPath = IndexPath(row: move.from, section: section)
            if sectionedResult.deletes.contains(indexPath) {
                continue
            }
            sectionedResult.moveRow(at: RowsMovement(from: indexPath, to: IndexPath(row: move.to, section: toSection)))
        }
    }
    return (indexedResult, sectionedResult)
}
