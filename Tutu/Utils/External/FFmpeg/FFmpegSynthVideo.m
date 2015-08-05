//
//  FFmpegSynthVideo.m
//  Tutu
//
//  Created by zhanglingyu on 15/3/4.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "FFmpegSynthVideo.h"
#import "UIImage+Extend.h"

#define kVideoWidth 50.0

@interface FFmpegSynthVideo()

@property(nonatomic,copy) NSString *tempFile;

@property(nonatomic,strong) NSArray *arrayImage;
@property(nonatomic,assign) double rate;
@property(nonatomic,strong) NSMutableArray *arrayWidth;

@end

@implementation FFmpegSynthVideo
{
    AVFormatContext *_pFormatCtx;
}

/**
 *  图片合成视频
 */
- (void)synthImageToVideo:(NSArray *)arrayImage;
{
    _videoPath=[Tools documentsPath:@"synthVideo.mp4"];
    NSLog(@"%@",_videoPath);
    _tempFile=[Tools documentsPath:@"tempFile.jpg"];
    
    _arrayImage=arrayImage;
    int i=(int)_arrayImage.count/10;
    switch (i) {
        case 0:
            _rate=25.0/1;
            break;
        case 1:
            _rate=25.0/2;
            break;
        case 2:
            _rate=25.0/3;
            break;
        default:
            _rate=25.0/3;
            break;
    }
    
    _arrayWidth=[[NSMutableArray alloc]init];
    for (int i=0; i<_arrayImage.count; i++) {
        UIImage *image=_arrayImage[i];
        if (image.size.width<image.size.height) {
            [_arrayWidth addObject:[NSNumber numberWithDouble:image.size.width]];
        }
        else {
            [_arrayWidth addObject:[NSNumber numberWithDouble:image.size.height]];
        }
    }
    [self encoding];
}

/**
 解码
 返回值：-1:失败 0:成功
 */
-(AVFrame *)decoding
{
    AVFrame *pFrameTemp=avcodec_alloc_frame();
    
    //注册文件格式和编码
    av_register_all();
    avcodec_register_all();
    
    //打开视频文件
    if(avformat_open_input(&_pFormatCtx, [_tempFile UTF8String], NULL, NULL)!=0){
        av_log(NULL, AV_LOG_ERROR, "打开视频文件，出错！");
        goto error;
    }
    
    //取出流信息
    if(avformat_find_stream_info(_pFormatCtx, NULL)<0){
        av_log(NULL, AV_LOG_ERROR, "取出流信息，出错！");
        goto error;
    }
    
    //打印编码格式信息
    av_dump_format(_pFormatCtx, 0, [_tempFile UTF8String], 0);
    
    //查找视频流信息
    AVCodec *pCodec;
    int index_v;
    if((index_v=av_find_best_stream(_pFormatCtx, AVMEDIA_TYPE_VIDEO, -1, -1, &pCodec, 0))<0){
        av_log(NULL, AV_LOG_ERROR, "未找到视频文件流！");
        goto error;
    }
    AVCodecContext *pCodecCtx=_pFormatCtx->streams[index_v]->codec;
    
    //视频流的旋转角度
    AVStream *stream_v=_pFormatCtx->streams[index_v];
    AVDictionaryEntry *rotate_tag  = av_dict_get(stream_v->metadata, "rotate", NULL, 0);
    int rotate_v;
    if (rotate_tag!=NULL) {
        rotate_v=atoi(rotate_tag->value);
    }
    
    //查找视频流的解码器
    pCodec=avcodec_find_decoder(pCodecCtx->codec_id);
    if(pCodec==NULL){
        av_log(NULL, AV_LOG_ERROR, "未找到相应解码器！");
        goto error;
    }
    
    //打开解码器
    if(avcodec_open2(pCodecCtx, pCodec, NULL)<0){
        av_log(NULL, AV_LOG_ERROR, "未能打开解码器！");
        goto error;
    }

    //颜色编码转换成YUV420P
    struct SwsContext * sws_context = sws_getContext(pCodecCtx->width,pCodecCtx->height,pCodecCtx->pix_fmt,pCodecCtx->width,pCodecCtx->height,PIX_FMT_YUV420P,SWS_POINT,NULL,NULL,NULL);
    
    AVPacket packet;
    while(av_read_frame(_pFormatCtx, &packet)>=0)
    {
        if(packet.stream_index==index_v)
        {
            //解码
            int is_decode=0;
            AVFrame *pFrame=avcodec_alloc_frame();
            avcodec_decode_video2(pCodecCtx, pFrame, &is_decode, &packet);
            
            if (pCodecCtx->pix_fmt==PIX_FMT_YUV420P)
            {
                pFrameTemp=pFrame;
            }
            else
            {
                int size = avpicture_get_size(pCodecCtx->pix_fmt, pCodecCtx->width, pCodecCtx->height);
                uint8_t *buf_new = (uint8_t*)malloc(size);
                
                AVFrame *pFrameNEW = avcodec_alloc_frame();
                avpicture_fill((AVPicture *)pFrameNEW, buf_new, pCodecCtx->pix_fmt, pCodecCtx->width, pCodecCtx->height);
                free(buf_new);
                
                sws_scale(sws_context, pFrame->data, pFrame->linesize, 0, pCodecCtx->height, pFrameNEW->data, pFrameNEW->linesize);
                
                pFrameTemp=pFrameNEW;
            }
        }
    }
    NSLog(@"解码，完毕！");
    avformat_close_input(&_pFormatCtx);
    avformat_free_context(_pFormatCtx);
    return pFrameTemp;
    
error:
    return nil;
}

/**
 *  编码
 */
- (int)encoding
{
    avcodec_register_all();
    av_register_all();

    //查找h264编码器，CODEC_ID_H264，2
    int codec_id=2;
    AVCodec *pCodec = avcodec_find_encoder(AV_CODEC_ID_H264);
    if(!pCodec){
        fprintf(stderr, "未找到编码器！");
        return -1;
    }
    
    AVRational rate;
    rate.num = 1;
    rate.den = 25;
    
    AVCodecContext *_pCodecCtx = avcodec_alloc_context3(pCodec);
    _pCodecCtx->bit_rate = 300000;
    _pCodecCtx->width = kVideoWidth;
    _pCodecCtx->height = kVideoWidth;
    _pCodecCtx->time_base = rate;
    _pCodecCtx->gop_size = 10;
    _pCodecCtx->max_b_frames = 1;
    _pCodecCtx->thread_count = 1;
    _pCodecCtx->pix_fmt = PIX_FMT_YUV420P; //颜色编码
    
    if (codec_id == AV_CODEC_ID_H264)
        av_opt_set(_pCodecCtx->priv_data, "preset", "slow", 0);
    //打开编码器
    if(avcodec_open2(_pCodecCtx,pCodec,NULL)<0){
        printf("不能打开编码库！");
        return -1;
    }
    
    //创建视频文件
    const char *videoName=[_videoPath UTF8String];
    NSLog(@"%s",videoName);
    FILE *out_file = fopen(videoName, "wb");
    if (!out_file) {
        printf( "创建视频文件失败！");
        return -1;
    }
    
    int out_buf_size=1000000;
    uint8_t * out_buf= (uint8_t*)malloc(out_buf_size);
    
    for (int i=0;i<_arrayImage.count*_rate;++i)
    {
        AVPacket pkt;
        av_init_packet(&pkt);
        pkt.data = out_buf;
        pkt.size = out_buf_size;

        //图片解码
        int index=i/_rate;
        NSNumber *width=_arrayWidth[index];
        double scale=kVideoWidth/[width doubleValue];
        UIImage *image=[UIImage scaleImage:_arrayImage[index] toScale:scale];
        int result = [UIImageJPEGRepresentation(image,1.0) writeToFile: _tempFile atomically:YES];
        if (!result) {
            continue;
        }
        AVFrame *pFrame = [self decoding];
        pFrame->format=_pCodecCtx->pix_fmt;
        pFrame->pts=i;
        int is_encode=0;
        int flag = avcodec_encode_video2(_pCodecCtx, &pkt, pFrame, &is_encode);
        if (flag == 0){
            
            fwrite(pkt.data, 1, pkt.size, out_file);
        }
        av_free_packet(&pkt);
    }
    
    //释放资源
    fclose(out_file);
    free(out_buf);
    avcodec_close(_pCodecCtx);
    av_free(_pCodecCtx);
    
    NSLog(@"合并视频，完毕！");
    return 0;
}

@end
