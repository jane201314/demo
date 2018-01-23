//
//  DownloadController.m
//  美颜
//
//  Created by rt on 2018/1/17.
//  Copyright © 2018年 runtop. All rights reserved.
//
#import "DownloadManager.h"
#import "DownloadController.h"

@interface DownloadController ()

@end

@implementation DownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor=[UIColor whiteColor];
    UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 50)];
    [btn setTitle:@"开始" forState:UIControlStateNormal];
    btn.backgroundColor=[UIColor grayColor];
    [btn addTarget:self action:@selector(download) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *stopbtn=[[UIButton alloc]initWithFrame:CGRectMake(100, 170, 100, 50)];
    [stopbtn setTitle:@"暂停" forState:UIControlStateNormal];
    stopbtn.backgroundColor=[UIColor grayColor];
    [stopbtn addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopbtn];
   
}

- (void)download{
    
    NSString * downLoadUrl =  @"http://audio.xmcdn.com/group11/M01/93/AF/wKgDa1dzzJLBL0gCAPUzeJqK84Y539.m4a";
    
    [[DownloadManager sharedInstance]downLoadWithURL:downLoadUrl progress:^(float progress) {
        NSLog(@"下载进度===%f",progress);
        
    } success:^(NSString *fileStorePath) {
        NSLog(@"文件地址====###%@",fileStorePath);
        
    } faile:^(NSError *error) {
        NSLog(@"error====###%@",error.userInfo[NSLocalizedDescriptionKey]);
    }];
}


- (void)stop{
    
    [[DownloadManager sharedInstance]stopTask];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
