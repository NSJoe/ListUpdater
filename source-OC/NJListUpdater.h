//
//  NJListUpdater.h
//  PM_ListUpdater_FuncCmp
//
//  Created by Joe on 2017/10/25.
//  Copyright © 2017年 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJDiffable.h"

typedef void(^NJAnimationBlock)(NJDiffSectionResult *);
typedef void(^NJAnimationComplete)(BOOL);

//更新的基类，如果需要自定义视图支持差值计算，使用这个基类
@interface NJListUpdater : NSObject

//UI中需要响应数据源请使用这个属性，否则可能因为更新的数据和动画的数据不匹配导致崩溃
@property (nonatomic) NSArray<NJSectionDiffArrayType> *dataSource;
//动画更新执行完成
@property (nonatomic, copy) NJAnimationComplete complete;
//动画执行间隔， 默认0.1秒，在这个间隔时间内，只会计算一次动画也只执行一次
@property (nonatomic) CGFloat throttle;
//动画的计算部分会在子线程进行，计算完成后再调用真正的动画实现
- (void)updateNewData:(NSArray<NJSectionDiffArrayType> *)newData withAnimation:(NJAnimationBlock)animation;

@end

//TableView
@interface NJTableViewUpdater : NJListUpdater

//默认top动画, iPhone 7Plus 10.3.1 闪烁问题 UITableViewRowAnimationFade引起
@property (nonatomic) UITableViewRowAnimation tableViewAnimation;

- (instancetype)initWithTableView:(UITableView *)tableView;

/// section > 1 的更新
//通过动画更新
- (void)animateReload:(NSArray<NJSectionDiffArrayType> *)newData;
//立刻更新，实际就是直接reloadData
- (void)immediateReload:(NSArray<NJSectionDiffArrayType> *)newData;

/// section = 1 的更新
//通过动画更新
- (void)simpleAnimateReload:(NSArray<NJDiffArrayType> *)newData;
//立刻更新，实际就是直接reloadData
- (void)simpleImmediateReload:(NSArray<NJDiffArrayType> *)newData;

@end

//CollectionView --------未在项目中实践过--------
@interface NJCollectionViewUpdater : NJListUpdater

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;

/// section > 1 的更新
//通过动画更新
- (void)animateReload:(NSArray<NJSectionDiffArrayType> *)newData;
//立刻更新，实际就是直接reloadData
- (void)immediateReload:(NSArray<NJSectionDiffArrayType> *)newData;

/// section = 1 的更新
//通过动画更新
- (void)simpleAnimateReload:(NSArray<NJDiffArrayType> *)newData;
//立刻更新，实际就是直接reloadData
- (void)simpleImmediateReload:(NSArray<NJDiffArrayType> *)newData;

@end
