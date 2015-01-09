//
//  RHFirmModel.h
//  RHFirmModelDemo
//
//  Created by Hanran Liu on 15/1/9.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RHFirmModel : NSObject

@property (nonatomic, copy, readonly) NSDictionary *dictionaryValue;

+ (NSSet *)propertyKeys;

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary error:(NSError **)error;

- (instancetype)init;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)error;

- (void)mergeValueForKey:(NSString *)key fromModel:(RHFirmModel *)model;
- (void)mergeValuesForKeysFromModel:(RHFirmModel *)model;

+ (instancetype)modelWithJSONString:(NSString *)JSONString;
- (instancetype)initWithJSONString:(NSString *)JSONString error:(NSError **)error;

- (NSString *)toJSONString;

- (NSDictionary *)toDictionaryWithKeys:(NSArray *)propertyNames;

- (BOOL)isEqual:(RHFirmModel *)object;

- (NSString *)description;

@end
