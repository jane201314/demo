//
//  DownloadManager.m
//  美颜
//
//  Created by rt on 2018/1/17.
//  Copyright © 2018年 runtop. All rights reserved.
//
// 文件名（沙盒中的文件名），使用md5哈希url生成的，这样就能保证文件名唯一   //地址作为文件名不能下载？？
#define  Filename  @"http:ghg"//self.downLoadUrl//.md5String
// 文件的存放路径（caches）
#define  FileStorePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent: Filename]
// 使用plist文件存储文件的总字节数
#define  TotalLengthPlist [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"totalLength.plist"]
// 文件的已被下载的大小
#define  DownloadLength [[[NSFileManager defaultManager] attributesOfItemAtPath: FileStorePath error:nil][NSFileSize] integerValue]


#import "DownloadManager.h"
#import "NSString+Hash.h"

@interface  DownloadManager ()<NSURLSessionDelegate>{
    
    
}
/** 下载任务 */
@property (nonatomic, strong) NSURLSessionDataTask *task;
/** session */
@property (nonatomic, strong) NSURLSession *session;
/** 写文件的流对象 */
@property (nonatomic, strong) NSOutputStream *stream;
/** 文件的总大小 */
@property (nonatomic, assign) NSInteger totalLength;

@property(nonatomic,strong)NSString *downLoadUrl;

@end
@implementation DownloadManager


+ (instancetype)sharedInstance
{
    static DownloadManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    instance = [[DownloadManager alloc] init];
        
    });
    return instance;
}



- (void)downLoadWithURL:(NSString *)URL progress:(ProgressBlock)progressblock success:(SuccessBlock)successblock faile:(FailBlock)faileblock{
    
    
    _successblock=successblock;
    _progressblock=progressblock;
    _failblock=faileblock;
    self.downLoadUrl = URL;
    [self.task resume];
    
   NSLog(@"self.downLoadUrl====%@,%@",Filename,URL);
}

- (void)stopTask{
    
     [self.task suspend ];
}


#pragma mark  - getter方法
- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _session;
}

- (NSOutputStream *)stream
{
    if (!_stream) {
        _stream = [NSOutputStream outputStreamToFileAtPath: FileStorePath append:YES];
    }
    return _stream;
}


- (NSURLSessionDataTask *)task
{
    if (!_task) {
        NSInteger totalLength = [[NSDictionary dictionaryWithContentsOfFile: TotalLengthPlist][ Filename] integerValue];
        
        if (totalLength &&  DownloadLength == totalLength) {
            NSLog(@"######文件已经下载过了");
            return nil;
        }
        
        // 创建请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: self.downLoadUrl]];
        
        // 设置请求头
        // Range : bytes=xxx-xxx，从已经下载的长度开始到文件总长度的最后都要下载
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-",  DownloadLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        // 创建一个Data任务
        _task = [self.session dataTaskWithRequest:request];
    }
    return _task;
}

#pragma mark - <NSURLSessionDataDelegate>
/**
 * 1.接收到响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    // 打开流
    [self.stream open];
    
    /*
     （Content-Length字段返回的是服务器对每次客户端请求要下载文件的大小）
     比如首次客户端请求下载文件A，大小为1000byte，那么第一次服务器返回的Content-Length = 1000，
     客户端下载到500byte，突然中断，再次请求的range为 “bytes=500-”，那么此时服务器返回的Content-Length为500
     所以对于单个文件进行多次下载的情况（断点续传），计算文件的总大小，必须把服务器返回的content-length加上本地存储的已经下载的文件大小
     */
    self.totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] +  DownloadLength;
    
    // 把此次已经下载的文件大小存储在plist文件
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile: TotalLengthPlist];
    if (dict == nil) dict = [NSMutableDictionary dictionary];
    dict[ Filename] = @(self.totalLength);
    [dict writeToFile: TotalLengthPlist atomically:YES];
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * 2.接收到服务器返回的数据（这个方法可能会被调用N次）
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    // 写入数据
    [self.stream write:data.bytes maxLength:data.length];
    NSLog(@"DownloadLength====%zd,%zd",DownloadLength,self.totalLength);
    float progress = 1.0 *  DownloadLength / self.totalLength;
    if (self.progressblock) {
        self.progressblock(progress);
    }
    
    // 下载进度
}

/**
 * 3.请求完毕（成功\失败）
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        if (self.failblock) {
            self.failblock(error);
            self.successblock = nil;
            self.progressblock = nil;
            self.failblock = nil;
            
        }
        self.stream = nil;
        self.task = nil;
        
    }else{
        if (self.successblock) {
            self.successblock(FileStorePath);
            self.successblock = nil;
            self.progressblock = nil;
            self.failblock = nil;
            
        }
        // 关闭流
        [self.stream close];
        self.stream = nil;
        // 清除任务
        self.task = nil;
    }
}



@end
