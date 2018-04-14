
//
//  DDEditInfoVC.m
//  TongParty
//
//  Created by 方冬冬 on 2017/9/26.
//  Copyright © 2017年 桐聚. All rights reserved.
//

#import "DDEditInfoVC.h"
#import "DDTitletxtFieldView.h"

@interface DDEditInfoVC ()
@property (nonatomic, strong) DDTitletxtFieldView *txtFieldView;
@end

@implementation DDEditInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

-(void)setupViews{
    [self navigationWithTitle:self.title];
    self.navigationItem.rightBarButtonItem = [self customTitleButtonForNavigationWithAction:@selector(confirm:) title:@"完成" CGSize:CGSizeMake(DDFitWidth(50.f), DDFitHeight(50.f)) titleColor:kBgGrayColor];
    self.navigationItem.leftBarButtonItem = [self backButtonForNavigationBarWithAction:@selector(pop)];
    self.txtFieldView = [[DDTitletxtFieldView alloc] init];
    [self.view addSubview:self.txtFieldView];
    [self.txtFieldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(1);
        make.left.and.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    self.txtFieldView.style = DDTextFieldStyleNormal;
    self.txtFieldView.ploceholderstr = @"修改昵称";
}


- (void)confirm:(UIBarButtonItem *)sender {
    if (_editResult) {
        _editResult(_txtFieldView.textView.text);
        [self pop];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end





