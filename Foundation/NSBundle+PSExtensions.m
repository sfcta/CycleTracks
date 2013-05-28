//
//  NSBundle+PSExtensions.m
//  PSExtensions
//
//  Created by Gregory Kip on 2/6/12.
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


// Cocoa
NSString * const kNSHumanReadableCopyright = @"NSHumanReadableCopyright";

// CoreFoundation
NSString * const kCFBundleVersion            = @"CFBundleVersion";
NSString * const kCFBundleShortVersioNString = @"CFBundleShortVersionString";
NSString * const kCFBundleDisplayName        = @"CFBundleDisplayName";
NSString * const kCFBundleIdentifier         = @"CFBundleIdentifier";

// UIKit
NSString * const kUIMainStoryboardFile       = @"UIMainStoryboardFile";
NSString * const kUIMainStoryboardFileiPhone = @"UIMainStoryboardFile~iphone";
NSString * const kUIMainStoryboardFileiPad   = @"UIMainStoryboardFile~ipad";


#import "NSBundle+PSExtensions.h"

@implementation NSBundle (PSExtensions)

+(NSString *)displayName {
   return [[[NSBundle mainBundle] infoDictionary] objectForKey:kCFBundleDisplayName];
}

+(NSString *)bundleIdentifier {
   return [[[NSBundle mainBundle] infoDictionary] objectForKey:kCFBundleIdentifier];
}

+(NSString *)copyright {
   return [[[NSBundle mainBundle] infoDictionary] objectForKey:kNSHumanReadableCopyright];
}

+(NSString *)version {
   return [[[NSBundle mainBundle] infoDictionary] objectForKey:kCFBundleShortVersioNString];
}

+(NSString *)build {
   return [[[NSBundle mainBundle] infoDictionary] objectForKey:kCFBundleVersion];
}

+(NSString *)storyboardName {
   return [[[NSBundle mainBundle] infoDictionary] objectForKey:kUIMainStoryboardFile];
}

+(NSString *)storyboardName_iPhone {
   return [[[NSBundle mainBundle] infoDictionary] objectForKey:kUIMainStoryboardFileiPhone];
}

+(NSString *)storyboardName_iPad {
   return [[[NSBundle mainBundle] infoDictionary] objectForKey:kUIMainStoryboardFileiPad];
}

@end
