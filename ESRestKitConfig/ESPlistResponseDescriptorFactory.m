//
//  ESPlistResponseDescriptorFactory.m
//  Engineering Solutions
//
//  Created by Marco Brescianini on 16/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ESPlistResponseDescriptorFactory.h"

@implementation ESPlistResponseDescriptorFactory

//-------------------------------------------------------------------------------------------
#pragma mark - Inits

-(instancetype)init
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot call init, must call initWithRoutes" userInfo:nil];
}

-(instancetype)initWithRoutes:(ESRouteMap)routes mappings:(ESMappingMap)mappings fromMainBundle:(NSString *)filename
{
	NSString * path = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];
	
	if(!path)
		@throw [NSException exceptionWithName:@"PlistNotFoundException" reason:@"Plist file not found" userInfo:nil];
	
	return [self initWithRoutes:routes mappings:mappings filepath:path];
}

-(instancetype)initWithRoutes:(ESRouteMap)routes mappings:(ESMappingMap)mappings filepath:(NSString *)filepath
{
	return [self initWithRoutes:routes mappings:mappings config:[NSDictionary dictionaryWithContentsOfFile:filepath]];
}

-(instancetype)initWithRoutes:(ESRouteMap)routes mappings:(ESMappingMap)mappings config:(NSDictionary *)config
{
	NSAssert(routes, @"Route dictionary must be provided");
	NSAssert(routes.count > 0, @"At least one route must be provided");
	NSAssert(mappings, @"Mapping dictionary must be provided");
	NSAssert(mappings.count > 0, @"At least one mapping must be provided");
	NSAssert(config, @"Config dictionary must be provided");
	NSAssert(config.count > 0, @"Config dictionary cannot be empty");
	
	self = [super init];
	
	if(self)
	{
		_routes = routes;
		_mappings = mappings;
		_config = config;
	}
	
	return self;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Business Logic

-(NSArray<RKResponseDescriptor *> *)createResponseDescriptors
{
    NSMutableArray<RKResponseDescriptor*> * descriptors = [[NSMutableArray alloc] initWithCapacity:self.config.count];

    [self.config enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {

        RKResponseDescriptor * descriptor = [self createDescriptorNamed:key];
        [descriptors addObject:descriptor];
    }];

    return descriptors;
}

-(RKResponseDescriptor *)createDescriptorNamed:(NSString *)name
{
	NSDictionary * descriptorConf = self.config[name];

    RKRequestMethod method = [self readRequestMethod:descriptorConf];
    NSIndexSet * statusCodeIndexSet = [self readAcceptedStatusCodes:descriptorConf];
    RKRoute * route = [self readRoute:descriptorConf];
    RKMapping * mapping = [self readMapping:descriptorConf];
    NSString * keypath = descriptorConf[@"keypath"];

	RKResponseDescriptor * descriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:method pathPattern:route.pathPattern keyPath:keypath statusCodes:statusCodeIndexSet];

	return descriptor;
}


- (RKRequestMethod)readRequestMethod:(NSDictionary *)descriptorConf
{
    RKRequestMethod method;
    @try
	{
		NSString * methodString = descriptorConf[@"method"];
		method = RKRequestMethodFromString(methodString);
	}@catch(NSException *)
	{
		@throw [NSException exceptionWithName:@"PlistMalformedException" reason:@"Method not provided, or not supported" userInfo:nil];
	}
    return method;
}

-(NSIndexSet *)readAcceptedStatusCodes:(NSDictionary *)descriptorConf
{
    NSNumber * statusCode = descriptorConf[@"statusCode"];

    if([statusCode integerValue] < 100 || [statusCode integerValue] >= 600)
    {
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:@"Not supported status code range" userInfo:nil];
    }

    return RKStatusCodeIndexSetForClass((RKStatusCodeClass) [statusCode integerValue]);
}

-(RKRoute *)readRoute:(NSDictionary *)descriptorConf
{
    NSString * routeName = descriptorConf[@"route"];
    RKRoute * route = self.routes[routeName];

    if(!route)
    {
        @throw [NSException exceptionWithName:@"PlistMalformedException"
                                       reason:[NSString stringWithFormat:@"Route not found %@", routeName]
                                     userInfo:nil];
    }

    return route;
}

-(RKMapping*)readMapping:(NSDictionary *)descriptorConf
{
    NSString * mappingName = descriptorConf[@"mapping"];
    RKMapping * mapping = self.mappings[mappingName];

    if(!mapping)
    {
        @throw [NSException exceptionWithName:@"PlistMalformedException"
                                       reason:[NSString stringWithFormat:@"Mapping Not Found %@", mappingName]
                                     userInfo:nil];
    }

    return mapping;
}

@end
