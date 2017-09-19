//
//  ValidBaseObject.m
//  ValidObject
//
//  Created by zhupeng on 2017/9/11.
//  Copyright © 2017年 Alger. All rights reserved.
//

#import "ValidBaseObject.h"
#import <objc/runtime.h>

#define CommonNullStr @""

@implementation ValidBaseObject

- (id) valid{
    unsigned int count = 0;
    //获取属性列表
    Ivar *members = class_copyIvarList([self class], &count);
    
    //遍历属性列表
    for (int i = 0 ; i < count; i++) {
        Ivar var = members[i];
        //获取变量名称
        const char *memberName = ivar_getName(var);
        //获取变量类型
        const char *memberType = ivar_getTypeEncoding(var);
        
        Ivar ivar = class_getInstanceVariable([self class], memberName);
        
        NSString *typeStr = [NSString stringWithCString:memberType encoding:NSUTF8StringEncoding];
        
        if (![typeStr isEqualToString:@"i"]) {
            object_setIvar(self, ivar, [self check:[self valueForKey:(NSString *)[NSString stringWithUTF8String:memberName]] type:typeStr]);
        }
    }
    return self;
}

- (id) check:(id) obj type:(NSString *)type {
    if([type isEqualToString:@"@\"NSString\""]){
        if ([self isNullOrEmpty:obj]) {
            return CommonNullStr;
        }
    } else if([type isEqualToString:@"@\"NSArray\""] || [type isEqualToString:@"@\"NSMutableArray\""]){
        if (obj) {
            NSMutableArray *arr = [NSMutableArray arrayWithArray: obj];
            for(int i = 0; i < arr.count; i++){
                id object = [arr objectAtIndex:i];
                if ([object isKindOfClass:[ValidBaseObject class]]) {
                    id validObj = [object valid];
                    [arr replaceObjectAtIndex:i withObject:validObj];
                }
            }
            return arr;
        }
        return [NSArray array];
    } else if ([obj isKindOfClass:[ValidBaseObject class]]) {
        id validObj = [obj valid];
        return validObj;
    }
    return obj;
}

- (BOOL)isNullOrEmpty:(NSString *)str {
    return  !str || str==nil || (NSString*)[NSNull null]==str || [str isEqualToString:@""] || [str isEqualToString:CommonNullStr];
}

@end
