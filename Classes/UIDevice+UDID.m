//
//  UIDevice+UDID.m
//  Open Bike
//
//  Created by Gregory Kip on 5/28/13.
//  Copyright (c) 2013 Permusoft Corporation.
//

/*
 * Copyright (C) 2013 Permusoft Corporation. All rights reserved.
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


#import "UIDevice+UDID.h"

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "NSString+PSExtensions.h"



@implementation UIDevice (UDID)



#pragma mark MAC addy

// Return the local MAC addy.
// Courtesy of FreeBSD hackers email list.
// Accidentally munged during previous update. Fixed thanks to mlamb.

-(NSString *)macAddress {
   int                 mib[6];
   size_t              len;
   char                *buf;
   unsigned char       *ptr;
   struct if_msghdr    *ifm;
   struct sockaddr_dl  *sdl;
   
   mib[0] = CTL_NET;
   mib[1] = AF_ROUTE;
   mib[2] = 0;
   mib[3] = AF_LINK;
   mib[4] = NET_RT_IFLIST;
   
   if ((mib[5] = if_nametoindex("en0")) == 0) {
      printf("Error: if_nametoindex error\n");
      return NULL;
   }
   
   if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
      printf("Error: sysctl, take 1\n");
      return NULL;
   }
   
   if ((buf = malloc(len)) == NULL) {
      printf("Could not allocate memory. error!\n");
      return NULL;
   }
   
   if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
      printf("Error: sysctl, take 2");
      free(buf);
      return NULL;
   }
   
   ifm = (struct if_msghdr *)buf;
   sdl = (struct sockaddr_dl *)(ifm + 1);
   ptr = (unsigned char *)LLADDR(sdl);
   NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                          *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
   // NSString *outstring = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X",
   //                       *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
   free(buf);
   
   return outstring;
}


-(NSString *)uniqueDeviceIdentifier {
   NSString *macaddress = [[UIDevice currentDevice] macAddress];
   NSString *uniqueGlobalDeviceIdentifier = [macaddress MD5UsingEncoding:NSUTF8StringEncoding];
   
   return uniqueGlobalDeviceIdentifier;
}


@end
