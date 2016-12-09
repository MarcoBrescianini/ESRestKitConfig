//
// Created by Engineering Solutions on 09/12/2016.
// Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESRoutesFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESDictionaryRoutesFactory : NSObject <ESRoutesFactory>

@property (nonatomic, strong, readonly) NSDictionary * config;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@end


NS_ASSUME_NONNULL_END
