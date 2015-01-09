//
//  User.m
//  RHFirmModelDemo
//
//  Created by Hanran Liu on 15/1/9.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import "User.h"

@implementation User

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
  if ([key isEqualToString:@"id"]) {
    self.user_id = value;
  }
}

@end
