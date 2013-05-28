//
//  UIDevice+UDID.m
//  CycleTracks
//
//  Created by Gregory Kip on 5/28/13.
//

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
