//
//  ARSCNViewRotateController.m
//  自定义AR实现
//
//  Created by 黄红荫 on 2017/10/1.
//  Copyright © 2017年 黄红荫. All rights reserved.
//

#import "ARSCNViewRotateController.h"
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
@interface ARSCNViewRotateController ()
//AR视图：展示3D界面
@property (nonatomic, strong) ARSCNView *arSCNView;
//AR会话：负责管理相机追踪配置及3D相机坐标
@property (nonatomic, strong) ARSession *arSession;
//会话追踪配置：负责追踪相机的运动
@property (nonatomic, strong) ARConfiguration *arConfiguration;
//飞机3D模型
@property (nonatomic, strong) SCNNode *planeNode;

@end

@implementation ARSCNViewRotateController

#pragma mark- 搭建ARKit环境
// 懒加载
- (ARSCNView *)arSCNView
{
    if(_arSCNView) return _arSCNView;
    _arSCNView = [[ARSCNView alloc]initWithFrame:self.view.bounds];
    _arSCNView.session = self.arSession;
    _arSCNView.automaticallyUpdatesLighting = YES;
    return _arSCNView;
    
}
- (ARSession *)arSession
{
    if(_arSession) return _arSession;
    _arSession = [[ARSession alloc]init];
    return _arSession;
    
}
- (ARConfiguration *)arConfiguration
{
    if(_arConfiguration) return _arConfiguration;
    // 创建世界会话追踪配置
    ARWorldTrackingConfiguration *cfg  = [[ARWorldTrackingConfiguration alloc]init];
    // 设置追踪方向:追踪平面
    cfg.planeDetection = ARPlaneDetectionHorizontal;
    _arConfiguration = cfg;
    //自适应灯光
    _arConfiguration.lightEstimationEnabled = YES;
    return _arConfiguration;
    
}
- (void)back:(UIButton *)btn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Called when the view has been fully transitioned onto the screen. Default does nothing
    // 将AR视图添加到当前视图
    [self.view addSubview:self.arSCNView];
    // 开启AR会话:此时相机开始工作
    [self.arSession runWithConfiguration:self.arConfiguration];
    
    // 添加返回按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    btn.frame = CGRectMake(self.view.bounds.size.width / 2 - 50, self.view.bounds.size.height - 100, 100, 50);
    btn.backgroundColor = [UIColor greenColor];
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 使用场景加载scn文件
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
    // 获取模型的节点
    SCNNode *planeNode = scene.rootNode.childNodes[0];
    self.planeNode = planeNode;
    planeNode.scale = SCNVector3Make(0.5, 0.5, 0.5);
    planeNode.position = SCNVector3Make(0, -15, -15);
    for (SCNNode *node in planeNode.childNodes ) {
        node.scale = SCNVector3Make(0.5, 0.5, 0.5);
        node.position = SCNVector3Make(0, -15, -15);
    }
    self.planeNode.position = SCNVector3Make(0, 0, -20);
    // 绕相机旋转: 创建一个空节点，然后将模型添加到这个空节点，最后让这个空节点自身旋转，就可以实现模型绕相机旋转
    SCNNode *node1 = [[SCNNode alloc]init];
    node1.position = self.arSCNView.scene.rootNode.position;
    //将空节点添加到当前相机的根节点
    [self.arSCNView.scene.rootNode addChildNode:node1];
    // 将模型节点作为空节点的字节点
    [node1 addChildNode:self.planeNode];
    CABasicAnimation *annimate = [CABasicAnimation animationWithKeyPath:@"totation"];
    annimate.duration = 30;
    annimate.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI *2)];
    annimate.repeatCount = FLT_MAX;
    [node1 addAnimation:annimate forKey:@"moon rotation around earth"];
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
