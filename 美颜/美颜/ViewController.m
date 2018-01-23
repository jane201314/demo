//
//  ViewController.m
//  美颜
//
//  Created by rt on 17/10/9.
//  Copyright © 2017年 runtop. All rights reserved.
//

#define ScreenHeight    [UIScreen mainScreen].bounds.size.height
#define ScreenWidth      [UIScreen mainScreen].bounds.size.width
#import "ViewController.h"
#import "GPUImage.h"
#import "GPUImageBeautifyFilter.h"


@interface ViewController (){
    
    UIButton *btn;
}

@property(nonatomic,strong)UISlider *clarity_view;
@property(nonatomic,strong)UISlider *contrastslider;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, weak) GPUImageView *captureVideoPreview;
@property (nonatomic, weak) GPUImageBilateralFilter *bilateralFilter;
@property (nonatomic, weak) GPUImageBrightnessFilter *brightnessFilter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
 
    // 创建视频源
    // SessionPreset:屏幕分辨率，AVCaptureSessionPresetHigh会自适应高分辨率
    // cameraPosition:摄像头方向
    GPUImageVideoCamera *videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _videoCamera = videoCamera;
    
    // 创建最终预览View
    GPUImageView *captureVideoPreview = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:captureVideoPreview atIndex:0];
    _captureVideoPreview = captureVideoPreview;
    
    // 创建滤镜：磨皮，美白，组合滤镜
    GPUImageFilterGroup *groupFilter = [[GPUImageFilterGroup alloc] init];
    
    // 磨皮滤镜
    GPUImageBilateralFilter *bilateralFilter = [[GPUImageBilateralFilter alloc] init];
    [groupFilter addTarget:bilateralFilter];
    _bilateralFilter = bilateralFilter;
    
    // 美白滤镜
    GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    [groupFilter addTarget:brightnessFilter];
    _brightnessFilter = brightnessFilter;
    
    // 设置滤镜组链
    [bilateralFilter addTarget:brightnessFilter];
    [groupFilter setInitialFilters:@[bilateralFilter]];
    groupFilter.terminalFilter = brightnessFilter;

    
    // 设置处理链
    // 设置GPUImage处理链，从数据源 => 滤镜 => 最终界面效果
    [videoCamera addTarget:groupFilter];
    [groupFilter addTarget:_captureVideoPreview];
   // [_videoCamera addTarget:_captureVideoPreview];//
    
    // 必须调用startCameraCapture，底层才会把采集到的视频源，渲染到GPUImageView中，就能显示了。
    // 开始采集视频
    [videoCamera startCameraCapture];
    
    

    
    btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(20, 20, 100, 50);
    [btn setTintColor:[UIColor redColor]];
    [btn setTitle:@"关闭" forState:UIControlStateNormal];
    [btn setTitle:@"美颜" forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [self.view addSubview:self.clarity_view];
    [self.view addSubview:self.contrastslider];
}

#pragma mark 原生美颜
- (void)click:(UIButton *)sender{
    
    sender.selected=!sender.selected;
    // 切换美颜效果原理：移除之前所有处理链，重新设置处理链
    if (sender.selected) {
        
        // 移除之前所有处理链
        [_videoCamera removeAllTargets];
        
        // 创建美颜滤镜
        GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
        
        // 设置GPUImage处理链，从数据源 => 滤镜 => 最终界面效果
        [_videoCamera addTarget:beautifyFilter];
        [beautifyFilter addTarget:_captureVideoPreview];
        
    } else {
        
        // 移除之前所有处理链
        [_videoCamera removeAllTargets];
        [_videoCamera addTarget:_captureVideoPreview];
    }
    
}

- (UISlider *)clarity_view{
    
    if(!_clarity_view){
        _clarity_view=[[UISlider alloc]initWithFrame:CGRectMake((ScreenWidth-200)/2, ScreenHeight-200, 200, 30)];
        _clarity_view.minimumValue=5;
        _clarity_view.maximumValue=10;
        _clarity_view.value=5;
        [_clarity_view setMinimumTrackTintColor:[UIColor greenColor]];
        [_clarity_view setMaximumTrackTintColor:[UIColor whiteColor]];
        [_clarity_view addTarget:self action:@selector(slider:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clarity_view;
}

- (UISlider *)contrastslider{
    
    if(!_contrastslider){
        _contrastslider=[[UISlider alloc]initWithFrame:CGRectMake((ScreenWidth-200)/2, ScreenHeight-120, 200, 30)];
        _contrastslider.minimumValue=0;
        _contrastslider.maximumValue=0.3;
        _contrastslider.value=0;
        [_contrastslider setMinimumTrackTintColor:[UIColor greenColor]];
        [_contrastslider setMaximumTrackTintColor:[UIColor whiteColor]];
        [_contrastslider addTarget:self action:@selector(contrastslider:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _contrastslider;
}


- (void)slider:(UISlider *)slider{
    
    NSLog(@"磨皮===%f",slider.value);
    // 值越小，磨皮效果越好
    CGFloat maxValue = 10;
    [_bilateralFilter setDistanceNormalizationFactor:(maxValue - slider.value)];
}

- (void)contrastslider:(UISlider *)slider{
    
    NSLog(@"美白===%f",slider.value);
     _brightnessFilter.brightness = slider.value;
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
