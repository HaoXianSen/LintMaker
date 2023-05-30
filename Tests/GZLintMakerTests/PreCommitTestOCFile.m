//
//  JPKDebugSettingsViewController.m
//  YoudaoCourse
//
//  Created by zengbl on 2017/3/20.
//  Copyright © 2017年 网易有道. All rights reserved.
//

#import "JPKDebugSettingsViewController.h"
#import "JPKDebugSectionTitleItem.h"
#import "JPKDebugCheckmarkItem.h"
#import "JPKDebugOpenPageViewController.h"
#import "JPKDebugInputItem.h"
#import "JPDebugParameterModVC.h"
#import <AICourse_iOS-Swift.h>

@import JPKUtils;
@import XTHTTPManager;
@import JPKCommonInfo;
@import SAMKeychain;
@import YDAccountSDK;
@import LSLoginModule_iOS;
@import JPKUI_iOS;

#if DEBUG
#import <FLEX/FLEXManager.h>
#endif
static NSString *const kJPKDebugSettingsDeepLinkURL = @"http://c.youdao.com/course_live/newLive.html";


@interface PreCommitTestOCFile () <UIAlertViewDelegate, UITextFieldDelegate>

@end


@implementation PreCommitTestOCFile

#pragma mark - VC Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.items = [self generateTableData];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(self.view);
    }];
}

#pragma mark Private Method
- (NSArray *)generateTableData {
    // 课程服务
    JPKDebugCheckmarkItem *baseOnlineItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"Online"];
    JPKDebugCheckmarkItem *test1Item = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"ydls-test-gateway-user"];
    JPKDebugCheckmarkItem *test2Item = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"ydls-test1-gateway-user-test1"];
    JPKDebugCheckmarkItem *test3Item = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"ydls-test2-gateway-user-test2"];
    JPKDebugCheckmarkItem *test4Item = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"ydls-test3-gateway-user-test3"];
    JPKDebugCheckmarkItem *test5Item = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"ydls-pre"];
    JPKDebugInputItem *customBaseItem = [JPKDebugInputItem itemWithPlaceholder:@"自定义，如http://xuetang-test8.youdao.com"];
    @weakify(self);
    
    customBaseItem.title = [[JPKBaseURL sharedInstance] customServer];
    customBaseItem.textEndEditingOperation = ^(NSString *text) {
        @strongify(self);
        if (text.length == 0) {
            if ([[JPKBaseURL sharedInstance] customServer] != nil) {
                [self showHint:@"已清除自定义服务器" hide:1];
            }
            [[JPKBaseURL sharedInstance] removeCustomServer];
        } else {
            [[JPKBaseURL sharedInstance] setCustomServer:text];
        }
        [self.view endEditing:YES];
        self.items = [self generateTableData];
    };
    JPKBaseServerType type = [[JPKBaseURL sharedInstance] serverType];
    switch (type) {
        case JPKBaseServerTypeOnline:
            baseOnlineItem.checked = YES;
            test1Item.checked = NO;
            test2Item.checked = NO;
            test3Item.checked = NO;
            test4Item.checked = NO;
            test5Item.checked = NO;
            break;
        case JPKBaseServerTypeTest1:
            baseOnlineItem.checked = NO;
            test1Item.checked = YES;
            test2Item.checked = NO;
            test3Item.checked = NO;
            test4Item.checked = NO;
            test5Item.checked = NO;
            break;
        case JPKBaseServerTypeTest2:
            baseOnlineItem.checked = NO;
            test1Item.checked = NO;
            test2Item.checked = YES;
            test3Item.checked = NO;
            test4Item.checked = NO;
            test5Item.checked = NO;
            break;
        case JPKBaseServerTypeTest3:
            baseOnlineItem.checked = NO;
            test1Item.checked = NO;
            test2Item.checked = NO;
            test3Item.checked = YES;
            test4Item.checked = NO;
            test5Item.checked = NO;
            break;
        case JPKBaseServerTypeTest4:
            baseOnlineItem.checked = NO;
            test1Item.checked = NO;
            test2Item.checked = NO;
            test3Item.checked = NO;
            test4Item.checked = YES;
            test5Item.checked = NO;
            break;
        case JPKBaseServerTypeProd:
            baseOnlineItem.checked = NO;
            test1Item.checked = NO;
            test2Item.checked = NO;
            test3Item.checked = NO;
            test4Item.checked = NO;
            test5Item.checked = YES;
            break;
        case JPKBaseServerTypeCustom:
            baseOnlineItem.checked = NO;
            test1Item.checked = NO;
            break;
            
        default:
            break;
    }
    [self setCheckActionForItem:baseOnlineItem type:JPKBaseServerTypeOnline];
    [self setCheckActionForItem:test1Item type:JPKBaseServerTypeTest1];
    [self setCheckActionForItem:test2Item type:JPKBaseServerTypeTest2];
    [self setCheckActionForItem:test3Item type:JPKBaseServerTypeTest3];
    [self setCheckActionForItem:test4Item type:JPKBaseServerTypeTest4];
    [self setCheckActionForItem:test5Item type:JPKBaseServerTypeProd];

    // 知识图谱
    JPKDebugCheckmarkItem *mapOnlineItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"Online"];
    JPKDebugCheckmarkItem *mapTestItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"Test-(测试服测试环境)"];
    JPKDebugCheckmarkItem *mapTest1Item = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"Test1-(测试服测试环境)"];
    JPKDebugCheckmarkItem *mapTest2Item = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"Test2-(预发测试环境)"];
    JPKDebugInputItem *customMapItem = [JPKDebugInputItem itemWithPlaceholder:@"自定义，如http://xuetang-test8.youdao.com"];
    
    customMapItem.title = [[JPKKnowledgeMapURL sharedInstance] customServer];
    customMapItem.textEndEditingOperation = ^(NSString *text) {
        @strongify(self);
        if (text.length == 0) {
            if ([[JPKKnowledgeMapURL sharedInstance] customServer] != nil) {
                [self showHint:@"已清除自定义服务器" hide:1];
            }
            [[JPKKnowledgeMapURL sharedInstance] removeCustomServer];
        } else {
            [[JPKKnowledgeMapURL sharedInstance] setCustomServer:text];
        }
        [self.view endEditing:YES];
        self.items = [self generateTableData];
    };
    
    LSKnowledgeMapWebServerType mapType = [[JPKKnowledgeMapURL sharedInstance] serverType];
    switch (mapType) {
        case LSKnowledgeMapTypeOnline:
            mapOnlineItem.checked = YES;
            mapTestItem.checked = NO;
            mapTest1Item.checked = NO;
            mapTest2Item.checked = NO;
            break;
        case LSKnowledgeMapTypeTest:
            mapOnlineItem.checked = NO;
            mapTestItem.checked = YES;
            mapTest1Item.checked = NO;
            mapTest2Item.checked = NO;
            break;
        case LSKnowledgeMapTypeTest1:
            mapOnlineItem.checked = NO;
            mapTestItem.checked = NO;
            mapTest1Item.checked = YES;
            mapTest2Item.checked = NO;
            break;
        case LSKnowledgeMapTypePreTest:
            mapOnlineItem.checked = NO;
            mapTestItem.checked = NO;
            mapTest1Item.checked = NO;
            mapTest2Item.checked = YES;
            break;
        case LSKnowledgeMapTypeCustom:
            mapOnlineItem.checked = NO;
            mapTestItem.checked = NO;
            mapTest1Item.checked = NO;
            mapTest2Item.checked = NO;
            break;
    }
    [self setCheckActionForItem:mapOnlineItem mapType:LSKnowledgeMapTypeOnline];
    [self setCheckActionForItem:mapTestItem mapType:LSKnowledgeMapTypeTest];
    [self setCheckActionForItem:mapTest1Item mapType:LSKnowledgeMapTypeTest1];
    [self setCheckActionForItem:mapTest2Item mapType:LSKnowledgeMapTypePreTest];

    // 试卷分析
    JPKDebugCheckmarkItem *paperOnlineItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"Online"];
    JPKDebugCheckmarkItem *paperTestItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"Test-(测试服测试环境)"];
    JPKDebugInputItem *customPaperItem = [JPKDebugInputItem itemWithPlaceholder:@"自定义，如http://xuetang-test8.youdao.com"];
    
    customPaperItem.title = [[JPKAnalysisPaperWebURL sharedInstance] customServer];
    customPaperItem.textEndEditingOperation = ^(NSString *text) {
        @strongify(self);
        if (text.length == 0) {
            if ([[JPKAnalysisPaperWebURL sharedInstance] customServer] != nil) {
                [self showHint:@"已清除自定义服务器" hide:1];
            }
            [[JPKAnalysisPaperWebURL sharedInstance] removeCustomServer];
        } else {
            [[JPKAnalysisPaperWebURL sharedInstance] setCustomServer:text];
        }
        [self.view endEditing:YES];
        self.items = [self generateTableData];
    };
    
    LSAnalysisWebServerType paperType = [[JPKAnalysisPaperWebURL sharedInstance] serverType];
    switch (paperType) {
        case LSAnalysisTypeOnline:
            paperOnlineItem.checked = YES;
            paperTestItem.checked = NO;
            break;
        case LSAnalysisTypeTest:
            paperOnlineItem.checked = NO;
            paperTestItem.checked = YES;
            break;
        case LSAnalysisTypeCustom:
            paperOnlineItem.checked = NO;
            paperTestItem.checked = NO;
            break;
    }
    [self setCheckActionForItem:paperOnlineItem analysisType:LSAnalysisTypeOnline];
    [self setCheckActionForItem:paperTestItem analysisType:LSAnalysisTypeTest];
    
    // 学习计划
    JPKDebugCheckmarkItem *planOnlineItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"Online"];
    JPKDebugCheckmarkItem *planTestItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"Test-(测试服测试环境)"];
    JPKDebugInputItem *customPlanItem = [JPKDebugInputItem itemWithPlaceholder:@"自定义，如http://xuetang-test8.youdao.com"];
    
    customPlanItem.title = [[JPKStudyPlanURL sharedInstance] customServer];
    customPlanItem.textEndEditingOperation = ^(NSString *text) {
        @strongify(self);
        if (text.length == 0) {
            if ([[JPKStudyPlanURL sharedInstance] customServer] != nil) {
                [self showHint:@"已清除自定义服务器" hide:1];
            }
            [[JPKStudyPlanURL sharedInstance] removeCustomServer];
        } else {
            [[JPKStudyPlanURL sharedInstance] setCustomServer:text];
        }
        [self.view endEditing:YES];
        self.items = [self generateTableData];
    };
    LSStudyPlanServerType planType = [[JPKStudyPlanURL sharedInstance] serverType];
    switch (planType) {
        case LSStudyPlanTypeOnline:
            planOnlineItem.checked = YES;
            planTestItem.checked = NO;
            break;
        case LSStudyPlanTypeTest:
            planOnlineItem.checked = NO;
            planTestItem.checked = YES;
            break;
        case LSStudyPlanTypeCustom:
            planOnlineItem.checked = NO;
            planTestItem.checked = NO;
            break;
    }
    [self setCheckActionForItem:planOnlineItem planType:LSStudyPlanTypeOnline];
    [self setCheckActionForItem:planTestItem planType:LSStudyPlanTypeTest];
    
    
    // 学业诊断
    JPKDebugCheckmarkItem *diagnosisOnlineItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"Online"];
    JPKDebugCheckmarkItem *diagnosisTestItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"Test-(测试服测试环境)"];
    JPKDebugInputItem *customDiagnosisItem = [JPKDebugInputItem itemWithPlaceholder:@"自定义，如http://xuetang-test8.youdao.com"];
    
    customDiagnosisItem.title = [[JPKDiagnosisURL sharedInstance] customServer];
    customDiagnosisItem.textEndEditingOperation = ^(NSString *text) {
        @strongify(self);
        if (text.length == 0) {
            if ([[JPKDiagnosisURL sharedInstance] customServer] != nil) {
                [self showHint:@"已清除自定义服务器" hide:1];
            }
            [[JPKDiagnosisURL sharedInstance] removeCustomServer];
        } else {
            [[JPKDiagnosisURL sharedInstance] setCustomServer:text];
        }
        [self.view endEditing:YES];
        self.items = [self generateTableData];
    };
    LSStudyDiagnosisServerType diagnosisType = [[JPKDiagnosisURL sharedInstance] serverType];
    switch (diagnosisType) {
        case LSStudyDiagnosisTypeOnline:
            diagnosisOnlineItem.checked = YES;
            diagnosisTestItem.checked = NO;
            break;
        case LSStudyDiagnosisTypeTest:
            diagnosisOnlineItem.checked = NO;
            diagnosisTestItem.checked = YES;
            break;
        case LSStudyDiagnosisCustom:
            diagnosisOnlineItem.checked = NO;
            diagnosisTestItem.checked = NO;
            break;
    }
    [self setCheckActionForItem:diagnosisOnlineItem diagnosisType:LSStudyDiagnosisTypeOnline];
    [self setCheckActionForItem:diagnosisTestItem diagnosisType:LSStudyDiagnosisTypeTest];
    
    // 试卷批改服务配置
    JPKDebugCheckmarkItem *quizOnlineItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"Online"];
    JPKDebugCheckmarkItem *quizTestItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"Test-(测试服测试环境)"];
    JPKDebugCheckmarkItem *quizProdTestItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"Test-(预发测试环境)"];
    JPKDebugInputItem *customQuizItem = [JPKDebugInputItem itemWithPlaceholder:@"自定义，如https://f2estatic.inner.ydshengxue.com/"];
    
    customQuizItem.title = [[JPKDiagnosisURL sharedInstance] customServer];
    customQuizItem.textEndEditingOperation = ^(NSString *text) {
        @strongify(self);
        if (text.length == 0) {
            if ([[JPKQuizURL sharedInstance] customServer] != nil) {
                [self showHint:@"已清除自定义服务器" hide:1];
            }
            [[JPKQuizURL sharedInstance] removeCustomServer];
        } else {
            [[JPKQuizURL sharedInstance] setCustomServer:text];
        }
        [self.view endEditing:YES];
        self.items = [self generateTableData];
    };
    
    JPKQuizServerType quizType = [[JPKQuizURL sharedInstance] serverType];
    switch (quizType) {
        case JPKQuizServerTypeOnline:
            quizOnlineItem.checked = YES;
            quizTestItem.checked = NO;
            quizProdTestItem.checked = NO;
            break;
        case JPKQuizServerTypeTest:
            quizOnlineItem.checked = NO;
            quizTestItem.checked = YES;
            quizProdTestItem.checked = NO;
            break;
        case JPKQuizServerTypeProdTest:
            quizOnlineItem.checked = NO;
            quizTestItem.checked = NO;
            quizProdTestItem.checked = YES;
            break;
        case JPKQuizServerTypeCustom:
            quizOnlineItem.checked = NO;
            quizTestItem.checked = NO;
            quizProdTestItem.checked = NO;
            break;
    }
    [self setCheckActionForItem:quizOnlineItem quizType:JPKQuizServerTypeOnline];
    [self setCheckActionForItem:quizTestItem quizType:JPKQuizServerTypeTest];
    [self setCheckActionForItem:quizProdTestItem quizType:JPKQuizServerTypeProdTest];

    JPKDebugInputItem *rnABTestCoverageItem = [JPKDebugInputItem itemWithPlaceholder:@"ABTest覆盖率0~10,0为不覆盖，10为全量覆盖"];
    rnABTestCoverageItem.title = [XTCommonInfoManager sharedInstance].abtest;
    rnABTestCoverageItem.textEndEditingOperation = ^(NSString *text) {
        @strongify(self);
        NSString *currentABTestCoverage = @"";
        if (text.length == 0) {
            [self showHint:@"已关闭ABTest，下次进入时获取userConfig接口返回的ABTest" hide:1.0];
        } else {
            currentABTestCoverage = text;
        }
        [self.view endEditing:YES];
        [XTCommonInfoManager sharedInstance].abtest = currentABTestCoverage;
    };
    
    // 直播服务
    JPKDebugCheckmarkItem *liveOnlineItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"Online"];
    JPKDebugCheckmarkItem *liveTestItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"liveTest"];
    JPKDebugInputItem *customLiveItem = [JPKDebugInputItem itemWithPlaceholder:@"https://live.youdao.com"];
    customLiveItem.title = [[JPKLiveURL sharedInstance] customServer];
    customLiveItem.textEndEditingOperation = ^(NSString *text) {
        @strongify(self);
        if (text.length == 0) {
            if ([[JPKLiveURL sharedInstance] customServer] != nil) {
                [self showHint:@"已清除自定义服务器" hide:1];
            }
            [[JPKLiveURL sharedInstance] removeCustomServer];
        } else {
            [[JPKLiveURL sharedInstance] setCustomServer:text];
        }
        [self.view endEditing:YES];
        self.items = [self generateTableData];
    };
    JPKLiveServerType liveType = [[JPKLiveURL sharedInstance] serverType];
    switch (liveType) {
        case JPKLiveServerTypeOnline:
            liveOnlineItem.checked = YES;
            liveTestItem.checked = NO;
            break;
        case JPKLiveServerTypeTest:
            liveOnlineItem.checked = NO;
            liveTestItem.checked = YES;
            break;
        case JPKLiveServerTypeCustom:
            liveOnlineItem.checked = NO;
            liveTestItem.checked = NO;
            break;
        default:
            break;
    }
    [self setCheckActionForItem:liveOnlineItem liveType:JPKLiveServerTypeOnline];
    [self setCheckActionForItem:liveTestItem liveType:JPKLiveServerTypeTest];
    
    // soda
    JPKDebugSectionTitleItem *sodaItem = [[JPKDebugSectionTitleItem alloc] initWithTitle:@"开启Soda测试服"];
    sodaItem.needSwitcher = YES;
    sodaItem.swicherID = @"SwitchToSodaTestServer";
    sodaItem.swithcherIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:kJPKSodaDebugMode];
    
    JPKDebugInputItem *sodaCustomItem = [JPKDebugInputItem itemWithPlaceholder:@"添加soda自定义服务器"];
    NSString *sodaTestServer = [[NSUserDefaults standardUserDefaults] objectForKey:kJPKSodaDebugTestServer];
    if (!sodaTestServer || sodaTestServer.length <= 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@"testsoda.youdao.com:8002" forKey:kJPKSodaDebugTestServer];
    }
    sodaCustomItem.title = [[NSUserDefaults standardUserDefaults] objectForKey:kJPKSodaDebugTestServer] ?: @" testsoda.youdao.com:8002";
    sodaCustomItem.textEndEditingOperation = ^(NSString *text) {
        @strongify(self);
        if (text.length != 0) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kJPKSodaDebugMode]) {
                [[NSUserDefaults standardUserDefaults] setObject:text forKey:kJPKSodaDebugTestServer];
            }
        }
        [self.view endEditing:YES];
    };
    
    // 跳转售前详情页
    JPKDebugCheckmarkItem *openPreSaleItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"跳转售前详情页"];
    openPreSaleItem.checked = NO;
    @weakify(openPreSaleItem);
    openPreSaleItem.checkOperation = ^(BOOL check) {
        @strongify(openPreSaleItem);
        [@"xt://debug_page" openWithQuery:@{@"type" : @(YDLSDebugOpenPageTypePreSale)}];
        openPreSaleItem.checked = NO;
    };

    JPKDebugCheckmarkItem *deepLinkItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"DeepLink"];
    deepLinkItem.checked = NO;
    @weakify(deepLinkItem);
    deepLinkItem.checkOperation = ^(BOOL check) {
        @strongify(self, deepLinkItem);
        [self alertDeepLink];
        deepLinkItem.checked = NO;
    };
    
    JPKDebugCheckmarkItem *wkOpenUrlItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"跳转Url链接(新WKWebview)"];
    wkOpenUrlItem.checked = NO;
    @weakify(wkOpenUrlItem);
    wkOpenUrlItem.checkOperation = ^(BOOL check) {
        @strongify(wkOpenUrlItem);
        [@"xt://debug_page" openWithQuery:@{@"type" : @(JPKDebugOpenPageTypeUrlUI)}];
        wkOpenUrlItem.checked = NO;
    };
    
    JPKDebugCheckmarkItem *openLiveDetailItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"视频播放页"];
    openLiveDetailItem.checked = NO;
    @weakify(openLiveDetailItem);
    openLiveDetailItem.checkOperation = ^(BOOL check) {
        @strongify(openLiveDetailItem);
        [@"xt://debug_page" openWithQuery:@{@"type" : @(JPKDebugOpenPageTypeLivePlayer)}];
        openLiveDetailItem.checked = NO;
    };
    
    JPKDebugCheckmarkItem *chatStatisticsItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"直播讨论区快速统计"];
    chatStatisticsItem.checked = NO;
    @weakify(chatStatisticsItem);
    chatStatisticsItem.checkOperation = ^(BOOL check) {
        @strongify(chatStatisticsItem, self);
        JPChatStatisticsParameterMod *modVC = [[JPChatStatisticsParameterMod alloc] init];
        [self.navigationController pushViewController:modVC animated:YES];
        chatStatisticsItem.checked = NO;
    };
    
    JPKDebugCheckmarkItem *heartBeatItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"心跳设置"];
    heartBeatItem.checked = NO;
    @weakify(heartBeatItem);
    heartBeatItem.checkOperation = ^(BOOL check) {
        @strongify(heartBeatItem, self);
        JPDebugHeartBeatModVCViewController *modVC = [[JPDebugHeartBeatModVCViewController alloc] init];
        [self.navigationController pushViewController:modVC animated:YES];
        heartBeatItem.checked = NO;
    };
    
    JPKDebugCheckmarkItem *eyeCareTimeItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"护眼模式"];
    eyeCareTimeItem.checked = NO;
    @weakify(eyeCareTimeItem);
    eyeCareTimeItem.checkOperation = ^(BOOL check) {
        @strongify(eyeCareTimeItem, self);
        JPDebugParameterModVC *modVC = [[JPDebugParameterModVC alloc] initWithType:JPDebugParameterModEyeCare];
        [self.navigationController pushViewController:modVC animated:YES];
        eyeCareTimeItem.checked = NO;
    };
    
    JPKDebugCheckmarkItem *cleanLoginItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"清除上次登录"];
    cleanLoginItem.checked = NO;
    @weakify(cleanLoginItem);
    cleanLoginItem.checkOperation = ^(BOOL check) {
        @strongify(self, cleanLoginItem);
        cleanLoginItem.checked = NO;
        [YDAccountBridge removeLastLoginInfo];
        gUser.loginMobile = nil;
        [self showHint:@"已成功清除上次登录"];
    };
    
    JPKDebugCheckmarkItem *cleanClassGuide = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"清除本地视图缓存"];
    cleanClassGuide.checked = NO;
    @weakify(cleanClassGuide);
    cleanClassGuide.checkOperation = ^(BOOL check) {
        @strongify(self, cleanClassGuide);
        cleanClassGuide.checked = NO;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"firstGuide"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"firstPopover"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hasNoMorePrompts"];
        [self showHint:@"已清除"];
    };
    
    JPKDebugCheckmarkItem *flexItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:@"显示FLEX窗口"];
    flexItem.checked = NO;
    @weakify(flexItem);
    flexItem.checkOperation = ^(BOOL check) {
        @strongify(flexItem);
        flexItem.checked = NO;
#if DEBUG
        if ([FLEXManager sharedManager].isHidden) {
            [[FLEXManager sharedManager] showExplorer];
        }
#endif
    };
    
    JPKDebugSectionTitleItem *testloginItem = [[JPKDebugSectionTitleItem alloc] initWithTitle:@"登录测试服切换"];
    testloginItem.needSwitcher = YES;
    testloginItem.swicherTitle = @"打开测试服";
    testloginItem.swicherID = kJPKLoginDebugModeExist;
    testloginItem.swithcherIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:kJPKLoginDebugModeExist];
    
    JPKDebugSectionTitleItem *launchConfigItem = [[JPKDebugSectionTitleItem alloc] initWithTitle:@"启动配置测试服切换"];
    launchConfigItem.needSwitcher = YES;
    launchConfigItem.swicherTitle = @"打开测试服";
    launchConfigItem.swicherID = kJPKLaunchConfigDebugModeExist;
    launchConfigItem.swithcherIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:kJPKLaunchConfigDebugModeExist];
    
    
    JPKDebugSectionTitleItem *testPushItem = [[JPKDebugSectionTitleItem alloc] initWithTitle:@"推送测试服切换"];
    testPushItem.needSwitcher = YES;
    testPushItem.swicherTitle = @"打开测试服";
    testPushItem.swicherID = Constants.kPushServerDebugKey;
    testPushItem.swithcherIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:Constants.kPushServerDebugKey];
    
    JPKDebugCheckmarkItem *imeiItem = [[JPKDebugCheckmarkItem alloc] initWithTitle:XString(@"复制imei:%@", [XTCommonInfoManager sharedInstance].imei)];
    imeiItem.checked = NO;
    @weakify(imeiItem);
    imeiItem.checkOperation = ^(BOOL check) {
        @strongify(self, imeiItem);
        imeiItem.checked = NO;
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [XTCommonInfoManager sharedInstance].imei;
        [self showHint:@"已成功复制imei"];
    };

    
    return @[ @[ [[JPKDebugSectionTitleItem alloc] initWithTitle:@"商品服务"],
                baseOnlineItem, test1Item, test2Item, test3Item, test4Item, test5Item, customBaseItem,
                [[JPKDebugSectionTitleItem alloc] initWithTitle:@"直播服务"],
                liveOnlineItem, liveTestItem, sodaItem, sodaCustomItem,
                [[JPKDebugSectionTitleItem alloc] initWithTitle:@"知识图谱服务"], mapOnlineItem, mapTestItem, mapTest1Item, mapTest2Item, customMapItem,
                [[JPKDebugSectionTitleItem alloc] initWithTitle:@"试卷分析服务"], paperOnlineItem, paperTestItem, customPaperItem,
                [[JPKDebugSectionTitleItem alloc] initWithTitle:@"学习计划服务"], planOnlineItem, planTestItem, customPlanItem,
                [[JPKDebugSectionTitleItem alloc] initWithTitle:@"学业诊断服务"], diagnosisOnlineItem, diagnosisTestItem, customDiagnosisItem,
                [[JPKDebugSectionTitleItem alloc] initWithTitle:@"试卷批改服务"], quizOnlineItem, quizTestItem, quizProdTestItem, customQuizItem,
                [[JPKDebugSectionTitleItem alloc] initWithTitle:@"ABTest分桶设定"], rnABTestCoverageItem,
                [[JPKDebugSectionTitleItem alloc] initWithTitle:@"页面跳转"], openPreSaleItem,
                deepLinkItem, wkOpenUrlItem,
                [[JPKDebugSectionTitleItem alloc] initWithTitle:@"参数修改"],
                chatStatisticsItem, heartBeatItem,
                [[JPKDebugSectionTitleItem alloc] initWithTitle:@"常用工具"],
                eyeCareTimeItem, imeiItem, cleanLoginItem, cleanClassGuide, flexItem, testloginItem, launchConfigItem, testPushItem ] ];
}

- (void)setCheckActionForItem:(JPKDebugCheckmarkItem *)item type:(JPKBaseServerType)type {
    @weakify(self);
    item.checkOperation = ^(BOOL isChecked) {
        @strongify(self);
        if (isChecked) {
            [[JPKBaseURL sharedInstance] setServerType:type];
        }
        self.items = [self generateTableData];
    };
}

- (void)setCheckActionForItem:(JPKDebugCheckmarkItem *)item newBasetype:(LSNewBaseServerType)type {
    @weakify(self);
    item.checkOperation = ^(BOOL isChecked) {
        @strongify(self);
        if (isChecked) {
            [[JPKNewBaseURL sharedInstance] setServerType:type];
        }
        self.items = [self generateTableData];
    };
}

- (void)setCheckActionForItem:(JPKDebugCheckmarkItem *)item teamType:(JPKTeamServerType)type {
    @weakify(self);
    item.checkOperation = ^(BOOL isChecked) {
        @strongify(self);
        if (isChecked) {
            [[JPKTeamURL sharedInstance] setServerType:type];
        }
        self.items = [self generateTableData];
    };
}

- (void)setCheckActionForItem:(JPKDebugCheckmarkItem *)item ypadType:(JPKYpadServerType)type {
    @weakify(self);
    item.checkOperation = ^(BOOL isChecked) {
        @strongify(self);
        if (isChecked) {
            [[JPKYpadURL sharedInstance] setServerType:type];
        }
        self.items = [self generateTableData];
    };
}

- (void)setCheckActionForItem:(JPKDebugCheckmarkItem *)item liveType:(JPKLiveServerType)type {
    @weakify(self);
    item.checkOperation = ^(BOOL isChecked) {
        @strongify(self);
        if (isChecked) {
            [[JPKLiveURL sharedInstance] setServerType:type];
        }
        self.items = [self generateTableData];
    };
}

- (void)setCheckActionForItem:(JPKDebugCheckmarkItem *)item liveMicroType:(JPKLiveServerType)type {
    @weakify(self);
    item.checkOperation = ^(BOOL isChecked) {
        @strongify(self);
        if (isChecked) {
            [[JPKLiveURL sharedInstance] setLiveMicroServerType:type];
        }
        self.items = [self generateTableData];
    };
}

- (void)setCheckActionForItem:(JPKDebugCheckmarkItem *)item rnTabType:(JPKRNTabServerType)type {
    @weakify(self);
    item.checkOperation = ^(BOOL isChecked) {
        @strongify(self);
        if (isChecked) {
            [[JPKRNTabURL sharedInstance] setServerType:type];
        }
        self.items = [self generateTableData];
    };
}

- (void)setCheckActionForItem:(JPKDebugCheckmarkItem *)item adsType:(JPKAdsServerType)type {
    @weakify(self);
    item.checkOperation = ^(BOOL isChecked) {
        @strongify(self);
        if (isChecked) {
            [[JPKAdsURL sharedInstance] setServerType:type];
        }
        self.items = [self generateTableData];
    };
}

- (void)setCheckActionForItem:(JPKDebugCheckmarkItem *)item banxueType:(JPKBanxueServerType)type {
    @weakify(self);
    item.checkOperation = ^(BOOL isChecked) {
        @strongify(self);
        if (isChecked) {
            [[JPKBaseURL sharedInstance] setBanxueServerType:type];
        }
        self.items = [self generateTableData];
    };
}

- (void)setCheckActionForItem:(JPKDebugCheckmarkItem *)item fundType:(JPKFundServerType)type {
    @weakify(self);
    item.checkOperation = ^(BOOL isChecked) {
        @strongify(self);
        if (isChecked) {
            [[JPKFundURL sharedInstance] setServerType:type];
        }
        self.items = [self generateTableData];
    };
}

- (void)setCheckActionForItem:(JPKDebugCheckmarkItem *)item mapType:(LSKnowledgeMapWebServerType)type {
    @weakify(self);
    item.checkOperation = ^(BOOL isChecked) {
        @strongify(self);
        if (isChecked) {
            [[JPKKnowledgeMapURL sharedInstance] setServerType:type];
        }
        self.items = [self generateTableData];
    };
}

- (void)setCheckActionForItem:(JPKDebugCheckmarkItem *)item analysisType:(LSAnalysisWebServerType)type {
    @weakify(self);
    item.checkOperation = ^(BOOL isChecked) {
        @strongify(self);
        if (isChecked) {
            [[JPKAnalysisPaperWebURL sharedInstance] setServerType:type];
        }
        self.items = [self generateTableData];
    };
}

- (void)setCheckActionForItem:(JPKDebugCheckmarkItem *)item planType:(LSStudyPlanServerType)type {
    @weakify(self);
    item.checkOperation = ^(BOOL isChecked) {
        @strongify(self);
        if (isChecked) {
            [[JPKStudyPlanURL sharedInstance] setServerType:type];
        }
        self.items = [self generateTableData];
    };
}

- (void)setCheckActionForItem:(JPKDebugCheckmarkItem *)item quizType:(JPKQuizServerType)type {
    @weakify(self);
    item.checkOperation = ^(BOOL isChecked) {
        @strongify(self);
        if (isChecked) {
            [[JPKQuizURL sharedInstance] setServerType:type];
        }
        self.items = [self generateTableData];
    };
}

- (void)setCheckActionForItem:(JPKDebugCheckmarkItem *)item diagnosisType:(LSStudyDiagnosisServerType)type {
    @weakify(self);
    item.checkOperation = ^(BOOL isChecked) {
        @strongify(self);
        if (isChecked) {
            [[JPKDiagnosisURL sharedInstance] setServerType:type];
        }
        self.items = [self generateTableData];
    };
}

- (void)handleActionForCell:(XTableViewCell *)cell object:(XTableViewCellItem *)item info:(id)info {
    if ([item isKindOfClass:JPKDebugSectionTitleItem.class]) {
        JPKDebugSectionTitleItem *titleItem = (JPKDebugSectionTitleItem *)item;
        if ([titleItem.swicherTitle isEqualToString:@"needPreview"]) {
            BOOL needPreview = [info[@"value"] boolValue];
            [JPKTestModeManager sharedInstance].needRNPreview = needPreview;
            [[NSUserDefaults standardUserDefaults] setBool:needPreview forKey:kRNTabNeedPreview];
        }
        
        if ([titleItem.swicherID isEqualToString:@"SwitchToSodaTestServer"]) {
            BOOL switchTo = [info[@"value"] boolValue];
            [[NSUserDefaults standardUserDefaults] setBool:switchTo
                                                    forKey:kJPKSodaDebugMode];
        } else if (titleItem.needSwitcher && titleItem.swicherID) {
            BOOL switchTo = [info[@"value"] boolValue];
            [[NSUserDefaults standardUserDefaults] setBool:switchTo
                                                    forKey:titleItem.swicherID];
        }
        if ([titleItem.swicherID isEqualToString:@"DebugModeCloseHttpdns"]) {
            BOOL switchTo = [info[@"value"] boolValue];
            [[NSUserDefaults standardUserDefaults] setBool:switchTo
                                                    forKey:kJPKHttpDnsDebugModeClose];
        }
        
        if ([titleItem.swicherID isEqualToString:@"JPLiveLottieError"]) {
            BOOL switchTo = [info[@"value"] boolValue];
            [[NSUserDefaults standardUserDefaults] setBool:switchTo
                                                    forKey:@"JPLiveLottieError"];
        }
        
        if ([titleItem.swicherID isEqualToString:@"JPLiveLottieDownload"]) {
            BOOL switchTo = [info[@"value"] boolValue];
            [[NSUserDefaults standardUserDefaults] setBool:switchTo
                                                    forKey:@"JPLiveLottieDownload"];
        }
    }
}

- (void)alertDeepLink {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请选择打开方式"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"Safari", @"精品课APP", nil];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSURL *url = [[NSURL alloc] initWithString:kJPKDebugSettingsDeepLinkURL];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } else if (buttonIndex == 2) {
        [@"xt://webview" openWithQuery:@{@"url" : kJPKDebugSettingsDeepLinkURL}];
    }
}

#pragma mark - VC Relative
- (NSString *)title {
    return @"开发者模式";
}

- (BOOL)autoGenerateBackBarButtonItem {
    return YES;
}

@end
