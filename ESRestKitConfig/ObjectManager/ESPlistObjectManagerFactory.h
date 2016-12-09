//
// Created by Engineering Solutions on 09/12/2016.
// Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESObjectManagerFactory.h"
#import "ESDictionaryObjectManagerFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESPlistObjectManagerFactory : ESDictionaryObjectManagerFactory


- (instancetype)initWithFilename:(NSString*)filename;
- (instancetype)initWithFilename:(NSString*)filename inBundle:(NSBundle * )bundle;
- (instancetype)initWithFilepath:(NSString*)filepath;

@end

NS_ASSUME_NONNULL_END
