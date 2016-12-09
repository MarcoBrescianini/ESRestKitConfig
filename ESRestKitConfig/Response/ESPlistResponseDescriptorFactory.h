//
//  ESPlistResponseDescriptorFactory.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 16/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESResponseDescriptorFactory.h"
#import "ESDictionaryResponseDescriptorFactory.h"


NS_ASSUME_NONNULL_BEGIN

@interface ESPlistResponseDescriptorFactory : ESDictionaryResponseDescriptorFactory

- (instancetype)initWithMappings:(ESMappingMap)mappings;
- (instancetype)initWithMappings:(ESMappingMap)mappings filename:(NSString *)filename;
- (instancetype)initWithMappings:(ESMappingMap)mappings filename:(NSString *)filename inBundle:(NSBundle * )bundle;
- (instancetype)initWithMappings:(ESMappingMap)mappings filepath:(NSString *)filepath;

@end

NS_ASSUME_NONNULL_END
