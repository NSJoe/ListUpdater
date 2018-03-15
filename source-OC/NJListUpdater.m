//
//  NJListUpdater.m
//  PM_ListUpdater_FuncCmp
//
//  Created by Joe on 2017/10/25.
//  Copyright © 2017年 Joe. All rights reserved.
//

#import "NJListUpdater.h"
#import "NJThrottleTask.h"

@interface _NJInnerSectionWrapper : NSObject <NJSectionedDiffable>

+ (instancetype)simpleSectionWith:(NSArray<NJDiffArrayType> *)items;

@end

@implementation _NJInnerSectionWrapper {
    NSArray<NJDiffArrayType> *_items;
}

+ (instancetype)simpleSectionWith:(NSArray<NJDiffArrayType> *)items {
    _NJInnerSectionWrapper *wrapper = [[self alloc] init];
    wrapper->_items = items;// 这步不需要复制，后边调用的时候还是会复制
    return wrapper;
}

- (NSString *)diffIdentifier {
    return @"diffIdentifier";
}

-(NSArray<NJDiffArrayType> *)sectionItems {
    return _items;
}

- (id)copyWithZone:(NSZone *)zone {
    _NJInnerSectionWrapper *copy = [[_NJInnerSectionWrapper alloc] init];
    copy->_items = [[NSArray alloc] initWithArray:self->_items copyItems:YES];
    return copy;
}

@end

@interface NJListUpdater ()

@property (nonatomic) NJThrottleTask *throttleTask;
//@property (nonatomic, readwrite) NSArray<NJSectionDiffArrayType> *dataSource;

@end

@implementation NJListUpdater

-(instancetype)init{
    if (self = [super init]) {
        self.throttleTask = [[NJThrottleTask alloc] init];
        self.throttle = 0.3;
    }
    return self;
}

-(void)updateNewData:(NSArray<NJSectionDiffArrayType> *)newData withAnimation:(NJAnimationBlock)animation {
    [self.throttleTask commitTask:^{
        
        NJDiffSectionResult *diff = luSectionedDiff(self.dataSource, newData);
        if ([NSThread isMainThread]) {
            self.dataSource = [[NSArray alloc] initWithArray:newData copyItems:YES];
            animation(diff);
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.dataSource = [[NSArray alloc] initWithArray:newData copyItems:YES];
                animation(diff);    
            });
        }
    }];
}

-(void)setThrottle:(CGFloat)throttle {
    self.throttleTask.throttle = throttle;
}

@end

@interface NJTableViewUpdater ()

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation NJTableViewUpdater

-(instancetype)initWithTableView:(UITableView *)tableView{
    if (self = [super init]) {
        self.tableView = tableView;
        self.tableViewAnimation = UITableViewRowAnimationTop;
    }
    return self;
}

- (void)animateReload:(NSArray<NJSectionDiffArrayType> *)newData {
    [self updateNewData:newData withAnimation:^(NJDiffSectionResult *result) {
        if (result.changeCount + result.indexResult.changeCount == 0) {
            NSLog(@"111112222");
            return [self.tableView reloadData];//动画block执行前已经赋值过dataSource
        }
        NSLog(@"11111111");
        [CATransaction begin];
        [self.tableView beginUpdates];
        
        if ([result.indexResult.deletes count]) {
            [self.tableView deleteSections:result.indexResult.deletes withRowAnimation:self.tableViewAnimation];
        }
        if ([result.indexResult.inserts count]) {
            [self.tableView insertSections:result.indexResult.inserts withRowAnimation:self.tableViewAnimation];
        }
        
        for (NJIndexMovement *movement in result.indexResult.moveIndexes) {
            [self.tableView moveSection:movement.from toSection:movement.to];
        }
        
        if (result.deletes.count) {
            [self.tableView deleteRowsAtIndexPaths:result.deletes withRowAnimation:self.tableViewAnimation];
        }
        if (result.inserts.count) {
            [self.tableView insertRowsAtIndexPaths:result.inserts withRowAnimation:self.tableViewAnimation];
        }
        
        for (NJRowsMovement *movement in result.moveRows) {
            [self.tableView moveRowAtIndexPath:movement.from toIndexPath:movement.to];
        }
        
        [self.tableView endUpdates];
        
        [CATransaction setCompletionBlock:^{
            if (self.complete) {
                self.complete(YES);
            }
        }];
        [CATransaction commit];
    }];
}

- (void)immediateReload:(NSArray<NJSectionDiffArrayType> *)newData {
    self.dataSource = [[NSArray alloc] initWithArray:newData copyItems:YES];
    [self.tableView reloadData];
}

- (void)simpleAnimateReload:(NSArray<NJDiffArrayType> *)newData {
    [self animateReload:@[[_NJInnerSectionWrapper simpleSectionWith:newData]]];
}

- (void)simpleImmediateReload:(NSArray<NJDiffArrayType> *)newData {
    [self immediateReload:@[[_NJInnerSectionWrapper simpleSectionWith:newData]]];
}

@end

@interface NJCollectionViewUpdater ()

@property (nonatomic) UICollectionView *collectionView;

@end

@implementation NJCollectionViewUpdater

-(instancetype)initWithCollectionView:(UICollectionView *)collectionView {
    if (self = [super init]) {
        self.collectionView = collectionView;
    }
    return self;
}

- (void)animateReload:(NSArray<NJSectionDiffArrayType> *)newData {
    [self updateNewData:newData withAnimation:^(NJDiffSectionResult *result) {
        if (result.changeCount + result.indexResult.changeCount == 0) {
            return [self.collectionView reloadData];
        }
        
        [self.collectionView performBatchUpdates:^{
            
            [self.collectionView deleteSections:result.indexResult.deletes];
            [self.collectionView insertSections:result.indexResult.inserts];
            for (NJIndexMovement *movement in result.indexResult.moveIndexes) {
                [self.collectionView moveSection:movement.from toSection:movement.to];
            }
            [self.collectionView deleteItemsAtIndexPaths:result.deletes];
            [self.collectionView insertItemsAtIndexPaths:result.inserts];
            for (NJRowsMovement *movement in result.moveRows) {
                [self.collectionView moveItemAtIndexPath:movement.from toIndexPath:movement.to];
            }
            
        } completion:^(BOOL finished) {
            if (self.complete) {
                self.complete(finished);
            }
        }];
    }];
}

- (void)immediateReload:(NSArray<NJSectionDiffArrayType> *)newData {
    self.dataSource = [[NSArray alloc] initWithArray:newData copyItems:YES];
    [self.collectionView reloadData];
}

- (void)simpleAnimateReload:(NSArray<NJDiffArrayType> *)newData {
    [self animateReload:@[[_NJInnerSectionWrapper simpleSectionWith:newData]]];
}

- (void)simpleImmediateReload:(NSArray<NJDiffArrayType> *)newData {
    [self immediateReload:@[[_NJInnerSectionWrapper simpleSectionWith:newData]]];
}

@end
