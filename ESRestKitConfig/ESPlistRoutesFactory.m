//
//  ESPlistRoutesFactory.m
//  Engineering Solutions
//
//  Created by Marco Brescianini on 15/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ESPlistRoutesFactory.h"
#import "RKRoute+ESAuthRequirement.h"

@implementation ESPlistRoutesFactory


- (instancetype)init {
    return [self initWithPlistFilePath:@"Routes"];
}

- (instancetype)initFromMainBundle:(NSString *)filename {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];

    if (!path)
        @throw [NSException exceptionWithName:@"PlistNotFoundException" reason:@"Plist file not found" userInfo:nil];

    return [self initWithPlistFilePath:path];
}

- (instancetype)initWithPlistFilePath:(NSString *)filepath {
    return [self initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:filepath]];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    NSAssert(dictionary, @"A dictionary Must be provided");
    NSAssert(dictionary.count > 0, @"Must provide a non emtpy dictionary");

    self = [super init];

    if (self) {
        _config = dictionary;
    }

    return self;
}

- (RKRoute *)createRouteNamed:(NSString *)routeName {
    NSDictionary *routeInfo = self.config[routeName];

    NSString *pattern = routeInfo[@"path"];
    RKRequestMethod method = RKRequestMethodFromString(routeInfo[@"method"]);
    NSString *routeType = routeInfo[@"type"];
    Class objClass = NSClassFromString(routeInfo[@"objectClass"]);
    BOOL authRequired = [routeInfo[@"authRequired"] boolValue];
    NSString *authScope = routeInfo[@"authScope"];

    if ([routeType isEqualToString:@"object"]) {
        [self assertObjectClassExists:objClass forRoute:routeName];

        return [RKRoute routeWithClass:objClass
                           pathPattern:pattern
                                method:method
                          authRequired:authRequired
                             authScope:authScope];
    }

    if ([routeType isEqualToString:@"relationship"]) {
        [self assertObjectClassExists:objClass forRoute:routeName];

        return [RKRoute routeWithRelationshipName:routeName
                                      objectClass:objClass
                                      pathPattern:pattern
                                           method:method
                                     authRequired:authRequired
                                        authScope:authScope];
    }

    return [RKRoute routeWithName:routeName pathPattern:pattern method:method authRequired:authRequired authScope:authScope];
}

- (void)assertObjectClassExists:(Class)aClass forRoute:(NSString *)routeName {
    if (aClass == NULL) {
        @throw [NSException exceptionWithName:@"PlistMalformedException"
                                       reason:[NSString stringWithFormat:@"Object class not found for route named: %@", routeName]
                                     userInfo:nil];
    }
}

- (NSDictionary<NSString *, RKRoute *> *)createRoutes {
    NSMutableDictionary <NSString *, RKRoute *> *routes = [[NSMutableDictionary alloc] initWithCapacity:self.config.count];

    NSArray *keys = [self.config allKeys];

    for (NSString *routeName in keys) {
        RKRoute *route = [self createRouteNamed:routeName];
        [routes setValue:route forKey:routeName];
    }

    return routes;
}

@end
