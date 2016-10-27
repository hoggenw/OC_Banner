//
//  BannerScrollView.h
//  test
//
//  Created by ios-mac on 16/4/15.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyPageControl.h"

@interface BannerScrollView : UIView<UIScrollViewDelegate>

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, strong) MyPageControl *pageControl;


/** 启动定时器调用，开始自动进行轮播 */
- (void)animationTimerDidFire:(NSTimer *)timer;

/** 滚动后，将原来的三个视图移除，添加新的视图组，保证显示出来的视图，永远处于中间的位置 */
- (void)configureContentViews;
/** 设置视图组的数据源 */
- (void)setScrollViewDataSource;
/** 获取指定页标的索引 */

/**
 * @brief 初始化方法
 * @param interval 滚动的时间间, 必须大于0
 */
- (instancetype)initWithFrame:(CGRect)frame duration:(NSTimeInterval)interval;

/** 获取page总数 */
@property (nonatomic, copy) NSInteger (^totalPageCount)(void);

/** 获取pageIndex下的视图 */
@property (nonatomic, copy) UIImageView* (^contentViewAtIndex)(NSInteger pageIndex);

/** 点击指定视图触发事件 */
@property (nonatomic, copy) void (^tapActionBlock)(NSInteger pageIndex);

- (void)hidePageControl;

-(void)hideCureView;

@end
