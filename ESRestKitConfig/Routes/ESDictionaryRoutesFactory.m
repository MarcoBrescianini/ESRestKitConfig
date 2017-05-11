//
// Created by Engineering Solutions on 09/12/2016.
// Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "ESDictionaryRoutesFactory.h"

static NSString * const kPathKey = @"path";
static NSString * const kMethodKey = @"method";
static NSString * const kTypeKey = @"type";
static NSString * const kObjectClassKey = @"objectClass";
static NSString *const kEscapePath = @"escapePath";

static NSString * const kRouteTypeObject = @"object";
static NSString * const kRouteTypeRelationship = @"relationship";

@implementation ESDictionaryRoutesFactory

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    NSAssert(dictionary.count > 0, @"Must provide a non empty dictionary");

    self = [super init];

    if (self)
    {
        _config = dictionary;
    }

    return self;
}

- (RKRoute *)createRouteNamed:(NSString *)routeName
{
    NSDictionary * routeInfo = self.config[routeName];

    NSString * pattern = routeInfo[kPathKey];
    RKRequestMethod method = RKRequestMethodFromString(routeInfo[kMethodKey]);
    NSString * routeType = routeInfo[kTypeKey];
    Class objClass = NSClassFromString(routeInfo[kObjectClassKey]);
    BOOL escapePath = NO;

    if (routeInfo[kEscapePath] && [routeInfo[kEscapePath] isKindOfClass:[NSNumber class]])
    {
        escapePath = [routeInfo[kEscapePath] boolValue];
    }

    RKRoute *route;
    if ([routeType isEqualToString:kRouteTypeObject])
    {
        [self assertObjectClassExists:objClass forRoute:routeName];

        route = [RKRoute routeWithClass:objClass pathPattern:pattern method:method];
    } else if ([routeType isEqualToString:kRouteTypeRelationship])
    {
        [self assertObjectClassExists:objClass forRoute:routeName];

        route = [RKRoute routeWithRelationshipName:routeName objectClass:objClass pathPattern:pattern method:method];
    } else
    {
        route = [RKRoute routeWithName:routeName pathPattern:pattern method:method];
    }

    route.shouldEscapePath = escapePath;

    return route;
}

- (void)assertObjectClassExists:(Class)aClass forRoute:(NSString *)routeName
{
    if (aClass == NULL)
    {
        @throw [NSException exceptionWithName:@"PlistMalformedException"
                                       reason:[NSString stringWithFormat:@"Object class not found for route named: %@", routeName]
                                     userInfo:nil];
    }
}

- (NSDictionary<NSString *, RKRoute *> *)createRoutes
{
    NSMutableDictionary <NSString *, RKRoute *> * routes = [[NSMutableDictionary alloc] initWithCapacity:self.config.count];

    NSArray * keys = [self.config allKeys];

    for (NSString * routeName in keys)
    {
        RKRoute * route = [self createRouteNamed:routeName];
        [routes setValue:route forKey:routeName];
    }

    return routes;
}

- (NSArray<RKRoute *> *)createAllRoutes
{
    return [[self createRoutes] allValues];
}
@end
