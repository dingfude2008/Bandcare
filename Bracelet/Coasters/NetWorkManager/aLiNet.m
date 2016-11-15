//
//  aLiNet.m
//  aerocom
//
//  Created by 丁付德 on 15/7/9.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "aLiNet.h"

OSSClient * client;


@interface aLiNet()

@property (nonatomic, strong) NSString *        accessKey;
@property (nonatomic, strong) NSString *        secretKey;
@property (nonatomic, strong) NSString *        expiration;
@property (nonatomic, strong) NSString *        securityToken;
@property (nonatomic, strong) UIImage  *        image;
@property (nonatomic, strong) NSData   *        imageData;
@property (nonatomic, strong) NSString *        imageName;


@end


@implementation aLiNet

- (void)initOSSService
{
    DDWeak(self)
    id<OSSCredentialProvider> credential2 = [[OSSFederationCredentialProvider alloc] initWithFederationTokenGetter:^OSSFederationToken *
     {
         DDStrong(self)
         OSSFederationToken * token = [OSSFederationToken new];
         token.tAccessKey = self.accessKey;
         token.tSecretKey = self.secretKey;
         token.tToken = self.securityToken;
         token.expirationTimeInGMTFormat = self.expiration;
         return token;
     }];
    
    
    OSSClientConfiguration * conf   = [OSSClientConfiguration new];
    conf.maxRetryCount              = 1;
    conf.timeoutIntervalForRequest  = 30;
    conf.timeoutIntervalForResource = 24 * 60 * 60;
    
    client = [[OSSClient alloc] initWithEndpoint:ALIendPoint credentialProvider:credential2 clientConfiguration:conf];
}

-(void)uploadStart
{
    DDWeak(self)
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.bucketName            = BucketName;
    put.objectKey             = _imageName;
    put.uploadingData         = _imageData;
    
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        //NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    put.contentType        = @"";
    put.contentMd5         = @"";
    put.contentEncoding    = @"";
    put.contentDisposition = @"";
    
    OSSTask * putTask = [client putObject:put];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        DDStrong(self)
        [self getUrl];
        return nil;
    }];
}

-(void)getUrl
{
    NSString * publicURL = nil;
    OSSTask *  task = [client presignPublicURLWithBucketName:BucketName
                                    withObjectKey:_imageName];
    if (!task.error) {
        publicURL = task.result;
    } else {
        NSLog(@"sign url error: %@", task.error);
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.delegate upload:(BOOL)publicURL url:publicURL];
    });
}

- (void)initAndupload:(UIImage *)image dic:(NSDictionary *)dic;
{
    _accessKey = dic[@"accessKeyId"];
    _secretKey = dic[@"accessKeySecret"];
    _expiration = dic[@"expiration"];
    _securityToken = dic[@"securityToken"];
    
    CGFloat compressionRatio = 1.0;
    _imageData = UIImageJPEGRepresentation(image,compressionRatio);
    NSString *imageType = [DFD typeForImageData:_imageData];
    NSUInteger length = [_imageData length] / 1024;
    while (length > UploadBiggestKB) {
        compressionRatio /= 2.0;
        _imageData = UIImageJPEGRepresentation(image, compressionRatio);
        length = [_imageData length] / 1024;
    }
    NSString *imType    = [imageType isEqualToString:@"image/jpeg"] ? @".jpg" : @".png";
    NSTimeInterval time = [DNow timeIntervalSince1970]*1000;
    _imageName          = [NSString stringWithFormat:@"BandCare%.0f%@", time, imType];
    
    [self initOSSService];
    
    [self uploadStart];
}


@end
