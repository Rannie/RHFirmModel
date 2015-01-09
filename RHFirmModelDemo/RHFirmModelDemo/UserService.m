//
//  UserService.m
//  RHFirmModelDemo
//
//  Created by Hanran Liu on 15/1/9.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import "UserService.h"

@implementation UserService

+ (void)fetchUsersWithSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
  //do sth fetch data
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    NSDictionary *response = [self responseObject];
    NSArray *list = response[@"users"];
    NSMutableArray *content = [NSMutableArray arrayWithCapacity:list.count];
    for (NSDictionary *userDict in list) {
      [content addObject:[User modelWithDictionary:userDict]];
    }
    if (success) success([content copy]);
  });
}

+ (NSDictionary *)responseObject {
  return @{@"users": @[@{
                         @"id": @"4248292",
                         @"name": @"ran",
                         @"sex": @"female",
                         @"age": @"24",
                         @"address": @{
                             @"city": @"beijing",
                             @"street": @"wangjing",
                             @"postcode": @"200000"
                             }
                         },
                       @{
                         @"id": @"232532",
                         @"name": @"liu",
                         @"sex": @"female",
                         @"age": @"42",
                         @"address": @{
                             @"city": @"beijing",
                             @"street": @"wudaokou",
                             @"postcode": @"200000"
                             }
                         }]};
}

@end
