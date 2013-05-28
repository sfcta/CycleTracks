//
//  NSString+PSExtensions.h
//  PSExtensions
//
//  Created by Gregory Kip on 12/10/10.
//  Copyright (C) 2010 Permusoft Corporation. All rights reserved.
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

// Users must import Security.framework

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>


@interface NSString (PSExtensions)


// Misc
+(NSString *)emDash;

+(NSString *)stringWithRandomUnsignedLong;
+(NSString *)stringWithNewUUID;
+(NSString *)stringForReachabilityFlags:(SCNetworkReachabilityFlags)flags comment:(NSString *)comment;
+(NSString *)stringForRange:(NSRange)range;

// CoreGeometry Stuff
+(NSString *)stringForCGPoint:(CGPoint)point;
+(NSString *)stringForCGSize:(CGSize)size;
+(NSString *)stringForCGRect:(CGRect)rect;

// NSIndexPath
+(NSString *)stringForIndexPath:(NSIndexPath *)indexPath;

// NSRange
+(NSString *)stringForNSRange:(NSRange)range;

// Hashes
-(NSString *)MD5UsingEncoding:(NSStringEncoding)encoding;
-(NSData *)SHA1HashUsingEncoding:(NSStringEncoding)encoding;
-(NSString *)SHA256HashUsingEncoding:(NSStringEncoding)encoding;


@end
