//
//  CXScrollBookrackView.m
//  杂志滑动
//
//  Created by 永来 付 on 2017/2/16.
//  Copyright © 2017年 caixin. All rights reserved.
//

#import "CXScrollBookrackView.h"
#import "CXBookItemModel.h"
#import "CXBookrackItemView.h"
#import <pop/POP.h>

#define ScreenWidth             [UIScreen mainScreen].bounds.size.width
#define ScreenHeight            [UIScreen mainScreen].bounds.size.height

#define W(x) ceilf(((float)x * ((float)(ScreenWidth)/(float)375)))

#define MaxShowViewNumber 5

#define MainItemOriginY W(160)
#define MainItemOriginX W(40)
#define MainItemSizeWidth ceil((ScreenWidth - W(40)*2))
#define MainItemSizeHeight W(390)

@interface CXScrollBookrackView ()

@property (nonatomic, strong)   NSMutableArray<CXBookItemModel *> *itemList;
@property (nonatomic, strong)   NSMutableArray *itemViewList;
@property (nonatomic, copy)     NSArray *alphaList;
@property (nonatomic, strong)   NSMutableArray *cacheViewList;

@property (nonatomic, strong)   CXBookrackItemView *addNewItemView;

@end

@implementation CXScrollBookrackView

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
    self.cacheViewList  = [NSMutableArray array];
    
}

- (void)bulidView {
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [self addGestureRecognizer:panGes];

    
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

- (void)swipe:(UIPanGestureRecognizer *)pan {
    static CGFloat beginY = 0;
    CGFloat offsetY = 0;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            beginY = [pan translationInView:self].y;
            
            NSLog(@"开始:%f",beginY);
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            offsetY = [pan translationInView:self].y - beginY;
            beginY = [pan translationInView:self].y;
            
            NSLog(@"offset:%f begin:%f",offsetY,beginY);
            [self allIetmRefreshFrameWithOffsetY:offsetY/15.f];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            
            NSLog(@"停止:%f",[pan velocityInView:self].y);
            beginY = 0;
            
            POPDecayAnimation *decayAnim = [POPDecayAnimation animation];
            decayAnim.fromValue = @(0);
            decayAnim.velocity = @([pan velocityInView:self].y);
            decayAnim.property = [self animationProperty];
            [self pop_addAnimation:decayAnim forKey:@"decay"];
        }
        default:
            break;
    }
    
}

- (void)scrollToFinalLocation:(id)velocity {
    CGFloat offsetY = [self getFinalOffset];
    POPBasicAnimation *springAnim = [POPBasicAnimation animation];
    springAnim.fromValue = @(0);
    springAnim.toValue = @(offsetY);
//    springAnim.velocity = velocity;
    springAnim.property = [self springProperty];
    [self pop_addAnimation:springAnim forKey:@"Finalspring"];
    
}

- (POPMutableAnimatableProperty *)springProperty {
    __block CGFloat star = 0;
    return [POPMutableAnimatableProperty propertyWithName:@"spring" initializer:^(POPMutableAnimatableProperty *prop) {
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            NSNumber *number = @(values[0]);
            CGFloat y = [number floatValue];
            [self allIetmRefreshFrameWithOffsetY:(y - star)];
            star = y;
        };
    }];
}

//减速时offset的变化
- (POPMutableAnimatableProperty *)animationProperty {
    
    __block CGFloat star = 0;
    
    return [POPMutableAnimatableProperty propertyWithName:@"scroll" initializer:^(POPMutableAnimatableProperty *prop) {
        prop.writeBlock = ^(id obj, const CGFloat values[]){
            NSNumber *number = @(values[0]);
            CGFloat y = [number floatValue];
            [self allIetmRefreshFrameWithOffsetY:(y - star)/15.f];
            star = y;
            
            POPDecayAnimation *decayAnim = [self pop_animationForKey:@"decay"];
            NSLog(@"%@",decayAnim.velocity);
            if ([decayAnim.velocity floatValue] <= 80 * 15) {
                [self pop_removeAllAnimations];
                [self scrollToFinalLocation:decayAnim.velocity];
            }
            
        };
    }];
    
}

- (void)allIetmRefreshFrameWithOffsetY:(CGFloat)offsetY {
    
    BOOL removeFirstView = NO;
    
    NSArray *tempArray = [NSArray arrayWithArray:self.itemViewList];
    
    for (CXBookrackItemView *view in tempArray) {
        
        view.frame = [self getNewFrameWithCurrentFrame:view.frame offsetY:offsetY];
        if (CGRectGetMinY(view.frame) > ScreenHeight) {
            removeFirstView = YES;
        }
        
//        if (ScreenHeight - CGRectGetMaxY(view.frame) > MainItemOriginY) {
            view.alpha = ((ScreenHeight - CGRectGetMinY(view.frame)) / ((float)ScreenHeight - (float)MainItemOriginY - 50));
//        }
    }
    
    if (removeFirstView) {
        CXBookrackItemView *view = self.itemViewList[0];
        [view removeFromSuperview];
        [self.itemViewList removeObject:view];
    }
    
    CXBookrackItemView *lastView = [self.itemViewList lastObject];
    if (lastView.frame.origin.y > W(35) && !self.addNewItemView) {
        
        NSInteger index = 0;
        if (lastView.tag + 1 >= self.itemList.count ) {
            index = 0;
        } else {
            index = lastView.tag + 1;
        }
        
        self.addNewItemView = [self getItemViewWithItem:self.itemList[index] index:MaxShowViewNumber - 1];
        self.addNewItemView.tag = index;
        [self addSubview:self.addNewItemView];
        [self sendSubviewToBack:self.addNewItemView];
        
    } else if (lastView.frame.origin.y >= W(70) && self.addNewItemView) {
        [self.itemViewList addObject:self.addNewItemView];
        self.addNewItemView = nil;
    }
}

- (CXBookrackItemView *)getItemViewWithItem:(CXBookItemModel *)bookItem index:(NSInteger)index {
    CXBookrackItemView *view = [CXBookrackItemView createBookrackItemViewWithFrame:[self getFrameWithIndex:index] Item:bookItem];
    return view;
}

//获取初始化时每个item的frame
- (CGRect)getFrameWithIndex:(NSInteger)index {
    CGFloat width   = ceil((ScreenWidth - W(40)*2) * pow(0.71,index));
    CGFloat height  = ceil(W(390) * pow(0.71, index));
    CGFloat x       = (ScreenWidth - width)/2;
    CGFloat y       = W(160) * pow(0.68, index);
    
    return CGRectMake(x, y, width, height);
}

//计算不同滑动位置item的frame
- (CGRect)getNewFrameWithCurrentFrame:(CGRect)currentFrame offsetY:(CGFloat)offsetY {
    CGFloat currentY = CGRectGetMinY(currentFrame);
    CGFloat endY = currentY + offsetY;
    
    if (endY < MainItemOriginY) {
        if (endY < W(35)) {
            endY = W(35);
        }
        
        CGFloat width = MainItemSizeWidth -  (MainItemSizeWidth - W(82)) * (MainItemOriginY - endY) / W(125.f);
        CGFloat height = (width * MainItemSizeHeight) / MainItemSizeWidth;
        CGFloat x = (ScreenWidth - width)/2;
        
        return CGRectMake(x, endY, width, height);
        
    } else {
        CGFloat width   = MainItemSizeWidth;
        CGFloat height  = MainItemSizeHeight;
        CGFloat x       = MainItemOriginX;
        CGFloat y       = currentY + offsetY * 15;
        return CGRectMake(x, y, width, height);
    }
    
    return currentFrame;
}

//计算停止滑动时 需要移动到正确位置的offset
- (CGFloat)getFinalOffset {
    CXBookrackItemView *firstView = self.itemViewList[0];
    CXBookrackItemView *secondView = self.itemViewList[1];
    
    CGFloat firstOffset = MainItemOriginY - CGRectGetMinY(firstView.frame);
    CGFloat secondOffset = MainItemOriginY - CGRectGetMinY(secondView.frame);
    
    return fabs(firstOffset) < fabs(secondOffset) ? firstOffset : secondOffset;
    
}

@end
