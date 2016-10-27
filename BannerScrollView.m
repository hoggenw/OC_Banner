//
//  BannerScrollView.m
//  test
//
//  Created by ios-mac on 16/4/15.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

#import "BannerScrollView.h"
#import "CurveView.h"
#import "NSTimer+Addition.h"


#define VIEW_WIDTH CGRectGetWidth(self.bounds)
#define VIEW_HEIGHT CGRectGetHeight(self.bounds)

@interface BannerScrollView ()

@property (nonatomic, strong) NSMutableArray *contentViews;
@property (nonatomic, readonly) NSTimeInterval animationInterval;
@property (nonatomic, assign) NSInteger totalPages;
@end

@implementation BannerScrollView{
    CurveView *cure;
}
- (void)dealloc {
    _scrollView.delegate = nil;
}
- (instancetype)initWithFrame:(CGRect)frame duration:(NSTimeInterval)interval{
    self  =  [super initWithFrame:frame];
    
    if (self) {
        if (interval > 0) {
            self.animationTimer  =  [NSTimer scheduledTimerWithTimeInterval:interval
                                                                   target:self
                                                                 selector:@selector(animationTimerDidFire:)
                                                                 userInfo:nil
                                                                  repeats:YES];
            [self.animationTimer pauseTimer];
        }
        _animationInterval  =  interval;
        self.clipsToBounds  =  YES;
        _scrollView  =  [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.scrollsToTop  =  NO;
        _scrollView.pagingEnabled  =  YES;
        _scrollView.delegate  =  self;
        _scrollView.contentOffset  =  CGPointMake(VIEW_WIDTH, 0);
        _scrollView.contentSize  =  CGSizeMake(3 * VIEW_WIDTH, VIEW_HEIGHT);
        [self addSubview:_scrollView];
        self.pageControl = [[MyPageControl alloc]initWithFrame:CGRectMake(0, VIEW_HEIGHT-20, VIEW_WIDTH, 10)];
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.midBool = NO;
        [self addSubview:self.pageControl];
        cure = [[CurveView alloc]initWithFrame:CGRectMake(0,VIEW_HEIGHT-20,VIEW_WIDTH, 20)];
        cure.backgroundColor = [UIColor clearColor];
        [self addSubview:cure];
    }
    
    return self;
}

// 设置总页数之后，启动动画
- (void)setTotalPageCount:(NSInteger (^)(void))totalPageCount{
    
    self.totalPages  =  totalPageCount();
    self.pageControl.numberOfPages  =  self.totalPages;
    _pageControl.backgroundColor = [UIColor clearColor];
    _pageControl.userInteractionEnabled = NO;
    _pageControl.midBool = NO;
    self.currentPageIndex = 0;
    if (self.totalPages   ==  1) {
        _scrollView.contentSize  =  CGSizeMake(VIEW_WIDTH, VIEW_HEIGHT);
        [self configureContentViews];
        [self hidePageControl];
        return;
    }else {
        self.pageControl.hidden  =  NO;
    }
    if (self.totalPages > 0) {
     
        [self configureContentViews];
        [self.animationTimer resumeTimerAfterInterval:self.animationInterval];
    }
}

- (void)configureContentViews{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setScrollViewDataSource];
    
    for (int i  =  0; i < self.contentViews.count; i++) {

        UIImageView *contentView  =  nil;
        if (self.totalPages <3) {
            
            UIImageView *midImageview =[self.contentViews objectAtIndex:i];
            UIImage *image = midImageview.image;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT)];
            imageView.contentMode = UIViewContentModeRedraw;
            imageView.image = image;
            contentView = imageView;
            
        }else{
            
          contentView  =  [self.contentViews objectAtIndex:i];
            contentView.frame = CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT);
            
        }
        

        contentView.userInteractionEnabled  =  YES;
        CGRect contentViewFrame  =  contentView.frame;
        contentViewFrame.origin  =  CGPointMake(VIEW_WIDTH * i, 0);
        contentView.frame  =  contentViewFrame;
        UITapGestureRecognizer *tapGesture  =  [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(contentViewTapped:)];
        [contentView addGestureRecognizer:tapGesture];
        [self.scrollView addSubview:contentView];
    }
    
    if (self.totalPages !=  1) {
        
        self.scrollView.contentOffset  =  CGPointMake(VIEW_WIDTH, 0);
    }
    else {
        
        self.scrollView.contentOffset  =  CGPointMake(VIEW_WIDTH * 2, 0);
    }
}

- (void)setScrollViewDataSource{
    

    NSInteger previousIndex  =  [self validateNextPageIndexWithPageIndex:self.currentPageIndex - 1];
    NSInteger rearIndex  =  [self validateNextPageIndexWithPageIndex:self.currentPageIndex + 1];
   // NSLog(@"self.currentPageIndex=%@", @(self.currentPageIndex));
    if (!self.contentViews) {
        self.contentViews  =  [[NSMutableArray alloc] init];
    }
    [self.contentViews removeAllObjects];
    
    if (self.contentViewAtIndex) {
        
        [self.contentViews addObject:self.contentViewAtIndex(previousIndex)];
        [self.contentViews addObject:self.contentViewAtIndex(self.currentPageIndex)];
        [self.contentViews addObject:self.contentViewAtIndex(rearIndex)];

    }
    
    
}

- (NSInteger)validateNextPageIndexWithPageIndex:(NSInteger)pageIndex{
    if (pageIndex < 0) {
        return self.totalPages - 1;
    }
    else if (pageIndex >=  self.totalPages) {
        return 0;
    }
    else {
        return pageIndex;
    }
}

- (void)contentViewTapped:(UITapGestureRecognizer *)recognizer{
    self.tapActionBlock(self.currentPageIndex);
}

- (void)hidePageControl{
    
    self.pageControl.hidden  =  YES;
}

-(void)hideCureView{
    [cure removeFromSuperview];
    cure = nil;
}

#pragma mark - 响应事件 -

- (void)animationTimerDidFire:(NSTimer *)timer{
    NSInteger index = self.scrollView.contentOffset.x/VIEW_WIDTH;
    [self.scrollView setContentOffset:CGPointMake(VIEW_WIDTH *index + VIEW_WIDTH, 0) animated:YES];
}

#pragma mark - Scroll view delegate -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.animationTimer pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.animationTimer resumeTimerAfterInterval:self.animationInterval];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x >=  VIEW_WIDTH * 2) {
        self.currentPageIndex  =  [self validateNextPageIndexWithPageIndex:++_currentPageIndex];
        [self configureContentViews];
    }
    else if (scrollView.contentOffset.x <=  0) {
        self.currentPageIndex  =  [self validateNextPageIndexWithPageIndex:--_currentPageIndex];
        [self configureContentViews];
    }
    
    self.pageControl.currentPage  =  self.currentPageIndex;
}
//减速停止时执行
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [scrollView setContentOffset:CGPointMake(VIEW_WIDTH, 0) animated:YES];
}

@end
