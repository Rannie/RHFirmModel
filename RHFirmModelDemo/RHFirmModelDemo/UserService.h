//
//  UserService.h
//  RHFirmModelDemo
//
//  Created by Hanran Liu on 15/1/9.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UserService : NSObject

+ (void)fetchUsersWithSuccess:(void (^)(NSArray *users))success failure:(void (^)(NSError *error))failure;

@end
