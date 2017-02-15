//
//  CXBookrackView.m
//  杂志滑动
//
//  Created by 永来 付 on 2017/2/15.
//  Copyright © 2017年 caixin. All rights reserved.
//

#import "CXBookrackView.h"
#import "CXBookrackItemView.h"
#import <pop/POP.h>

#define ScreenWidth             [UIScreen mainScreen].bounds.size.width
#define ScreenHeight            [UIScreen mainScreen].bounds.size.height

#define W(x) ceilf(((float)x * ((float)(ScreenWidth)/(float)375)))

@interface CXBookrackView ()

@property (nonatomic, copy) NSArray *itemList;
@property (nonatomic, strong) NSMutableArray *itemViewList;
@property (nonatomic, copy) NSArray *alphaList;

@end

@implementation CXBookrackView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initData];
        [self bulidView];
        
    }
    return self;
}

- (void)initData {
    self.itemList = @[@"image_1.jpg",@"image_2.jpg",@"image_3.jpg",@"image_4.jpg",@"image_5.jpg"];
    self.alphaList = @[@1,@0.7,@0.5,@0.3,@0.2];
    self.itemViewList = [NSMutableArray array];
    
    
}

- (void)bulidView {
    
    UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    upSwipe.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:upSwipe];
    
    UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    downSwipe.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:downSwipe];
    

    [self.itemList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CXBookrackItemView *bookView = [[CXBookrackItemView alloc] initWithFrame:[self getFrameWithIndex:idx]];
        bookView.imageView.image = [UIImage imageNamed:obj];
        [self.itemViewList addObject:bookView];
        [self addSubview:bookView];
        [self sendSubviewToBack:bookView];
    }];
    
}

- (void)swipe:(UISwipeGestureRecognizer *)swipeGR {
    switch (swipeGR.direction) {
        case UISwipeGestureRecognizerDirectionUp:
        {
            NSLog(@"向上滑");
            
            id obj = [self.itemViewList lastObject];
            [self.itemViewList removeObject:obj];
            [self.itemViewList insertObject:obj atIndex:0];
            
            [self.itemViewList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                CXBookrackItemView *bookView = obj;
                
                POPSpringAnimation *psa = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
                psa.toValue = [NSValue valueWithCGRect:[self getFrameWithIndex:idx]];
                psa.springBounciness = 6;
                [bookView pop_addAnimation:psa forKey:@"frame"];
                bookView.imageView.alpha = [self.alphaList[idx] floatValue];
                
                if (idx == 0) {
                    [self bringSubviewToFront:bookView];
                }
            }];
            
        }
            break;
        case UISwipeGestureRecognizerDirectionDown:
        {
            NSLog(@"向下滑");
            id obj = self.itemViewList[0];
            [self.itemViewList removeObjectAtIndex:0];
            [self.itemViewList addObject:obj];
            
            [self.itemViewList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                CXBookrackItemView *bookView = obj;
                
                POPSpringAnimation *psa = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
                psa.toValue = [NSValue valueWithCGRect:[self getFrameWithIndex:idx]];
                psa.springBounciness = 6;
                [bookView pop_addAnimation:psa forKey:@"frame"];
                
                bookView.imageView.alpha = [self.alphaList[idx] floatValue];
                
                if (idx == self.itemViewList.count - 1) {
                    [self sendSubviewToBack:bookView];
                }
            }];
            
            
        }
        default:
            break;
    }
}

//获取每个item的frame
- (CGRect)getFrameWithIndex:(NSInteger)index {
    
    
    CGFloat width   = ceil((ScreenWidth - W(40)*2) * pow(0.71,index));
    CGFloat height  = ceil(W(390) * pow(0.71, index));
    CGFloat x       = (ScreenWidth - width)/2;
    CGFloat y       = W(160) * pow(0.68, index);
    
    return CGRectMake(x, y, width, height);
    
}

@end
