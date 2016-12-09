//
// Created by Marco Brescianini on 16/11/15.
// Copyright (c) 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESRequestDescriptorFactory.h"
#import "ESDictionaryRequestDescriptorFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESPlistRequestDescriptorFactory : ESDictionaryRequestDescriptorFactory

- (instancetype)initWithMappings:(ESMappingMap)mappings;
- (instancetype)initWithMappings:(ESMappingMap)mappings filename:(NSString *)filename;
- (instancetype)initWithMappings:(ESMappingMap)mappings filename:(NSString *)filename inBundle:(NSBundle * )bundle;
- (instancetype)initWithMappings:(ESMappingMap)mappings filepath:(NSString *)filepath;

@end

NS_ASSUME_NONNULL_END
