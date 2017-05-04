//
//  ESPlistMappingFactory.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 15/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESMappingFactory.h"
#import "ESDictionaryMappingFactory.h"

@class RKManagedObjectStore;

NS_ASSUME_NONNULL_BEGIN

@interface ESPlistMappingFactory : ESDictionaryMappingFactory

- (instancetype)init;
- (instancetype)initWithFilename:(NSString *)filename;
- (instancetype)initWithFilename:(NSString *)filename inBundle:(NSBundle *)bundle;
- (instancetype)initWithFilepath:(NSString *)filepath;

@end

NS_ASSUME_NONNULL_END
