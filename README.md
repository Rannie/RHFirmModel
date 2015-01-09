# RHFirmModel
============================

A lightness base model.<br>
Thanks to Mantle and JSONModel.<br>
RHFirmModel support nested dictionary converted into model.Like a user has a address property which class is RHFirmModel's subclass.It also can make the value to be a model class instance.

##Feature

- [x] Model ---> Dictionary (Specify Keys or Whole)
- [x] Model <--- Dictionary (By KVC)
- [x] Model ---> JSONString 
- [x] Model <--- JSONString
- [x] Model <--> Model (Merge)
- [ ] Model Storage

##Usage

1. Dictionary to Model


		+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;
		+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary error:(NSError **)error;
		- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)error;
		
	If i have dict object like this:
	
		@{
          @"id": @"4248292",
          @"name": @"ran",
          @"sex": @"female",
          @"age": @"24",
          @"address": @{
              @"city": @"beijing",
              @"street": @"wangjing",
              @"postcode": @"200000"
              }
          }
         	
	Use 
	
		[User modelWithDictionary:userDict]
		
 	Set values to a User instance.
	
2. Model to Dictionary

		@property (nonatomic, copy, readonly) NSDictionary *dictionaryValue;
		- (NSDictionary *)toDictionaryWithKeys:(NSArray *)propertyNames;

	Like this:
		
		NSLog(@"user : %@", [user toDictionaryWithKeys:@[@"name", @"sex", @"age"]]);
	
	Output:
		
		user : {
		    age = 24;
		    name = ran;
		    sex = female;
		}
		
3. To JSON
	
		- (NSString *)toJSONString;
	
	Like this:
	
		NSLog(@"json user : %@", [user toJSONString]);
		
	Output:
	
		json user : {"age":"42","sex":"female","user_id":"232532","name":"liu","address":{"street":"wudaokou","city":"beijing","postcode":"200000"}}

4. Merge

		- (void)mergeValueForKey:(NSString *)key fromModel:(RHFirmModel *)model;
		- (void)mergeValuesForKeysFromModel:(RHFirmModel *)model;
		

See demo or RHFirmModel interface file to know more.


##Liscence

RHFirmModel is available under the MIT license. See the LICENSE file for more info.