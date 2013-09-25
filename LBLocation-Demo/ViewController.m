//
//  ViewController.m
//  LBLocation-Demo
//
//  Created by Lucian Boboc on 9/25/13.
//  Copyright (c) 2013 Lucian Boboc. All rights reserved.
//

#import "ViewController.h"
#import "LBLocation.h"

@interface ViewController ()
@property (strong, nonatomic) LBLocation *location;
@property (strong, nonatomic) CLLocation *myLocation;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    __weak ViewController *weakSelf = self;
    self.location = [[LBLocation alloc] initWithLocationUpdateBlock:^(CLLocation *location) {
        weakSelf.myLocation = location;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
