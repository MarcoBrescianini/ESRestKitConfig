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

- (instancetype)initWithStore:(nullable RKManagedObjectStore * )store;
- (instancetype)initWithFilename:(NSString *)filename;
- (instancetype)initWithFilename:(NSString *)filename store:(nullable RKManagedObjectStore *)store;
- (instancetype)initWithFilename:(NSString *)filename inBundle:(NSBundle *)bundle;
- (instancetype)initWithFilename:(NSString *)filename inBundle:(NSBundle *)bundle store:(nullable RKManagedObjectStore *)store;
- (instancetype)initWithFilepath:(NSString *)filepath;
- (instancetype)initWithFilepath:(NSString *)filepath store:(nullable RKManagedObjectStore *)store;

@end

NS_ASSUME_NONNULL_END
