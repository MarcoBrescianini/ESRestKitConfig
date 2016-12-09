//
//  ESPlistRoutesFactoryTest.m
//  Engineering Solutions
//
//  Created by Marco Brescianini on 15/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RestKit/RestKit.h>


#import "ESPlistRoutesFactory.h"
#import "ESConfigFixtures.h"
#import "ESDictionaryRoutesFactory.h"

@interface ESPlistRoutesFactoryTest : XCTestCase
{
    ESPlistRoutesFactory *factory;
}

@end

@implementation ESPlistRoutesFactoryTest

//-------------------------------------------------------------------------------------------
#pragma mark - Initialization Tests

#warning Skipped Test
- (void)_testInitWithFileNameFromMainBundle
{
    factory = [[ESPlistRoutesFactory alloc] initWithFilename:@"Routes"];

    XCTAssertNotNil(factory);
    XCTAssertNotNil(factory.config);
}

- (void)testInitWithFilename_fileNotFound_Throws
{
    XCTAssertThrows([[ESPlistRoutesFactory alloc] initWithFilename:@"Not Existing"]);
}


- (void)testInitWithFilepath
{
    NSString *filepath = nil;

    @try
    {
        NSDictionary *routesConfig = [ESConfigFixtures routesConfigDictionary];
        filepath = [ESConfigFixtures writeRoutesFile:routesConfig];

        NSAssert(filepath, @"Couldn't create file");

        factory = [[ESPlistRoutesFactory alloc] initWithFilepath:filepath];

        XCTAssertNotNil(factory);
        XCTAssertNotNil(factory.config);

    }
    @finally
    {
        NSFileManager *manager = [[NSFileManager alloc] init];

        if (filepath)
        {
            if ([manager fileExistsAtPath:filepath])
            {
                [manager removeItemAtPath:filepath error:nil];
            }
        }
    }


}

- (void)testInitWithDictionary
{
    factory = [[ESPlistRoutesFactory alloc] initWithDictionary:@{
            @"get_something"  : @{
                    @"path"   : @"something/",
                    @"method" : @"GET"

            },
            @"post_something" : @{
                    @"path"   : @"something/",
                    @"method" : @"POST"
            }
    }];

    XCTAssertNotNil(factory);
    XCTAssertNotNil(factory.config);
}

- (void)testInitWithEmptyDictionaryThrows
{
    XCTAssertThrows([[ESPlistRoutesFactory alloc] initWithDictionary:@{}]);
}

- (void)testInitWithNilDictionaryThrows
{
    XCTAssertThrows([[ESPlistRoutesFactory alloc] initWithDictionary:nil]);
}

//-------------------------------------------------------------------------------------------
#pragma mark - Business Logic tests

- (void)testRouteForName
{
    NSString *method = @"GET";
    NSString *pattern = @"path/";
    NSString *name = @"route_name";

    NSDictionary *dictionary = @{
            name : @{
                    @"path"   : pattern,
                    @"method" : method
            }
    };
    factory = [[ESPlistRoutesFactory alloc] initWithDictionary:dictionary];

    RKRoute *actual = [factory createRouteNamed:name];

    [self assertRoute:actual hasName:name pattern:pattern forMethod:method];
}

- (void)testMissingMethod
{
    NSString *pattern = @"path/";
    NSString *name = @"route_name";

    NSDictionary *dictionary = @{
            name : @{
                    @"path" : pattern
            }
    };

    factory = [[ESPlistRoutesFactory alloc] initWithDictionary:dictionary];

    XCTAssertThrows([factory createRouteNamed:@"route_name"]);
}

- (void)testCreateRoutes
{
    NSDictionary *dictionary = @{
            @"get_something"  : @{
                    @"path"   : @"something/",
                    @"method" : @"GET"

            },
            @"post_something" : @{
                    @"path"   : @"something/",
                    @"method" : @"POST"
            }
    };
    factory = [[ESPlistRoutesFactory alloc] initWithDictionary:dictionary];

    NSDictionary<NSString *, RKRoute *> *routes = [factory createRoutes];

    XCTAssertEqual([dictionary count], routes.count);

    [routes enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, RKRoute *_Nonnull obj, BOOL *_Nonnull stop) {

        NSDictionary *routeConf = dictionary[key];

        [self assertRoute:obj hasName:key pattern:routeConf[@"path"] forMethod:routeConf[@"method"]];
    }];
}

- (void)testCreateAllRoutes
{
    NSDictionary *dictionary = @{
            @"get_something"  : @{
                    @"path"   : @"something/",
                    @"method" : @"GET"

            },
            @"post_something" : @{
                    @"path"   : @"something/",
                    @"method" : @"POST"
            }
    };
    factory = [[ESPlistRoutesFactory alloc] initWithDictionary:dictionary];

    NSArray * routes = [factory createAllRoutes];

    XCTAssertEqual(routes.count, 2);

    RKRoute * first = routes[0];
    [self assertRoute:first hasName:@"get_something" pattern:@"something/" forMethod:@"GET"];
    RKRoute * second = routes[1];
    [self assertRoute:second hasName:@"post_something" pattern:@"something/" forMethod:@"POST"];
}


-(void)testCreateRelationshipRoute
{
    NSString *method = @"GET";
    NSString *pattern = @"path/";
    NSString *name = @"route_name";

    NSDictionary *dictionary = @{
            name : @{
                    @"path"   : pattern,
                    @"method" : method,
                    @"type"   : @"relationship",
                    @"objectClass" : @"NSString"
            }
    };
    factory = [[ESPlistRoutesFactory alloc] initWithDictionary:dictionary];

    RKRoute *actual = [factory createRouteNamed:name];
    [self assertRoute:actual hasName:name pattern:pattern forMethod:method];
    XCTAssertEqualObjects(actual.objectClass, [NSString class]);
}


-(void)testRelationshipRoute_missingObjectClass
{
    NSString *method = @"GET";
    NSString *pattern = @"path/";
    NSString *name = @"route_name";

    NSDictionary *dictionary = @{
            name : @{
                    @"path"   : pattern,
                    @"method" : method,
                    @"type"   : @"relationship"
            }
    };
    factory = [[ESPlistRoutesFactory alloc] initWithDictionary:dictionary];

    XCTAssertThrowsSpecificNamed([factory createRouteNamed:name],NSException ,@"PlistMalformedException");
}


-(void)testObjectRoute
{
    NSString *method = @"GET";
    NSString *pattern = @"path/";
    NSString *name = @"route_name";

    NSDictionary *dictionary = @{
            name : @{
                    @"path"   : pattern,
                    @"method" : method,
                    @"type"   : @"object",
                    @"objectClass" : @"NSString"
            }
    };
    factory = [[ESPlistRoutesFactory alloc] initWithDictionary:dictionary];

    RKRoute *actual = [factory createRouteNamed:name];
    [self assertRoute:actual hasName:nil pattern:pattern forMethod:method];
    XCTAssertEqualObjects(actual.objectClass, [NSString class]);
}


-(void)testObjectRoute_missingClass_Throws
{
    NSString *method = @"GET";
    NSString *pattern = @"path/";
    NSString *name = @"route_name";

    NSDictionary *dictionary = @{
            name : @{
                    @"path"   : pattern,
                    @"method" : method,
                    @"type"   : @"object",
                    @"objectClass" : @"TYNotExisting"
            }
    };
    factory = [[ESPlistRoutesFactory alloc] initWithDictionary:dictionary];

    XCTAssertThrowsSpecificNamed([factory createRouteNamed:name],NSException ,@"PlistMalformedException");
}

//-------------------------------------------------------------------------------------------
#pragma mark - Asserts

- (void)assertRoute:(RKRoute *)route hasName:(NSString *)name pattern:(NSString *)pattern forMethod:(NSString *)method
{
    if(name == nil)
    {
        XCTAssertNil(route.name);
    } else
    {
        XCTAssertEqualObjects(name, route.name);
    }

    XCTAssertEqualObjects(pattern, route.pathPattern);
    XCTAssertEqual(RKRequestMethodFromString(method), route.method);
}

@end
