//
//  User.h
//  RHFirmModelDemo
//
//  Created by Hanran Liu on 15/1/9.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import "Address.h"

@interface User : RHFirmModel

@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) NSString *age;

@property (nonatomic, strong) Address  *address;

@end
