//
// Created by Engineering Solutions on 09/12/2016.
// Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESDictionaryObjectManagerFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESPlistObjectManagerFactory : ESDictionaryObjectManagerFactory

- (instancetype)initWithFilename:(NSString*)filename;
- (instancetype)initWithFilename:(NSString*)filename inBundle:(NSBundle * )bundle;
- (instancetype)initWithFilepath:(NSString*)filepath;
- (instancetype)initWithFilepath:(NSString *)filepath baseURL:(nullable NSString *)baseURL;
- (instancetype)initWithFilepath:(NSString *)filepath
                         baseURL:(nullable NSString *)baseURL
                    routeFactory:(nullable id <ESRoutesFactory>)routesFactory
                  mappingFactory:(nullable id <ESMappingFactory>)mappingFactory
       responseDescriptorFactory:(nullable id <ESResponseDescriptorFactory>)responseDescriptorFactory
        requestDescriptorFactory:(nullable id <ESRequestDescriptorFactory>)requestDescriptorFactory NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
