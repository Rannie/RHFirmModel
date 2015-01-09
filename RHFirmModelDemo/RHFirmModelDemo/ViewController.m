//
//  ViewController.m
//  RHFirmModelDemo
//
//  Created by Hanran Liu on 15/1/9.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import "ViewController.h"
#import "UserService.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self fetchUser];
}

- (void)fetchUser {
  [UserService fetchUsersWithSuccess:^(NSArray *users) {
    NSLog(@"users : %@", users);
    NSLog(@"first user : %@", [(User *)[users firstObject] toDictionaryWithKeys:@[@"name", @"sex", @"age"]]);
    User *user = [users lastObject];
    NSLog(@"json user : %@", [user toJSONString]);
  } failure:nil];
}

@end
