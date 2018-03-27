//
//  EncrytUtils.m
//  leqisdk
//
//  Created by zhangkai on 2018/1/12.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "EncrytUtils.h"
#import "NetRSA.h"
#import "NSData+GZIP.h"


static NSString *pubkey = @"-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA1zQ4FOFmngBVc05sg7X5\nZ/e3GrhG4rRAiGciUCsrd/n4wpQcKNoOeiRahxKT1FVcC6thJ/95OgBN8jaDzKdd\ncMUti9gGzBDpGSS8MyuCOBXc6KCOYzL6Q4qnlGW2d09blZSpFUluDBBwB86yvOxk\n5oEtnf6WPw2wiWtm7JR1JrE1k+adYfy+Cx9ifJX3wKZ5X3n+CdDXbUCPBD63eMBn\ndy1RYOgI1Sc67bQlQGoFtrhXOGrJ8vVoRNHczaGeBOev96/V0AiEY2f5Kw5PAWhw\nNrAF94DOLu/4OyTVUg9rDC7M97itzBSTwvJ4X5JA9TyiXL6c/77lThXvX+8m/VLi\nmLR7PNq4e0gUCGmHCQcbfkxZVLsa4CDg2oklrT4iHvkK4ZtbNJ2M9q8lt5vgsMkb\nbLLqe9IuTJ9O7Pemp5Ezf8++6FOeUXBQTwSHXuxBNBmZAonNZO1jACfOzm83zEE2\n+Libcn3EBgxPnOB07bDGuvx9AoSzLjFk/T4ScuvXKEhk1xqApSvtPADrRSskV0aE\nG5F8PfBF//krOnUsgqAgujF9unKaxMJXslAJ7kQm5xnDwn2COGd7QEnOkFwqMJxr\nDmcluwXXaZXt78mwkSNtgorAhN6fXMiwRFtwywqoC3jYXlKvbh3WpsajsCsbTiCa\nSBq4HbSs5+QTQvmgUTPwQikCAwEAAQ==\n-----END PUBLIC KEY-----\n";


static char *k = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ*!";
@implementation EncrytUtils

+ (NSString *)encode:(NSString *)str {
    if(str == nil) return @"";
    
    NSMutableString *result = [NSMutableString new];
    const char *carr = [[[str dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0] UTF8String];
    size_t length= strlen(carr);
    [result appendString:@"x"];
    for (int i = 0; i < length; i++) {
        [result appendString:[NSString stringWithFormat:@"%d", carr[i] + k[i%strlen(k)]]];
        if(i != length - 1){
            [result appendString:@"_"];
        }
    }
    [result appendString:@"y"];
    NSLog(@"%@", result);
    return result;
}

+ (NSString *)getPubKey {
    return pubkey;
}

+ (void)setPubKey:(NSString *)_pubkey {
    pubkey = _pubkey;
}

+ (NSString *)decode:(NSString *)str {
    if(str == nil) return @"";
    NSMutableString *result = [NSMutableString new];
    if([str hasPrefix:@"x"] && [str hasSuffix:@"y"]){
        NSRange range = NSMakeRange(1, str.length - 2);
        NSArray *sarr = [[str substringWithRange:range] componentsSeparatedByString:@"_"];
        for(int i = 0; i < [sarr count]; i++){
            [result appendString:[NSString stringWithFormat:@"%c", [sarr[i] intValue] - k[i%strlen(k)]]];
        }
    }
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:result options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return decodedString;
}

+ (NSString *)rsaWithPublickey:(NSString *)publicKey data:(NSString *)jsonStr {
    return [NetRSA encryptString:jsonStr publicKey:publicKey];
}

+ (NSData *)gzipByRsa:(NSString *)jsonStr {
    if(jsonStr == nil) return nil;
    jsonStr = [EncrytUtils rsaWithPublickey:[EncrytUtils getPubKey] data:jsonStr];
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    return [jsonData gzippedData];
}

+ (NSString *)upgzipByResponse:(NSData *)data {
    if(data ==  nil) return nil;
    NSData *undata = [data gunzippedData];
    NSString *str = [[NSString alloc] initWithData:undata encoding:NSUTF8StringEncoding];
    return [EncrytUtils decode:str];
}


@end
