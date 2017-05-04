//
// Created by Engineering Solutions on 09/12/2016.
// Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ESDictionaryResponseDescriptorFactory.h"

static NSString * const kKeyPathKey = @"keypath";
static NSString * const kMethodKey = @"method";
static NSString * const kStatusCodeKey = @"statusCode";
static NSString * const kRouteKey = @"route";
static NSString * const kMappingKey = @"mapping";

@implementation ESDictionaryResponseDescriptorFactory

- (instancetype)initWithConfig:(NSDictionary *)config
{
    NSAssert(config.count > 0, @"Config dictionary cannot be empty");

    self = [super init];

    if (self)
    {
        _config = config;
    }

    return self;
}

- (NSArray<RKResponseDescriptor *> *)createAllDescriptors:(NSDictionary<NSString *, RKMapping *> *)mappings
{
    NSMutableArray<RKResponseDescriptor *> * descriptors = [[NSMutableArray alloc] initWithCapacity:self.config.count];

    [self.config enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {

        RKResponseDescriptor *descriptor = [self createDescriptorNamed:key forMappings:mappings];
        [descriptors addObject:descriptor];
    }];

    return descriptors;
}

- (RKResponseDescriptor *)createDescriptorNamed:(NSString *)name forMappings:(NSDictionary<NSString *, RKMapping *> *)mappings
{
    NSDictionary * descriptorConf = self.config[name];

    if(!descriptorConf || descriptorConf.count == 0)
        @throw [NSException exceptionWithName:@"ConfigurationException"
                                       reason:[NSString stringWithFormat:@"Configuration Not Found for Descriptor named: %@", name]
                                     userInfo:nil];

    RKRequestMethod method = [self readRequestMethod:descriptorConf];
    NSIndexSet * statusCodeIndexSet = [self readAcceptedStatusCodes:descriptorConf];
    NSString * pathPattern = [self readRoute:descriptorConf];
    RKMapping *mapping = [self readMappingDescription:descriptorConf given:mappings];
    NSString * keypath = descriptorConf[kKeyPathKey];

    RKResponseDescriptor * descriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:method pathPattern:pathPattern keyPath:keypath statusCodes:statusCodeIndexSet];

    return descriptor;
}

- (RKRequestMethod)readRequestMethod:(NSDictionary *)descriptorConf
{
    RKRequestMethod method;
    @try
    {
        NSString * methodString = descriptorConf[kMethodKey];

        if ([[methodString lowercaseString] isEqualToString:@"any"])
        {
            method = RKRequestMethodAny;
        } else
        {
            method = RKRequestMethodFromString(methodString);
        }
    } @catch (NSException *)
    {
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:@"Method not provided, or not supported" userInfo:nil];
    }
    return method;
}

- (NSIndexSet *)readAcceptedStatusCodes:(NSDictionary *)descriptorConf
{
    NSNumber * statusCode = descriptorConf[kStatusCodeKey];

    if ([statusCode integerValue] < 100 || [statusCode integerValue] >= 600)
        @throw [NSException exceptionWithName:@"PlistMalformedException" reason:@"Not supported status code range" userInfo:nil];

    return RKStatusCodeIndexSetForClass((RKStatusCodeClass) [statusCode integerValue]);
}

- (NSString *)readRoute:(NSDictionary *)descriptorConf
{
    NSString * pathPattern = descriptorConf[kRouteKey];

    return pathPattern;
}

- (RKMapping *)readMappingDescription:(NSDictionary *)descriptorConf given:(NSDictionary<NSString *, RKMapping *> *)mappings
{
    NSString * mappingName = descriptorConf[kMappingKey];
    RKMapping *mapping = mappings[mappingName];

    if (!mapping)
        @throw [NSException exceptionWithName:@"PlistMalformedException"
                                       reason:[NSString stringWithFormat:@"Mapping Not Found %@", mappingName]
                                     userInfo:nil];

    return mapping;
}
@end
