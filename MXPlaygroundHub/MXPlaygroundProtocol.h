//
// Created by max2oi on 2018/6/28.
// Copyright (c) 2018 max2oi. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 以下宏用于快速实现协议
#define MXHUBIMP(type, title, description)\
+ (NSString *)mxHub_Type {return (type);}\
+ (NSString *)mxHub_Title {return (title);}\
+ (NSString *)mxHub_Description {return (description);}

@protocol MXPlaygroundProtocol <NSObject>
+ (NSString *)mxHub_Title;
+ (NSString *)mxHub_Description;
+ (NSString *)mxHub_Type;
@end
