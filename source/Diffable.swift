//
//  Diffable.swift
//  ListUpdater
//
//  Created by Joe's MacBook Pro on 2017/7/9.
//  Copyright © 2017年 joe. All rights reserved.
//

import Foundation

protocol Diffable {
    var diffIdentifier : String {get}
}

extension Diffable {
    func diffChanged(to:Diffable) -> Bool {
        return self.diffIdentifier != to.diffIdentifier
    }
}

struct IndexMovement : Hashable {
    var from = 0
    var to = 0
    
    var hashValue: Int {
        get {
            return "\(from)-\(to)".hashValue
        }
    }
    
    static func ==(lhs: IndexMovement, rhs: IndexMovement) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

struct DiffIndexResult {
    var deletes = IndexSet()
    var inserts = IndexSet()
    var reloads = IndexSet()
    var moveIndexes = Set<IndexMovement>()
    
    var changedCount : Int {
        get{
            return deletes.count + inserts.count + moveIndexes.count
        }
    }
    
    mutating func deletes(at index:Int) -> Void {
        deletes.insert(index)
    }
    
    mutating func insert(at index:Int) -> Void {
        inserts.insert(index)
    }
    
    mutating func reloads(at index:Int) -> Void {
        reloads.insert(index)
    }
    
    mutating func moveIndex(at move:IndexMovement) -> Void {
        moveIndexes.insert(move)
    }
}

func indexedDiff(from:Array<Diffable>, to:Array<Diffable>) -> DiffIndexResult {
    var diffResult = DiffIndexResult()
    var oldIds = [String](), newIds = [String](), oldIndexMap = [String:Int](), newIndexMap = [String:Int](), expectIndexes = Array<String>()
    
    for item in from {
        oldIds.append(item.diffIdentifier)
    }
    for item in to {
        newIds.append(item.diffIdentifier)
    }
    
    for (index, item) in from.enumerated() {
        expectIndexes.append(item.diffIdentifier)
        if newIds.contains(item.diffIdentifier) {
            oldIndexMap[item.diffIdentifier] = index
        } else {
            diffResult.deletes(at: index)
        }
    }
    
    expectIndexes = expectIndexes.filter { return !diffResult.deletes.contains(expectIndexes.index(of: $0)!) }
    
    for (index, item) in to.enumerated() {
        if oldIds.contains(item.diffIdentifier) {
            newIndexMap[item.diffIdentifier] = index
        } else {
            diffResult.insert(at: index)
            expectIndexes.insert(item.diffIdentifier, at: index)
        }
    }
    
    for (key, _) in oldIndexMap {
        assert(newIndexMap.keys.contains(key), "对应key不存在")
        let fromIndex = oldIndexMap[key]!
        let expectIndex = expectIndexes.index(of: key)
        let toIndex = newIndexMap[key]!
        if expectIndex == nil {
            continue
        }
        let isChanged = from[fromIndex].diffChanged(to: to[toIndex])
        if expectIndex == toIndex {
            if isChanged {
                diffResult.reloads(at: fromIndex)
            }
            continue
        }
        
        diffResult.moveIndex(at: IndexMovement(from: fromIndex, to: toIndex))
    }
    
    return diffResult
}
