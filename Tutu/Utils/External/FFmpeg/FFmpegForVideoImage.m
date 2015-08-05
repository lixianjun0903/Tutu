//
//  FFmpegForVideoImage.m
//  Tutu
//
//  Created by zhangxinyao on 15-3-24.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "FFmpegForVideoImage.h"

@implementation FFmpegForVideoImage

-(void)findVideoImages:(NSURL *)videoURL number:(int)num width:(float)maxWidth progress:(FindVideoImage)block{

    AVFormatContext *pFormatCtx;
    int i, videoIndex;
    AVCodecContext *pCodecCtx = NULL;
    AVCodec *pCodec = NULL;
    
    AVPacket packet;
    int frameFinished;
    int numBytes;
    uint8_t *buffer;
    
    //char* filename = "nihao.avi";
    const char* filename = [videoURL.absoluteString cStringUsingEncoding:NSASCIIStringEncoding];
    pFormatCtx = avformat_alloc_context();
    av_register_all();
    if (avformat_open_input(&pFormatCtx, filename, NULL, 0) != 0)
        return ;
    if (avformat_find_stream_info(pFormatCtx, NULL) < 0)
        return ;
    av_dump_format(pFormatCtx, 0, filename, 0);
    
    videoIndex = -1;
    for (i = 0; i < pFormatCtx->nb_streams; ++i){
        if (pFormatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO){
            videoIndex = i;
            break;
        }
    }
    if (videoIndex == -1)
    {
        fprintf(stderr, "unsupport codec\n");
        return ;
    }
    pCodecCtx = pFormatCtx->streams[videoIndex]->codec;
    pCodec = avcodec_find_decoder(pCodecCtx->codec_id);
    if (avcodec_open2(pCodecCtx, pCodec, NULL) < 0)
        return ;
    
    AVFrame *pFrameRGB, *pFrame;
    pFrame = av_frame_alloc();
    pFrameRGB = av_frame_alloc();
    if (pFrame == NULL)
        return ;
    
    numBytes = avpicture_get_size(PIX_FMT_RGB24, pCodecCtx->width, pCodecCtx->height);
    buffer = (uint8_t *)av_malloc(numBytes * sizeof(uint8_t));
    
    avpicture_fill((AVPicture*)pFrameRGB, buffer, PIX_FMT_RGB24, pCodecCtx->width, pCodecCtx->height);
    
    i = 0;
    struct SwsContext* img_convert_ctx;
    img_convert_ctx = sws_getContext(pCodecCtx->width, pCodecCtx->height, pCodecCtx->pix_fmt,
                                     pCodecCtx->width, pCodecCtx->height, PIX_FMT_RGB24, SWS_BICUBIC, NULL, NULL, NULL);
    
    while (av_read_frame(pFormatCtx, &packet) >= 0){
        if (packet.stream_index == videoIndex){
            avcodec_decode_video2(pCodecCtx, pFrame, &frameFinished, &packet);
            
            if (frameFinished)
            {
                sws_scale(img_convert_ctx, pFrame->data, pFrame->linesize, 0, pCodecCtx->height,
                          pFrameRGB->data, pFrameRGB->linesize);
                
                if (++i <= 100){
                    [self imageFromAVPicture:pFrameRGB width:640 height:640 progress:block];
//                    [self savePPMPicture:pFrameRGB width:640 height:640 index:i];
//                    saveFrame(pFrameRGB, pCodecCtx->width, pCodecCtx->height, i);
                }
            }
        }
        av_free_packet(&packet);
    }
    
    av_free(buffer);
    av_free(pFrameRGB);
    av_free(pFrame);
    avcodec_close(pCodecCtx);
}



-(UIImage *)imageFromAVPicture:(AVFrame *)pict width:(int)width height:(int)height progress:(FindVideoImage ) block{
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, pict->data[0], pict->linesize[0]*height,kCFAllocatorNull);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width,
                                       height,
                                       8,
                                       24,
                                       pict->linesize[0],
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CFRelease(data);
    
//    block([image ]);
    
    return image;
}

-(void)savePPMPicture:(AVPicture *)pict width:(int)width height:(int)height index:(int)iFrame {
    FILE *pFile;
    NSString *fileName;
    int  y;
    
    fileName = getDocumentsFilePath([NSString stringWithFormat:@"image%04d.jpg",iFrame]);
    // Open file
    NSLog(@"write image file: %@",fileName);
    pFile=fopen([fileName cStringUsingEncoding:NSASCIIStringEncoding], "wb");
    if(pFile==NULL)
        return;
    
    // Write header
    fprintf(pFile, "P6\n%d %d\n255\n", width, height);
    
    // Write pixel data
    for(y=0; y<height; y++)
        fwrite(pict->data[0]+y*pict->linesize[0], 1, width*3, pFile);
    
    // Close file
    fclose(pFile);
}

@end
