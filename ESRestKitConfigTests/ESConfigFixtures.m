//
//  ESConfigFixtures.m
//  Engineering Solutions
//
//  Created by Marco Brescianini on 19/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import "ESConfigFixtures.h"

@implementation ESConfigFixtures

+(NSDictionary *)routesConfigDictionary
{
	return @{
					 @"foo" : @{
							 @"path" : @"foo/",
							 @"method" : @"GET"
							 
							 },
					 @"bar" : @{
							 @"path" : @"bar/",
							 @"method" : @"POST"
							 }
			 };
}

+(NSDictionary *)mappingConfigDictionary
{
	return @{
					 @"foo" : @{
							 @"Identification" : @[@"identifier"],
							 @"Modification" : @"updatedAt",
							 @"Entity" : @"Foo",
							 @"Attributes" :  @{
									 @"id" : @"identifier",
									 @"firstname" : @"name",
									 @"lastname" : @"lastname",
									 @"information" : @"info",
									 @"created_at" : @"createdAt",
									 @"updated_at" : @"updatedAt"
									 }
							 },
					 @"bar" : @{
							 @"Identification" : @[@"identifier"],
							 @"Modification" : @"updatedAt",
							 @"Entity" : @"Bar",
							 @"Attributes" : @{
									 @"id" : @"identifier",
									 @"cost" : @"cost",
									 @"header_url" : @"headerURL",
									 @"name" : @"name",
									 @"created_at" : @"createdAt",
									 @"updated_at" : @"updatedAt"
									 }
							 }
			 };

}

+(NSDictionary *)responseConfigDictionary
{
	return @{

					 @"foo" : @{
							 @"route" : @"foo",
							 @"keypath" : @"keypath",
							 @"method" : @"GET",
							 @"mapping" : @"foo",
							 @"statusCode" : @200
							 },
					 @"bar" : @{
							 @"route" : @"bar",
							 @"keypath" : @"keypath",
							 @"method" : @"POST",
							 @"mapping" : @"bar",
							 @"statusCode" : @200
							 }
			 };
}

+(NSDictionary *)requestConfigDictionary
{
    return @{

            @"foo" : @{
                    @"keypath" : @"keypath",
                    @"method" : @"GET",
                    @"mapping" : @"foo",
                    @"object" : @"ESFoo"
            },
            @"bar" : @{
                    @"keypath" : @"keypath",
                    @"method" : @"POST",
                    @"mapping" : @"bar",
                    @"object" : @"ESBar"
            }
    };
}

+(NSString *)writeRoutesFile:(NSDictionary*)config
{	
	return [self writeFile:@"routes.plist" forDictionary:config];
}

+(NSString *)writeMappingFile:(NSDictionary *)config
{
	return [self writeFile:@"mapping.plist" forDictionary:config];
}

+(NSString *)writeResponseFile:(NSDictionary *)config
{
	return [self writeFile:@"response.plist" forDictionary:config];
}

+(NSString *)writeRequestFile:(NSDictionary*)config
{
    return [self writeFile:@"request.plist" forDictionary:config];
}

+(NSString*)writeFile:(NSString*)filename forDictionary:(NSDictionary*)config
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:filename];
	
	[config writeToFile:plistPath atomically: YES];
	
	return plistPath;
}


@end
