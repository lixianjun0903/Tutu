//
//  FFmpegSynthAudio.m
//  Tutu
//
//  Created by zhanglingyu on 15/3/23.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "FFmpegSynthAudio.h"

@implementation FFmpegSynthAudio

+ (NSString *)getExportVideoTempPath
{
    NSString *videoName=[NSString stringWithFormat:@"megraudio%@.mp4",
                         dateTransformStringAsYMDByFormate([NSDate new],
                                                           @"yyyyMMddhhmmss")];
    return [NSString stringWithFormat:@"%@%@",getTempVideoPath(),videoName];
}

/**
 *  图片合成音频
 */
+ (void)synthAudio:(NSString *) audioPath withVideo:(NSString *) videoPath withBlock:(SuccessBlock) successBlock
{
    //输入对应一个AVFormatContext，输出对应一个AVFormatContext
    AVFormatContext *ifmt_ctx_v = NULL, *ifmt_ctx_a = NULL,*ofmt_ctx = NULL;
    AVOutputFormat *ofmt = NULL;
    AVPacket pkt;
    int ret, i;
    int videoindex_v=-1,videoindex_out=-1;
    int audioindex_a=-1,audioindex_out=-1;
    int frame_index=0;
    
    //输入文件名
    const char *in_filename_v = [videoPath cStringUsingEncoding:NSASCIIStringEncoding];
    const char *in_filename_a = [audioPath cStringUsingEncoding:NSASCIIStringEncoding];
    
    //输出文件名
    NSString *exportPath =[self getExportVideoTempPath];
    if([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    const char *out_filename = [exportPath cStringUsingEncoding:NSASCIIStringEncoding];
    
    av_register_all();
    
    //输入视频
    if ((ret = avformat_open_input(&ifmt_ctx_v, in_filename_v, 0, 0)) < 0) {
        printf( "打开视频文件，失败！");
        goto end;
    }
    if ((ret = avformat_find_stream_info(ifmt_ctx_v, 0)) < 0) {
        printf( "取视频流信息，失败！");
        goto end;
    }
    av_dump_format(ifmt_ctx_v, 0, in_filename_v, 0);
    
    //输入音频
    if ((ret = avformat_open_input(&ifmt_ctx_a, in_filename_a, 0, 0)) < 0) {
        printf( "打开音频文件，失败！");
        goto end;
    }
    if ((ret = avformat_find_stream_info(ifmt_ctx_a, 0)) < 0) {
        printf( "取音频流信息，失败！");
        goto end;
    }
    printf("输入文件信息:\n");
    printf("视频:\n");
    av_dump_format(ifmt_ctx_v, 0, in_filename_v, 0);
    printf("音频:\n");
    av_dump_format(ifmt_ctx_a, 0, in_filename_a, 0);
    
    //初始化输出文件
    avformat_alloc_output_context2(&ofmt_ctx, NULL, NULL, out_filename);
    if (!ofmt_ctx) {
        printf( "创建输出文件，失败！\n");
        ret = AVERROR_UNKNOWN;
        goto end;
    }
    ofmt = ofmt_ctx->oformat;
    //视频
    for (i = 0; i < ifmt_ctx_v->nb_streams; i++) {
        //根据输入流创建输出流
        if(ifmt_ctx_v->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO){
            AVStream *in_stream = ifmt_ctx_v->streams[i];
            AVStream *out_stream = avformat_new_stream(ofmt_ctx, in_stream->codec->codec);
            
            //*设置旋转角度*
            AVDictionaryEntry *rotate_tag = av_dict_get(in_stream->metadata, "rotate", NULL, 0);
            if (rotate_tag!=NULL) {
                av_dict_set(&out_stream->metadata, "rotate", rotate_tag->value, 0);
            }
            
            videoindex_v=i;
            if (!out_stream) {
                printf( "创建输出流，失败！\n");
                ret = AVERROR_UNKNOWN;
                goto end;
            }
            videoindex_out=out_stream->index;
            //复制AVCodecContext的设置
            if (avcodec_copy_context(out_stream->codec, in_stream->codec) < 0) {
                printf( "复制AVCodecContext的设置，失败！\n");
                goto end;
            }
            out_stream->codec->codec_tag = 0;
            if (ofmt_ctx->oformat->flags & AVFMT_GLOBALHEADER)
                out_stream->codec->flags |= CODEC_FLAG_GLOBAL_HEADER;
            break;
        }
    }
    //音频
    for (i = 0; i < ifmt_ctx_a->nb_streams; i++) {
        //根据输入流创建输出流
        if(ifmt_ctx_a->streams[i]->codec->codec_type==AVMEDIA_TYPE_AUDIO){
            AVStream *in_stream = ifmt_ctx_a->streams[i];
            AVStream *out_stream = avformat_new_stream(ofmt_ctx, in_stream->codec->codec);
            audioindex_a=i;
            if (!out_stream) {
                printf( "创建输出流，失败！\n");
                ret = AVERROR_UNKNOWN;
                goto end;
            }
            audioindex_out=out_stream->index;
            //复制AVCodecContext的设置
            if (avcodec_copy_context(out_stream->codec, in_stream->codec) < 0) {
                printf( "复制AVCodecContext的设置，失败！\n");
                goto end;
            }
            out_stream->codec->codec_tag = 0;
            if (ofmt_ctx->oformat->flags & AVFMT_GLOBALHEADER)
                out_stream->codec->flags |= CODEC_FLAG_GLOBAL_HEADER;
            
            break;
        }
    }
    printf("\n输出文件信息:\n");
    av_dump_format(ofmt_ctx, 0, out_filename, 1);
    //打开输出文件
    if (!(ofmt->flags & AVFMT_NOFILE)) {
        if (avio_open(&ofmt_ctx->pb, out_filename, AVIO_FLAG_WRITE) < 0) {
            printf( "打开输出文件:'%s'，失败！\n", out_filename);
            goto end;
        }
    }
    //写入文件头
    if (avformat_write_header(ofmt_ctx, NULL) < 0) {
        printf( "写入文件头，失败！\n");
        goto end;
    }
    
    AVStream *st_v=ifmt_ctx_v->streams[videoindex_v];
    double duration_v=st_v->duration * av_q2d(st_v->time_base);
    if (duration_v<3) {
        duration_v=3;
    }
    NSLog(@"duration_v:%f",duration_v);
    while(av_read_frame(ifmt_ctx_v, &pkt) >= 0) {
        AVStream *in_stream = ifmt_ctx_v->streams[pkt.stream_index];
        AVStream *out_stream = ofmt_ctx->streams[videoindex_out];
        if(pkt.stream_index==videoindex_v){
            double time_v= pkt.pts * av_q2d(st_v->time_base);
            NSLog(@"time_in_v:%f",time_v);
            
            if(pkt.pts==AV_NOPTS_VALUE){
                AVRational time_base1=in_stream->time_base;
                int64_t calc_duration=(double)AV_TIME_BASE/av_q2d(in_stream->r_frame_rate);
                pkt.pts=(double)(frame_index*calc_duration)/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                pkt.dts=pkt.pts;
                pkt.duration=(double)calc_duration/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                frame_index++;
            }
            
            //转换PTS/DTS（Convert PTS/DTS）
            pkt.pts = av_rescale_q_rnd(pkt.pts, in_stream->time_base, out_stream->time_base, (AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
            pkt.dts = av_rescale_q_rnd(pkt.dts, in_stream->time_base, out_stream->time_base, (AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
            pkt.duration = (double)av_rescale_q(pkt.duration, in_stream->time_base, out_stream->time_base);
            pkt.pos = -1;
            pkt.stream_index=videoindex_out;
            
            double time_out_v= pkt.pts * av_q2d(out_stream->time_base);
            NSLog(@"time_out_v:%f",time_out_v);
   
            //写入一个AVPacket到输出文件
            if (av_interleaved_write_frame(ofmt_ctx, &pkt) < 0) {
                printf( "Error muxing packet\n");
                continue;
            }
            av_free_packet(&pkt);
        }
    }
    
    AVStream *st_a=ifmt_ctx_a->streams[audioindex_a];
    double duration_a=st_a->duration * av_q2d(st_a->time_base);
    NSLog(@"duration_a:%f",duration_a);
    for (int i=0; duration_a*i<duration_v; i++) {
        //指向开始播放时间
        [self seekTime: ifmt_ctx_a type:AVMEDIA_TYPE_AUDIO begin:0.0];
        while(av_read_frame(ifmt_ctx_a, &pkt) >= 0) {
            AVStream *in_stream = ifmt_ctx_a->streams[pkt.stream_index];
            AVStream *out_stream = ofmt_ctx->streams[audioindex_out];
            if(pkt.stream_index==audioindex_a){
                double time_a= pkt.pts * av_q2d(st_a->time_base);
                NSLog(@"time_a:%f",duration_a*i);
                if (duration_a*i+time_a>duration_v) {
                    break;
                }
                
                if(pkt.pts==AV_NOPTS_VALUE){
                    AVRational time_base1=in_stream->time_base;
                    int64_t calc_duration=(double)AV_TIME_BASE/av_q2d(in_stream->r_frame_rate);
                    pkt.pts=(double)(frame_index*calc_duration)/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                    pkt.dts=pkt.pts;
                    pkt.duration=(double)calc_duration/(double)(av_q2d(time_base1)*AV_TIME_BASE);
                    frame_index++;
                }
                
                //转换PTS/DTS（Convert PTS/DTS）
                pkt.pts = av_rescale_q_rnd(pkt.pts, in_stream->time_base, out_stream->time_base, (AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
                pkt.dts = av_rescale_q_rnd(pkt.dts, in_stream->time_base, out_stream->time_base, (AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
                pkt.duration = (double)av_rescale_q(pkt.duration, in_stream->time_base, out_stream->time_base);
                pkt.pos = -1;
                pkt.stream_index=audioindex_out;
                
                //修改播放时间
                pkt.pts=pkt.pts+out_stream->time_base.den*duration_a*i;
                pkt.dts=pkt.dts+out_stream->time_base.den*duration_a*i;
                double time_out_a= pkt.pts * av_q2d(out_stream->time_base);
                NSLog(@"time_out_a:%f",time_out_a);
                
                //写入一个AVPacket到输出文件
                if (av_interleaved_write_frame(ofmt_ctx, &pkt) < 0) {
                    printf( "Error muxing packet\n");
                    continue;
                }
                av_free_packet(&pkt);
            }
        }
    }
    
    //写入文件尾
    av_write_trailer(ofmt_ctx);
    successBlock(exportPath);
    printf("合成音频，完毕！\n");
    
end:
    avformat_close_input(&ifmt_ctx_v);
    avformat_close_input(&ifmt_ctx_a);
    /* close output */
    if (ofmt_ctx && !(ofmt->flags & AVFMT_NOFILE))
        avio_close(ofmt_ctx->pb);
        avformat_free_context(ofmt_ctx);
        if (ret < 0 && ret != AVERROR_EOF) {
            printf( "Error occurred.\n");
            return;
        }
    return;
}

@end
