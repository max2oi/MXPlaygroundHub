//
//  ViewController.m
//  MXPlaygroundHubExample
//
//  Created by max2oi on 2018/7/18.
//  Copyright © 2018 max2oi. All rights reserved.
//

#import "ViewController.h"
#import "MXPlaygroundProtocol.h"
@interface ViewController ()<MXPlaygroundProtocol>

@end

@implementation ViewController
MXHUBIMP(@"type1", @"example", @"long description long description long description long description long description long description")
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.grayColor;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
