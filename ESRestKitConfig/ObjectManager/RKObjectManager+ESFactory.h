//
// Created by Engineering Solutions on 09/12/2016.
// Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RKObjectManager.h>

@interface RKObjectManager (ESFactory)

+(instancetype)managerWithConfig:(NSDictionary * )config;
+(instancetype)managerWithConfigFromFile:(NSString*)filename;

@end
