//
//  RHFirmModel.m
//  RHFirmModelDemo
//
//  Created by Hanran Liu on 15/1/9.
//  Copyright (c) 2015年 ran. All rights reserved.
//

#import "RHFirmModel.h"
#import <objc/runtime.h>
#import "EXTRuntimeExtensions.h"
#import "EXTScope.h"

#ifdef DEBUG
#   define RLog(...) NSLog((@"%s [Line %d] %@"), __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#else
#   define RLog(...)
#endif

static void *RHFModelCachedPropertiesKey = &RHFModelCachedPropertiesKey;

FOUNDATION_STATIC_INLINE BOOL UValidateAndSetValue(id obj, NSString *key, id value, BOOL forceUpdate, NSError **error) {
  __autoreleasing id validateValue = value;

  @try {
    if (![obj validateValue:&validateValue forKey:key error:error]) return NO;
    
    if (forceUpdate || validateValue != value) {
      [obj setValue:value forKey:key];
    }
    
    return YES;
  }
  @catch (NSException *exception) {
    RLog(@"Model : Caught exception setting key \"%@\" : %@", key, exception);
    
  #ifdef DEBUG
    @throw exception;
  #endif
  }
}

SEL RHFSelectorWithCapitalizedKeyPattern(const char *prefix, NSString *key, const char *suffix) {
  NSUInteger prefixLength = strlen(prefix);
  NSUInteger suffixLength = strlen(suffix);

  NSString *initial = [key substringToIndex:1].uppercaseString;
  NSUInteger initialLength = [initial maximumLengthOfBytesUsingEncoding:NSUTF8StringEncoding];

  NSString *rest = [key substringFromIndex:1];
  NSUInteger restLength = [rest maximumLengthOfBytesUsingEncoding:NSUTF8StringEncoding];

  char selector[prefixLength + initialLength + restLength + suffixLength + 1];
  memcpy(selector, prefix, prefixLength);

  BOOL success = [initial getBytes:selector + prefixLength maxLength:initialLength usedLength:&initialLength encoding:NSUTF8StringEncoding options:0 range:NSMakeRange(0, initial.length) remainingRange:NULL];
  if (!success) return NULL;

  success = [rest getBytes:selector + prefixLength + initialLength maxLength:restLength usedLength:&restLength encoding:NSUTF8StringEncoding options:0 range:NSMakeRange(0, rest.length) remainingRange:NULL];
  if (!success) return NULL;

  memcpy(selector + prefixLength + initialLength + restLength, suffix, suffixLength);
  selector[prefixLength + initialLength + restLength + suffixLength] = '\0';

  return sel_registerName(selector);
}

@interface RHFirmModel ()
+ (void)enumeratePropertiesUsingBlock:(void (^)(objc_property_t property, BOOL *stop))block;
@end

@implementation RHFirmModel

  #pragma mark - Runtime Reflection
+ (Class)propertyClassWithName:(NSString *)name {
  objc_property_t property = class_getProperty(self, [name UTF8String]);
  ext_propertyAttributes *attributes = ext_copyPropertyAttributes(property);
  @onExit {
    free(attributes);
  };
  return [attributes->objectClass copy];
}

+ (void)enumeratePropertiesUsingBlock:(void (^)(objc_property_t, BOOL *))block {
  Class c = self;
  BOOL stop = NO;

  while (!stop && ![c isEqual:RHFirmModel.class]) {
    unsigned count = 0;
    objc_property_t *properties = class_copyPropertyList(c, &count);
    
    c = c.superclass;
    if (properties == NULL) continue;
    
    @onExit {
      free(properties);
    };
    
    for (unsigned i = 0; i < count; i++) {
      block(properties[i], &stop);
      if (stop) break;
    }
  }
}

+ (NSSet *)propertyKeys {
  NSSet *cachedKeys = objc_getAssociatedObject(self, RHFModelCachedPropertiesKey);
  if (cachedKeys != nil) return cachedKeys;

  NSMutableSet *set = [NSMutableSet set];

  [self enumeratePropertiesUsingBlock:^(objc_property_t property, BOOL *stop) {
    ext_propertyAttributes *attributes = ext_copyPropertyAttributes(property);
    @onExit {
      free(attributes);
    };
    
    if (attributes->readonly && attributes->ivar == NULL) return;
    
    NSString *key = @(property_getName(property));
    [set addObject:key];
  }];

  objc_setAssociatedObject(set, RHFModelCachedPropertiesKey, set, OBJC_ASSOCIATION_COPY);

  return set;
  }

  #pragma mark - Initialization
  - (instancetype)init {
  return [super init];
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
  return [self modelWithDictionary:dictionary error:nil];
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary error:(NSError *__autoreleasing *)error {
  return [[self alloc] initWithDictionary:dictionary error:error];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError *__autoreleasing *)error {
  if (self = [super init]) {
    
    for (NSString *key in dictionary) {
        
      if (![[[self class] propertyKeys] containsObject:key]) {
        [self setValue:dictionary[key] forUndefinedKey:key];
        continue;
      }
      
      __autoreleasing id value = dictionary[key];
      
      if ([value isEqual:NSNull.null]) value = nil;
      
      if ([value isKindOfClass:NSDictionary.class]) {
        Class propertyClass = [self.class propertyClassWithName:key];
        if ([propertyClass isSubclassOfClass:RHFirmModel.class]) {
          value = [propertyClass modelWithDictionary:value error:error];
        }
      } else if ([value isKindOfClass:NSArray.class]) {
        RLog(@"Model : the property (%@) is array type. please custom setter if needed", key);
      }
      
      BOOL success = UValidateAndSetValue(self, key, value, YES, error);
      if (!success) return nil;
    }
    
  }
  return self;
}

- (NSDictionary *)dictionaryValue {
  NSDictionary *dict = [self dictionaryWithValuesForKeys:self.class.propertyKeys.allObjects];
  NSMutableDictionary *mutableDict = [dict mutableCopy];
  for (id obj in dict.allValues) {
    if ([obj isKindOfClass:RHFirmModel.class]) {
      NSArray *keys = [dict allKeysForObject:obj];
      id newValue = [(RHFirmModel *)obj dictionaryValue];
      for (NSString *key in keys) {
        mutableDict[key] = newValue;
      }
    }
  }
  return [mutableDict copy];
}

# pragma mark - Merge
- (void)mergeValueForKey:(NSString *)key fromModel:(RHFirmModel *)model {
  NSParameterAssert(key);

  SEL selector = RHFSelectorWithCapitalizedKeyPattern("merge", key, "FromModel:");
  if (![self respondsToSelector:selector]) {
    if (model != nil) {
      [self setValue:[model valueForKey:key] forKey:key];
    }
    
    return;
  }

  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
  invocation.target = self;
  invocation.selector = selector;
  [invocation setArgument:&model atIndex:2];
  [invocation invoke];
}

- (void)mergeValuesForKeysFromModel:(RHFirmModel *)model {
  NSSet *propertyKeys = model.class.propertyKeys;
  for (NSString *key in self.class.propertyKeys) {
    if (![propertyKeys containsObject:key]) continue;
    
    [self mergeValueForKey:key fromModel:model];
  }
}

  # pragma mark - Other Method
- (BOOL)isEqual:(RHFirmModel *)object {
  if (self == object) return YES;
  if (![object isMemberOfClass:self.class]) return NO;

  for (NSString *key in self.class.propertyKeys) {
    id selfValue = [self valueForKey:key];
    id modelValue = [object valueForKey:key];
    
    BOOL valuesEqual = ((selfValue == nil && modelValue == nil) || [selfValue isEqual:modelValue]);
    if (!valuesEqual) return NO;
  }

  return YES;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
// subclass impl if needed...
}

- (NSString *)toJSONString {
  NSData *jsonData = nil;
  NSError *jsonError = nil;

  @try {
    NSDictionary *dict = [self dictionaryValue];
    jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&jsonError];
  }
  @catch (NSException *exception) {
    RLog(@"Model : to json exception %@", exception.description);
    return nil;
  }

  return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

  - (NSDictionary *)toDictionaryWithKeys:(NSArray *)propertyNames {
  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:propertyNames.count];
  id value = nil;

  for (NSString *propertyName in propertyNames) {
    if (![self.class.propertyKeys containsObject:propertyName]) continue;
    
    value = self.dictionaryValue[propertyName];
    
    if ([value isKindOfClass:RHFirmModel.class]) {
        RHFirmModel *temp = value;
        value = [temp toDictionaryWithKeys:[temp.class.propertyKeys allObjects]];
    }
    
    if ([value isKindOfClass:NSArray.class]) {
      NSArray *temp = value;
      id obj = [temp firstObject];
      if ([obj isKindOfClass:RHFirmModel.class]) {
        __autoreleasing NSMutableArray *content = [NSMutableArray arrayWithCapacity:temp.count];
        
        for (RHFirmModel *model in temp) {
          __autoreleasing NSDictionary *tempDict = [model toDictionaryWithKeys:[model.class.propertyKeys allObjects]];
          [content addObject:tempDict];
        }
        
        value = content;
      }
    }
    
    [dict setValue:value forKey:propertyName];
  }

  return [dict copy];
  }

  - (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p> %@", self.class, self, self.dictionaryValue];
}


@end
