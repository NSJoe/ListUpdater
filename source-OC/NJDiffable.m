//
//  NJDiffable.m
//  PM_ListUpdater_FuncCmp
//
//  Created by Joe on 2017/10/25.
//  Copyright © 2017年 Joe. All rights reserved.
//

#import "NJDiffable.h"
#import <UIKit/UIKit.h>

@implementation NJIndexMovement

+(instancetype)movementFrom:(NSInteger)from to:(NSInteger)to {
    NJIndexMovement *movement = [[self alloc] init];
    movement.from = from;
    movement.to = to;
    return movement;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"从 %@ 到 %@", @(self.from), @(self.to)];
}

@end

@implementation NJDiffIndexResult

-(NSInteger)changeCount {
    return self.deletes.count + self.inserts.count + self.moveIndexes.count;
}

+(instancetype)diffResultWithDeletes:(NSIndexSet *)deletes inserts:(NSIndexSet *)inserts moves:(NSSet<NJIndexMovement *> *)moves reloads:(NSIndexSet *)reloads
{
    NJDiffIndexResult *result = [[self alloc] init];
    result.deletes = deletes;
    result.inserts = inserts;
    result.moveIndexes = moves;
    result.reloads = reloads;
    return result;
}

@end

NJDiffIndexResult* luIndexedDiff(NSArray<NJDiffArrayType> *from, NSArray<NJDiffArrayType> *to){
    //添加和删除的section计算
    NSMutableIndexSet *deleteIndexes = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *insertIndexes = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *reloadIndexes = [NSMutableIndexSet indexSet];
    //移动的section计算
    NSMutableArray<NJIndexMovement *> *moveSections = [NSMutableArray array];
    
    NSMutableArray *tempIds = [NSMutableArray array];
    for (NJDiffArrayType info in from) {
        [tempIds addObject:[info diffIdentifier]];
    }
    NSArray *oldIds = tempIds.copy;
    [tempIds removeAllObjects];
    
    for (NJDiffArrayType info in to) {
        [tempIds addObject:[info diffIdentifier]];
    }
    NSArray *newIds = tempIds.copy;
    
    NSMutableDictionary<NSString *, NSNumber *> *oldIndexMap = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, NSNumber *> *newIndexMap = [NSMutableDictionary dictionary];
    
    NSMutableArray<NSString *> *expectIndexes = [NSMutableArray array];
    
    [from enumerateObjectsUsingBlock:^(NJSectionDiffArrayType  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [expectIndexes addObject:[obj diffIdentifier]];
        if (![newIds containsObject:[obj diffIdentifier]]) {
            [deleteIndexes addIndex:idx];
        } else {
            [oldIndexMap setObject:@(idx) forKey:[obj diffIdentifier]];
        }
    }];
    
    [expectIndexes removeObjectsAtIndexes:deleteIndexes];
    
    [to enumerateObjectsUsingBlock:^(NJSectionDiffArrayType  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![oldIds containsObject:[obj diffIdentifier]]) {
            [insertIndexes addIndex:idx];
            [expectIndexes insertObject:[obj diffIdentifier] atIndex:idx];
        } else {
            [newIndexMap setObject:@(idx) forKey:[obj diffIdentifier]];
        }
    }];
    
    for (NSString *key in oldIndexMap) {
        NSCAssert([newIndexMap.allKeys containsObject:key], @"对应key不存在");
        NSInteger fromIndex = oldIndexMap[key].integerValue;
        NSInteger expectIndex = [expectIndexes indexOfObject:key];
        NSInteger toIndex = newIndexMap[key].integerValue;
        if (expectIndex == NSNotFound) {
            continue;
        }
        BOOL isChanged = YES;
        if ([from[fromIndex] respondsToSelector:@selector(isChanged:)]) {
            isChanged =  [from[fromIndex] isChanged:to[toIndex]];
        }
        if (expectIndex == toIndex) {
            if (isChanged) [reloadIndexes addIndex:fromIndex];
            continue;
        }
        
        NJIndexMovement *move = [moveSections filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"from == %d", toIndex]].firstObject;
        if (move && move.to == fromIndex) {
            NSLog(@"相反的移动已经存在");
            continue;
        }
        
        [moveSections addObject:[NJIndexMovement movementFrom:fromIndex to:toIndex]];
    }
    
    return [NJDiffIndexResult diffResultWithDeletes:deleteIndexes.copy inserts:insertIndexes.copy moves:[NSSet setWithArray:moveSections] reloads:reloadIndexes];
}

@implementation NJRowsMovement

+(instancetype)movementFromIndexPath:(NSIndexPath *)from toIndexPath:(NSIndexPath *)to {
    NJRowsMovement *movement = [[self alloc] init];
    movement.from = from;
    movement.to = to;
    return movement;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"从 %@ 到 %@", self.from, self.to];
}

@end

@implementation NJDiffSectionResult

-(NSInteger)changeCount {
    return self.deletes.count + self.inserts.count + self.moveRows.count;
}

+(instancetype)diffResultWithDeletes:(NSArray *)deletes inserts:(NSArray *)inserts moves:(NSArray<NJRowsMovement *> *)moves reloads:(NSArray *)reloads
{
    NJDiffSectionResult *result = [[self alloc] init];
    result.deletes = deletes;
    result.inserts = inserts;
    result.moveRows = moves;
    result.reloads = reloads;
    return result;
}

@end

NJDiffSectionResult* luSectionedDiff(NSArray<NJSectionDiffArrayType> *from, NSArray<NJSectionDiffArrayType> *to)
{
    NSArray<NJSectionDiffArrayType> *newArray = [[NSArray alloc] initWithArray:to copyItems:YES];
    
    NJDiffIndexResult *diffSectionResult = luIndexedDiff(from, newArray);
    
    NSMutableArray<NSIndexPath *> *deleteIndexPaths = [NSMutableArray array];
    NSMutableArray<NSIndexPath *> *insertIndexPaths = [NSMutableArray array];
    NSMutableArray<NJRowsMovement *> *moveIndexPaths = [NSMutableArray array];
    NSMutableArray<NSIndexPath *> *reloadIndexPaths = [NSMutableArray array];
    
    [from enumerateObjectsUsingBlock:^(NJSectionDiffArrayType  _Nonnull obj, NSUInteger section, BOOL * _Nonnull stop) {
        if ([diffSectionResult.deletes containsIndex:section]) {
            return;
        }
        NSArray<NJDiffArrayType> *fromArray = [obj sectionItems];
        NSArray<NJDiffArrayType> *toArray;
        NSInteger toSection = NSNotFound;
        for (NJSectionDiffArrayType sectionInfo in newArray) {
            if ([[sectionInfo diffIdentifier] isEqualToString:[obj diffIdentifier]]) {
                toArray = [sectionInfo sectionItems];
                toSection = [newArray indexOfObject:sectionInfo];
                break;
            }
        }
        NSCAssert(toArray != nil, @"找不到新数组对应");
        NJDiffIndexResult *diffRowResult = luIndexedDiff(fromArray, toArray);
        [diffRowResult.deletes enumerateIndexesUsingBlock:^(NSUInteger row, BOOL * _Nonnull stop) {
            [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
        }];
        [diffRowResult.inserts enumerateIndexesUsingBlock:^(NSUInteger row, BOOL * _Nonnull stop) {
            [insertIndexPaths addObject:[NSIndexPath indexPathForRow:row inSection:toSection]];
        }];
        
        [diffRowResult.moveIndexes enumerateObjectsUsingBlock:^(NJIndexMovement * _Nonnull obj, BOOL * _Nonnull stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:obj.from inSection:section];
            if ([deleteIndexPaths containsObject:indexPath]) {
                return;
            }
            [moveIndexPaths addObject:[NJRowsMovement movementFromIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:obj.to inSection:toSection]]];
        }];
        
    }];
    
    //同时移动和删除的处理掉
    convertMovingToDeleteAndInsert(YES, diffSectionResult, deleteIndexPaths);
    //同时移动和插入的处理掉
    convertMovingToDeleteAndInsert(NO, diffSectionResult, insertIndexPaths);
    //处理所有的移动变成insert或者delete
    for (NJRowsMovement *movement in [moveIndexPaths copy]) {
        BOOL containFrom = [diffSectionResult.deletes containsIndex:movement.from.section];
        BOOL containTo = [diffSectionResult.inserts containsIndex:movement.to.section];
        if (containFrom || containTo) {
            [moveIndexPaths removeObject:movement];
            if (!containFrom) {
                [deleteIndexPaths addObject:movement.from];
            }
            if (!containTo) {
                [insertIndexPaths addObject:movement.to];
            }
        }
    }
    
    NJDiffSectionResult *result = [NJDiffSectionResult diffResultWithDeletes:deleteIndexPaths.copy inserts:insertIndexPaths.copy moves:moveIndexPaths.copy reloads:reloadIndexPaths.copy];
    result.indexResult = diffSectionResult;
    
    return result;
}

void convertMovingToDeleteAndInsert(BOOL fromFlag, NJDiffIndexResult *result, NSMutableArray<NSIndexPath *> *indexPaths) {
    NSMutableIndexSet *deletes = result.deletes.mutableCopy;
    NSMutableIndexSet *inserts = result.inserts.mutableCopy;
    NSMutableSet<NJIndexMovement *> *moveIndexes = result.moveIndexes.mutableCopy;
    
    for (NSIndexPath *path in [indexPaths copy]) {
        NJIndexMovement* move = [result.moveIndexes filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NJIndexMovement* evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            NSInteger index = fromFlag ? evaluatedObject.from : evaluatedObject.to;
            return index == path.section;
        }]].anyObject;
        
        if (move != nil) {
            [indexPaths removeObject:path];
            [moveIndexes removeObject:move];
            [deletes addIndex:move.from];
            [inserts addIndex:move.to];
        }
    }
    
    result.deletes = deletes.copy;
    result.inserts = inserts.copy;
    result.moveIndexes = moveIndexes.copy;
}
