//
// Created by Marco Brescianini on 16/11/15.
// Copyright (c) 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESRequestDescriptorFactory.h"
#import "ESDictionaryRequestDescriptorFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESPlistRequestDescriptorFactory : ESDictionaryRequestDescriptorFactory

- (instancetype)init;
- (instancetype)initWithFilename:(NSString *)filename;
- (instancetype)initWithFilename:(NSString *)filename inBundle:(NSBundle *)bundle;
- (instancetype)initWithFilepath:(NSString *)filepath;

@end

NS_ASSUME_NONNULL_END
