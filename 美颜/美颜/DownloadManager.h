//
//  DownloadManager.h
//  美颜
//
//  Created by rt on 2018/1/17.
//  Copyright © 2018年 runtop. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessBlock)(NSString *path);
typedef void (^ProgressBlock)(float progress);
typedef void (^FailBlock)(NSError *error);

@interface DownloadManager : NSObject

@property(nonatomic,copy)SuccessBlock successblock;
@property(nonatomic,copy)FailBlock failblock;
@property(nonatomic,copy)ProgressBlock progressblock;

-(void)downLoadWithURL:(NSString *)URL
              progress:(ProgressBlock)progressblock
               success:(SuccessBlock)successblock
                 faile:(FailBlock)faileblock;

+ (instancetype)sharedInstance;

-(void)stopTask;



@end
