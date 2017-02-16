//
//  CXBookrackItemView.m
//  杂志滑动
//
//  Created by 永来 付 on 2017/2/15.
//  Copyright © 2017年 caixin. All rights reserved.
//

#import "CXBookrackItemView.h"

@implementation CXBookrackItemView

+ (instancetype)createBookrackItemViewWithFrame:(CGRect)frame Item:(CXBookItemModel *)bookItem {
    CXBookrackItemView *view = [[CXBookrackItemView alloc] initWithFrame:frame];
    view.imageView.image = [UIImage imageNamed:bookItem.imageName];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self bulidView];
    }
    return self;
}

- (void)bulidView {
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self addSubview:self.imageView];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
}

@end
