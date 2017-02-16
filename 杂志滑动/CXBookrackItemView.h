//
//  CXBookrackItemView.h
//  杂志滑动
//
//  Created by 永来 付 on 2017/2/15.
//  Copyright © 2017年 caixin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXBookItemModel.h"

@interface CXBookrackItemView : UIView

@property (nonatomic, strong) UIImageView *imageView;

+ (instancetype)createBookrackItemViewWithFrame:(CGRect)frame
                                           Item:(CXBookItemModel *)bookItem;

@end
