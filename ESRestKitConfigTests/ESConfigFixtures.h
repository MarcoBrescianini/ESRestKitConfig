//
//  ESConfigFixtures.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 19/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESConfigFixtures : NSObject


+(NSDictionary*)routesConfigDictionary;
+(NSDictionary*)mappingConfigDictionary;
+(NSDictionary*)responseConfigDictionary;

+ (NSDictionary *)requestConfigDictionary;

+(NSString*)writeRoutesFile:(NSDictionary*)config;
+(NSString*)writeMappingFile:(NSDictionary*)config;
+(NSString*)writeResponseFile:(NSDictionary*)config;

+ (NSString *)writeRequestFile:(NSDictionary *)config;
@end
