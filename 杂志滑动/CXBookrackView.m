//
//  CXBookrackView.m
//  杂志滑动
//
//  Created by 永来 付 on 2017/2/15.
//  Copyright © 2017年 caixin. All rights reserved.
//

#import "CXBookrackView.h"
#import "CXBookrackItemView.h"
#import "CXBookItemModel.h"
#import <pop/POP.h>

#define ScreenWidth             [UIScreen mainScreen].bounds.size.width
#define ScreenHeight            [UIScreen mainScreen].bounds.size.height

#define W(x) ceilf(((float)x * ((float)(ScreenWidth)/(float)375)))

#define MaxShowViewNumber 5

@interface CXBookrackView ()

@property (nonatomic, strong) NSMutableArray<CXBookItemModel *> *itemList;
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
    
    self.itemList       = [NSMutableArray array];
    self.itemViewList   = [NSMutableArray array];
    
    self.alphaList      = @[@1,@0.7,@0.5,@0.3,@0.2];
    
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
    
    for (NSInteger i = 1; i < 6; i++) {
        NSString *imageName = [NSString stringWithFormat:@"image_%ld.jpg",(long)i];
        CXBookItemModel *item = [[CXBookItemModel alloc] init];
        item.imageName = imageName;
        [self.itemList addObject:item];
    }

    CXBookItemModel *item = [[CXBookItemModel alloc] init];
    item.imageName = @"image_5.jpg";
    [self.itemList insertObject:item atIndex:2];
    
    [self.itemList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //多支持5张
        if (idx == MaxShowViewNumber) {
            *stop = YES;
            return ;
        }
        
        CXBookrackItemView *bookView = [[CXBookrackItemView alloc] initWithFrame:[self getFrameWithIndex:idx]];
        bookView.imageView.image = [UIImage imageNamed:[(CXBookItemModel *)obj imageName]];
        bookView.tag = idx;
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
            [self swipeUp];
            
        }
            break;
        case UISwipeGestureRecognizerDirectionDown:
        {
            NSLog(@"向下滑");
            [self swipeDown];
        }
        default:
            break;
    }
}

//向上滑
- (void)swipeUp {
    
    //取出最后一个view并删除
    CXBookrackItemView *obj = [self.itemViewList lastObject];
    [self.itemViewList removeObject:obj];
    
    if (self.itemList.count > MaxShowViewNumber) {
        
        [UIView animateWithDuration:0.4 animations:^{
            obj.alpha = 0;
        } completion:^(BOOL finished) {
            [obj removeFromSuperview];
        }];
        
        
        CXBookrackItemView *bookView = self.itemViewList[0];
        NSInteger preIndex = 0;
        if (bookView.tag == 0) {
            preIndex = MaxShowViewNumber - 1;
        } else {
            preIndex = bookView.tag - 1;
        }
        
        CGRect preViewFrame = [self getFrameWithIndex:0];
        preViewFrame.origin.y = ScreenHeight;
        CXBookrackItemView *preBookView = [CXBookrackItemView createBookrackItemViewWithFrame:preViewFrame Item:self.itemList[preIndex]];
//        preBookView.alpha = 0;
        preBookView.tag = preIndex;
        [self addSubview:preBookView];
        [self.itemViewList insertObject:preBookView atIndex:0];
        
        POPSpringAnimation *psa = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        psa.toValue = [NSValue valueWithCGRect:[self getFrameWithIndex:0]];
        psa.springBounciness = 0;
        [preBookView pop_addAnimation:psa forKey:@"frame"];
        
//        [UIView animateWithDuration:0.4 animations:^{
//            preBookView.frame = [self getFrameWithIndex:0];
////            preBookView.alpha = 1;
//        }];
        
    } else {
        [self.itemViewList insertObject:obj atIndex:0];
    }
    
    
    
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

//向下滑
- (void)swipeDown {
    CXBookrackItemView *bookView = self.itemViewList[0];
    
    [self.itemViewList removeObjectAtIndex:0];
    
    if (self.itemList.count > MaxShowViewNumber) {
        
        NSInteger addNewItemIndex = 0;
        
        CXBookrackItemView *lastItemView = self.itemViewList.lastObject;
        if (lastItemView.tag >= MaxShowViewNumber - 1) {
            addNewItemIndex = 0;
        } else {
            addNewItemIndex = lastItemView.tag + 1;
        }
        
        CXBookrackItemView *view = [CXBookrackItemView createBookrackItemViewWithFrame:[self getFrameWithIndex:MaxShowViewNumber - 1] Item:self.itemList[addNewItemIndex]];
        view.tag = addNewItemIndex;
        [self.itemViewList addObject:view];
        [self addSubview:view];
        [self sendSubviewToBack:view];
        
        CGRect frame = bookView.frame;
        frame.origin.y = ScreenHeight;
        POPSpringAnimation *psa = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        psa.toValue = [NSValue valueWithCGRect:frame];
        psa.springBounciness = 2;
        [bookView pop_addAnimation:psa forKey:@"frame"];
        
        //        self.userInteractionEnabled = NO;
//        CGRect frame = bookView.frame;
//        frame.origin.y = ScreenHeight ;
        [UIView animateWithDuration:0.5 animations:^{
//            bookView.frame = frame;
            bookView.alpha = 0.2;
        } completion:^(BOOL finished) {
            [bookView removeFromSuperview];
            //            self.userInteractionEnabled = YES;
        }];
    } else {
        
        [self.itemViewList addObject:bookView];
    }

    [self.itemViewList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CXBookrackItemView *bookView = obj;
        
        POPSpringAnimation *psa = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        psa.toValue = [NSValue valueWithCGRect:[self getFrameWithIndex:idx]];
        psa.springBounciness = 12 - idx;
        [bookView pop_addAnimation:psa forKey:@"frame"];
        
        bookView.imageView.alpha = [self.alphaList[idx] floatValue];
        
        if (idx == self.itemViewList.count - 1) {
            [self sendSubviewToBack:bookView];
            UIScrollView
        }
    }];
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
