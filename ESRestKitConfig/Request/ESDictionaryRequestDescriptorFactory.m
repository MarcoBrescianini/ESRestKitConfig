//
// Created by Engineering Solutions on 09/12/2016.
// Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ESDictionaryRequestDescriptorFactory.h"

static NSString *const kMethodKey = @"method";
static NSString *const kMappingKey = @"mapping";
static NSString *const kObjectKey = @"object";
static NSString *const kKeypathKey = @"keypath";

@implementation ESDictionaryRequestDescriptorFactory

- (instancetype)initWithConfig:(NSDictionary *)config
{
    NSAssert(config.count > 0, @"A non empty config dictionary must be provided");

    self = [super init];

    if (self)
    {
        _config = config;
    }

    return self;
}

- (NSArray<RKRequestDescriptor *> *)createAllDescriptors:(NSDictionary<NSString *, RKMapping *> *)mappings
{
    NSMutableArray<RKRequestDescriptor *> *descriptors = [[NSMutableArray alloc]
            initWithCapacity:self.config.count];
    [self.config enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
        RKRequestDescriptor *descriptor = [self createDescriptorNamed:key forMappings:mappings];
        [descriptors addObject:descriptor];
    }];

    return descriptors;
}

- (RKRequestDescriptor *)createDescriptorNamed:(NSString *)name forMappings:(NSDictionary<NSString *, RKMapping *> *)mappings
{
    NSDictionary *descriptorConf = self.config[name];

    if (!descriptorConf || descriptorConf.count == 0)
        @throw [NSException exceptionWithName:@"ConfigurationException"
                                       reason:[NSString stringWithFormat:@"Configuration Not Found for Descriptor named: %@", name]
                                     userInfo:nil];

    RKRequestMethod method = [self readRequestMethod:descriptorConf];
    RKMapping *mapping = [self readInversedMapping:descriptorConf mappings:mappings];
    Class objectClass = [self readObjectClass:descriptorConf];
    NSString *keypath = descriptorConf[kKeypathKey];

    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:mapping
                                                                                   objectClass:objectClass
                                                                                   rootKeyPath:keypath
                                                                                        method:method];
    return requestDescriptor;
}

- (RKRequestMethod)readRequestMethod:(NSDictionary *)descriptorConf
{
    NSString *methodString = descriptorConf[kMethodKey];
    RKRequestMethod method;

    @try
    {
        if ([[methodString lowercaseString] isEqualToString:@"any"])
        {
            method = RKRequestMethodAny;
        } else
        {
            method = RKRequestMethodFromString(methodString);
        }
    } @catch (NSException *)
    {
        @throw [NSException exceptionWithName:@"PlistMalformedException"
                                       reason:[NSString stringWithFormat:@"Method not provided, or not supported %@", methodString]
                                     userInfo:nil];
    }
    return method;
}

- (RKMapping *)readInversedMapping:(NSDictionary *)conf mappings:(NSDictionary<NSString *, RKMapping *> *)mappings
{
    NSString *mappingName = conf[kMappingKey];
    RKMapping *mapping = mappings[mappingName];
    RKMapping *inversedMapping;

    if (mapping == nil)
        @throw [NSException exceptionWithName:@"PlistMalformedException"
                                       reason:[NSString stringWithFormat:@"Mapping Not Found %@", mappingName]
                                     userInfo:nil];

    if ([mapping isKindOfClass:[RKObjectMapping class]])
        inversedMapping = [(RKObjectMapping *) mapping inverseMapping];

    if (!inversedMapping)
        @throw [NSException exceptionWithName:@"PlistMalformedException"
                                       reason:[NSString stringWithFormat:@"Mapping with name %@, cannot be inversed", mappingName]
                                     userInfo:nil];

    return inversedMapping;
}

- (Class)readObjectClass:(NSDictionary *)conf
{
    NSString *className = conf[kObjectKey];
    Class objectClass = NSClassFromString(className);

    if (objectClass == NULL)
        @throw [NSException exceptionWithName:@"PlistMalformedException"
                                       reason:[NSString stringWithFormat:@"Class not found with name: %@", className]
                                     userInfo:nil];

    return objectClass;
}
@end
