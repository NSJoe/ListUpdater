//
//  NJDiffable.h
//  PM_ListUpdater_FuncCmp
//
//  Created by Joe on 2017/10/25.
//  Copyright © 2017年 Joe. All rights reserved.
//

#import <Foundation/Foundation.h>

//@attention: 暂不支持reload，因为reload动画看起来有点奇怪

#pragma mark - 一维的Diff协议

//@attention: 为保证线程安全，实现这个协议时同时也要实现copy协议
@protocol NJDiffable <NSCopying, NSObject>

-(NSString *)diffIdentifier;//数组范围内保证唯一
@optional
-(BOOL)isChanged:(id<NJDiffable>)new;

@end

typedef id<NJDiffable> NJDiffArrayType;

//计算结果
@interface NJIndexMovement : NSObject

@property (nonatomic) NSInteger from;
@property (nonatomic) NSInteger to;

+(instancetype)movementFrom:(NSInteger)from to:(NSInteger)to;

@end

@interface NJDiffIndexResult : NSObject

@property (nonatomic) NSIndexSet *deletes;
@property (nonatomic) NSIndexSet *inserts;
@property (nonatomic) NSSet<NJIndexMovement *> *moveIndexes;
@property (nonatomic) NSIndexSet *reloads;

@property (nonatomic, readonly) NSInteger changeCount;

+(instancetype)diffResultWithDeletes:(NSIndexSet *)deletes inserts:(NSIndexSet *)inserts moves:(NSSet<NJIndexMovement *> *)moves reloads:(NSIndexSet *)reloads;

@end

extern NJDiffIndexResult* luIndexedDiff(NSArray<NJDiffArrayType> *from, NSArray<NJDiffArrayType> *to);

#pragma mark - 二维的Diff协议

@protocol NJSectionedDiffable <NJDiffable>

-(NSArray<NJDiffArrayType> *)sectionItems;

@end

typedef id<NJSectionedDiffable> NJSectionDiffArrayType;

//计算结果
@interface NJRowsMovement : NSObject

@property (nonatomic) NSIndexPath *from;
@property (nonatomic) NSIndexPath *to;

+(instancetype)movementFromIndexPath:(NSIndexPath *)from toIndexPath:(NSIndexPath *)to;

@end

@interface NJDiffSectionResult : NSObject

@property (nonatomic) NJDiffIndexResult *indexResult;//关联的一维变换

@property (nonatomic) NSArray<NSIndexPath *> *deletes;
@property (nonatomic) NSArray<NSIndexPath *> *inserts;
@property (nonatomic) NSArray<NJRowsMovement *> *moveRows;
@property (nonatomic) NSArray<NSIndexPath *> *reloads;

@property (nonatomic, readonly) NSInteger changeCount;

+(instancetype)diffResultWithDeletes:(NSArray *)deletes inserts:(NSArray *)inserts moves:(NSArray<NJRowsMovement *> *)moves reloads:(NSArray *)reloads;

@end

extern NJDiffSectionResult* luSectionedDiff(NSArray<NJSectionDiffArrayType> *from, NSArray<NJSectionDiffArrayType> *to);

extern void convertMovingToDeleteAndInsert(BOOL fromFlag, NJDiffIndexResult *result, NSMutableArray<NSIndexPath *> *indexPaths);
#define DEBUG_LOG_RESULT(result) \
NSLog(@"section:  delete:%@, insert:%@, reload:%@, move:%@",result.indexResult.deletes, result.indexResult.inserts, result.indexResult.reloads, result.indexResult.moveIndexes); \
NSLog(@"delete:%@",result.deletes); \
NSLog(@"insert:%@",result.inserts); \
NSLog(@"reload:%@",result.reloads); \
NSLog(@"move:%@",result.moveRows); \
