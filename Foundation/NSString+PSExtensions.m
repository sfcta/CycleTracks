//
//  NSString+PSExtensions.m
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

#import "NSString+PSExtensions.h"
#import <uuid/uuid.h>



@implementation NSString (PSExtensions)


#pragma mark -
#pragma mark Class Methods


+(NSString *)emDash {
   return @"\u2014";
}


+(NSString *)stringWithRandomUnsignedLong {
   //NSLog(@"NSString+PSExtensions.stringForRandomUnsignedLong");
   
   // Get a randomized C String
   unsigned long ghostID_ul;
   int notOK; // error value returned from SecRandomCopyBytes... weird semantics, weird name
   notOK = SecRandomCopyBytes (kSecRandomDefault, sizeof(unsigned long), (uint8_t *) &ghostID_ul);
   if (notOK) {
      // TODO: Exception
      NSLog (@"Crypto error!");
      return nil;
   } else {
      return [NSString stringWithFormat:@"%lu", ghostID_ul];
   }
}


+(NSString *)stringWithNewUUID {
   uuid_t uuid;
   uuid_string_t uuid_s;
   
   uuid_generate(uuid);
   uuid_unparse(uuid, uuid_s);
   
   return [NSString stringWithCString:uuid_s encoding:NSUTF8StringEncoding];
}


+(NSString *)stringForReachabilityFlags:(SCNetworkReachabilityFlags)flags comment:(NSString *)comment {
   if (comment == nil) comment = @"";
   
   return [NSString stringWithFormat:@"%c%c %c%c%c%c%c%c%c %@\n",
            (flags & kSCNetworkReachabilityFlagsIsWWAN)                 ? 'W' : '-',
            (flags & kSCNetworkReachabilityFlagsReachable)              ? 'R' : '-',
            (flags & kSCNetworkReachabilityFlagsTransientConnection)    ? 't' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionRequired)     ? 'c' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)    ? 'C' : '-',
            (flags & kSCNetworkReachabilityFlagsInterventionRequired)   ? 'i' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)     ? 'D' : '-',
            (flags & kSCNetworkReachabilityFlagsIsLocalAddress)         ? 'l' : '-',
            (flags & kSCNetworkReachabilityFlagsIsDirect)               ? 'd' : '-',
            comment];
}


+(NSString *)stringForRange:(NSRange)range {
   return [NSString stringWithFormat:@"(%u, %u)", range.location, range.length];
}



#pragma mark - NSIndexPath
+(NSString *)stringForIndexPath:(NSIndexPath *)indexPath {
   return [NSString stringWithFormat:@"{%u, %u}", [indexPath section], [indexPath row]];
}



#pragma mark - CoreGeometry Stuff


#define CGPOINT_FORMAT (@"{%.2f, %.2f}")
+(NSString *)stringForCGPoint:(CGPoint)point {
   return [NSString stringWithFormat:CGPOINT_FORMAT, point.x, point.y];
}


#define CGSIZE_FORMAT (@"{%.2f, %.2f}")
+(NSString *)stringForCGSize:(CGSize)size {
   return [NSString stringWithFormat:CGSIZE_FORMAT, size.width, size.height];
}


#define CGRECT_FORMAT (@"{{%.2f, %.2f}, {%.2f, %.2f}}")
+(NSString *)stringForCGRect:(CGRect)rect {
   return [NSString stringWithFormat:CGRECT_FORMAT, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}


#define NSRANGE_FORMAT (@"{%lu, %lu}")
+(NSString *)stringForNSRange:(NSRange)range {
   return [NSString stringWithFormat:NSRANGE_FORMAT, (unsigned long)range.location, (unsigned long)range.length];
}




#pragma mark - Hashes

-(NSString *)MD5UsingEncoding:(NSStringEncoding)encoding {
   static NSString *md5Format = @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X";
   NSData *plainText;
   CC_MD5_CTX ctx;
   uint8_t *hashBytes = NULL;
   NSString *md5;
   
   plainText = [self dataUsingEncoding:encoding];
   
   // Malloc a buffer.
	hashBytes = malloc(CC_MD5_DIGEST_LENGTH * sizeof(uint8_t));
	memset((void *)hashBytes, 0x0, CC_MD5_DIGEST_LENGTH);
   
   // Perform the hash
   CC_MD5_Init(&ctx);
   CC_MD5_Update(&ctx, (void *)[plainText bytes], [plainText length]);
   CC_MD5_Final(hashBytes, &ctx);
   
   // Fetch the hash into an NSString.
   md5 = [NSString stringWithFormat:md5Format,
          hashBytes[0], hashBytes[1], hashBytes[2], hashBytes[3],
          hashBytes[4], hashBytes[5], hashBytes[6], hashBytes[7],
          hashBytes[8], hashBytes[9], hashBytes[10], hashBytes[11],
          hashBytes[12], hashBytes[13], hashBytes[14], hashBytes[15]];
   
   if (hashBytes) free (hashBytes);

   return md5;
}


-(NSData *)SHA1HashUsingEncoding:(NSStringEncoding)encoding {
   NSData *plainText;
   CC_SHA1_CTX ctx;
	uint8_t *hashBytes = NULL;
	NSData *hash = nil;
	
   plainText = [self dataUsingEncoding:encoding];
   
	// Malloc a buffer.
	hashBytes = malloc(CC_SHA1_DIGEST_LENGTH * sizeof(uint8_t));
	memset((void *)hashBytes, 0x0, CC_SHA1_DIGEST_LENGTH);
	
   // Perform the hash
	CC_SHA1_Init(&ctx);
	CC_SHA1_Update(&ctx, (void *)[plainText bytes], [plainText length]);
	CC_SHA1_Final(hashBytes, &ctx);
	
	hash = [NSData dataWithBytes:(const void *)hashBytes length:(NSUInteger)CC_SHA1_DIGEST_LENGTH];
	
	if (hashBytes) free (hashBytes);
	
	return hash;
}


-(NSString *)SHA256HashUsingEncoding:(NSStringEncoding)encoding {
   const char *s;
   unsigned char *sd;
   const unsigned int hashlen = CC_SHA256_DIGEST_LENGTH * sizeof(unsigned char);
   CC_LONG slen;
   NSMutableString *sha256Hash;   
   
   sd = (unsigned char *)malloc(hashlen);
   bzero((void *)sd, hashlen);
   
   s = [self cStringUsingEncoding:encoding];
   slen = [self length];
   
   CC_SHA256(s, slen, sd);
   
   sha256Hash = [NSMutableString stringWithCapacity:hashlen];
   
   for (int i = 0; i<hashlen; i+=sizeof(unsigned char)) {
      [sha256Hash appendFormat:@"%02x", sd[i]];
   }
   
   return [NSString stringWithString:sha256Hash];
}


@end
