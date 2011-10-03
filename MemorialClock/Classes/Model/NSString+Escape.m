//
//  NSString+Escape.m
//  MemorialClock
//
//  Created by プー坊 on 11/10/03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+Escape.h"


@implementation NSString (NSString_Escape)

- (NSString *)escapeString
{
    return [((NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                 (CFStringRef)self,
                                                                 NULL,
                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                 kCFStringEncodingUTF8)) autorelease];
}

- (NSString *)unescapeString
{
    return [((NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                 (CFStringRef)self,
                                                                                 CFSTR(""),
                                                                                 kCFStringEncodingUTF8)) autorelease];
}

@end
