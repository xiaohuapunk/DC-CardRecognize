//
//  DCCardDetectModule.m
//  DCCardDetect
//
//  Created by XHY on 2019/1/24.
//  Copyright © 2019 DCloud. All rights reserved.
//

#import "DCCardDetectModule.h"
#import <AipOcrSdk/AipOcrSdk.h>

@implementation DCCardDetectModule
{
    // 默认的识别成功的回调
    void (^_successHandler)(id);
    // 默认的识别失败的回调
    void (^_failHandler)(NSError *);
    
    WXModuleKeepAliveCallback _callback;
    
    NSString *_maskType;
}

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(startRecognize::))

- (instancetype)init {
    if (self = [super init]) {
        [self configureData];
    }
    return self;
}

- (NSDictionary *)parseNodeWithInfo:(NSDictionary *)info nodeKeys:(NSArray *)nodeKeys retKeys:(NSArray *)retKeys {
    NSMutableDictionary *retDic = [NSMutableDictionary dictionary];
    
    [nodeKeys enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (info[obj]) {
            NSDictionary *node = info[obj];
            [retDic setValue:node[@"words"] ?: @"" forKey:retKeys[idx]];
        }
    }];
    
    return retDic;
}

- (void)parseResult:(NSDictionary *)ocrResult {
    
    __weak __typeof(self)weakSelf = self;
    
    if (!ocrResult) {
        if (_callback) {
            _callback([NSNull null],NO);
        }
        return;
    }
    
    
    id ret = [NSNull null];
    // 身份证正面
    if ([_maskType isEqualToString:@"IDCardFront"]) {
        NSDictionary *words = ocrResult[@"words_result"];
        ret = [self parseNodeWithInfo:words
                             nodeKeys:@[@"姓名",@"出生",@"公民身份号码",@"性别",@"住址",@"民族"]
                              retKeys:@[@"name",@"birthday",@"idNumber",@"gender",@"address",@"ethnic"]];
    }
    // 身份证背面
    else if ([_maskType isEqualToString:@"IDCardBack"]) {
        NSDictionary *words = ocrResult[@"words_result"];
        ret = [self parseNodeWithInfo:words
                             nodeKeys:@[@"失效日期",@"签发日期",@"签发机关"]
                              retKeys:@[@"expiryDate",@"signDate",@"issueAuthority"]];
    }
    // 银行卡
    else if ([_maskType isEqualToString:@"BankCard"]) {
        ret = ocrResult[@"result"];
    }
    // 车牌
    else if ([_maskType isEqualToString:@"LicensePlate"]) {
        NSDictionary *info = ocrResult[@"words_result"];
        ret = @{
                @"color": info[@"color"] ?: @"",
                @"number": info[@"number"] ?: @""
                };
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_callback) {
            self->_callback(ret,NO);
        }
        [[weakSelf findVisibleVC] dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)configureData {
    
    NSString *licenseFile = [[NSBundle mainBundle] pathForResource:@"aip" ofType:@"license"];
    NSData *licenseFileData = [NSData dataWithContentsOfFile:licenseFile];
    if(!licenseFileData) {
        [[[UIAlertView alloc] initWithTitle:@"授权失败" message:@"百度OCR授权文件不存在" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }
    [[AipOcrService shardService] authWithLicenseFileData:licenseFileData];
    
    __weak typeof(self) weakSelf = self;
    
    // 这是默认的识别成功的回调
    _successHandler = ^(id result){
        [weakSelf parseResult:result];
    };
    
    // 失败回调
    _failHandler = ^(NSError *error){
        NSLog(@"%@", error);
        NSString *msg = [NSString stringWithFormat:@"%li:%@", (long)[error code], [error localizedDescription]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[weakSelf findVisibleVC] dismissViewControllerAnimated:YES completion:nil];
            [[[UIAlertView alloc] initWithTitle:@"识别失败" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        });
    };
}

- (UIViewController *)findVisibleVC {
    UIViewController *visibleVc = nil;
    UIWindow *visibleWindow = nil;
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
        if (!window.hidden && !visibleWindow) {
            visibleWindow = window;
        }
        if ([UIWindow instancesRespondToSelector:@selector(rootViewController)]) {
            if ([window rootViewController]) {
                visibleVc = window.rootViewController;
                break;
            }
        }
    }
    
    return visibleVc ?: [[UIApplication sharedApplication].delegate window].rootViewController;
}


#pragma mark - OCR Method

/** 身份证正面 */
- (void)idcardOCROnlineFront {
    
    UIViewController * vc =
    [AipCaptureCardVC ViewControllerWithCardType:CardTypeIdCardFont
                                 andImageHandler:^(UIImage *image) {
                                     
                                     [[AipOcrService shardService] detectIdCardFrontFromImage:image
                                                                                  withOptions:nil
                                                                               successHandler:self->_successHandler
                                                                                  failHandler:self->_failHandler];
                                 }];
    
    [[self findVisibleVC] presentViewController:vc animated:YES completion:nil];
}

/** 身份证反面 */
- (void)idcardOCROnlineBack {
    
    UIViewController * vc =
    [AipCaptureCardVC ViewControllerWithCardType:CardTypeIdCardBack
                                 andImageHandler:^(UIImage *image) {
                                     
                                     [[AipOcrService shardService] detectIdCardBackFromImage:image
                                                                                 withOptions:nil
                                                                              successHandler:self->_successHandler
                                                                                 failHandler:self->_failHandler];
                                 }];
    [[self findVisibleVC] presentViewController:vc animated:YES completion:nil];
}

/** 银行卡正面 */
- (void)bankCardOCROnline {
    
    UIViewController * vc =
    [AipCaptureCardVC ViewControllerWithCardType:CardTypeBankCard
                                 andImageHandler:^(UIImage *image) {
                                     
                                     [[AipOcrService shardService] detectBankCardFromImage:image
                                                                            successHandler:self->_successHandler
                                                                               failHandler:self->_failHandler];
                                     
                                 }];
    [[self findVisibleVC] presentViewController:vc animated:YES completion:nil];
    
}

/** 车牌识别 */
- (void)plateLicenseOCR {
    
    UIViewController * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
        
        [[AipOcrService shardService] detectPlateNumberFromImage:image
                                                     withOptions:nil
                                                  successHandler:self->_successHandler
                                                     failHandler:self->_failHandler];
        
    }];
    [[self findVisibleVC] presentViewController:vc animated:YES completion:nil];
}

#pragma mark -

- (void)startRecognize:(NSDictionary *)options :(WXModuleKeepAliveCallback)callback {
    _maskType = options[@"maskType"];
    if (!_maskType) {
        if (callback) {
            callback([NSNull null],NO);
        }
        return;
    }
    
    _callback = callback;
    
    NSDictionary *actionMap = @{
                                @"IDCardFront": @"idcardOCROnlineFront",
                                @"IDCardBack": @"idcardOCROnlineBack",
                                @"BankCard": @"bankCardOCROnline",
                                @"LicensePlate": @"plateLicenseOCR"
                                };
    
    SEL funSel = NSSelectorFromString(actionMap[_maskType]);
    if (funSel) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:funSel];
#pragma clang diagnostic pop
    } else {
        WXLogError(@"maskType Error: %@",_maskType);
    }
}

@end
