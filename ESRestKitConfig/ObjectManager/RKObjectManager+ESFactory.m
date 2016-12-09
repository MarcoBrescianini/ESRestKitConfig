//
// Created by Engineering Solutions on 09/12/2016.
// Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import "RKObjectManager+ESFactory.h"
#import "ESPlistObjectManagerFactory.h"


@implementation RKObjectManager (ESFactory)

+ (instancetype)managerWithConfig:(NSDictionary *)config
{
    ESPlistObjectManagerFactory * factory = [[ESPlistObjectManagerFactory alloc] initWithConfig:config];
    return [factory createObjectManager];
}

+ (instancetype)managerWithConfigFromFile:(NSString *)filename
{
    ESPlistObjectManagerFactory * factory = [[ESPlistObjectManagerFactory alloc] initWithFilename:filename];
    return [factory createObjectManager];
}

@end
