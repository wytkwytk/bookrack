//
//  ViewController.m
//  杂志滑动
//
//  Created by 永来 付 on 2017/2/15.
//  Copyright © 2017年 caixin. All rights reserved.
//

#import "ViewController.h"
#import "CXBookrackView.h"

@interface ViewController ()

@property (nonatomic, strong) CXBookrackView *bookrackView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.bookrackView = [[CXBookrackView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.bookrackView];
    
}


@end
