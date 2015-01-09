//
//  Address.h
//  RHFirmModelDemo
//
//  Created by Hanran Liu on 15/1/9.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import "RHFirmModel.h"

@interface Address : RHFirmModel

@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *postcode;

@end
