//
//  NSObject+PSExtensions.m
//  PSExtensions
//
//  Created by Gregory Kip on 9/25/11.
//  Copyright (C) 2011-2012 Permusoft Corporation. All rights reserved.
//

/*
 * Copyright (C) 2012 Permusoft Corporation. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted
 * provided that the following conditions are met:
 *
 * 1) Redistributions of source code must retain the above copyright notice, this list of conditions and
 * the following disclaimer.
 *
 * 2) Redistributions in binary form must reproduce the above copyright notice, this list of conditions
 * and the following disclaimer in the documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 * WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSObject+PSExtensions.h"
#import <objc/runtime.h>

@implementation NSObject (PSExtensions)

+(NSArray *)properties {
   unsigned int propertyCount = 0;
   objc_property_t * properties = class_copyPropertyList([self class], &propertyCount);
   
   NSMutableArray * propertyNames = [NSMutableArray array];
   for (unsigned int i = 0; i < propertyCount; ++i) {
      objc_property_t property = properties[i];
      const char * name = property_getName(property);
      [propertyNames addObject:[NSString stringWithUTF8String:name]];
   }
   free(properties);
   
   return [NSArray arrayWithArray:propertyNames];
}


-(NSDictionary *)keyValueDictionary {
   unsigned int propertyCount = 0;
   objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
   
   NSMutableDictionary *keyValueDictionary = [NSMutableDictionary dictionaryWithCapacity:propertyCount];
   
   for (unsigned int i = 0; i < propertyCount; ++i) {
      objc_property_t property = properties[i];
      const char *propertyName = property_getName(property);
      NSString *key = [NSString stringWithUTF8String:propertyName];
      [keyValueDictionary setValue:[self valueForKey:key] forKey:key];
   }
   
   free(properties);
   
   return [NSDictionary dictionaryWithDictionary:keyValueDictionary];
}

@end