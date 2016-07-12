# VFR-AutoTimecode
用于在写avisynth脚本拼接帧率不同的影视片段制作VFR视频时，通过调用一套简易的函数来收集timecode信息，以实现自动生成v1格式的timecode文件，告别人工去编写timecode文件。

详细使用说明见VFR-AutoTimecode.avsi中的注释。

**AVS File Example**

    LoadPlugin("E:\program_media\DG2044\dgindexnv\DGDecodeNV.dll")
    LoadCPlugin("E:\program_media\avisynth-plugin\yadif17\yadif.dll")
    Import("H:\fansub-work\[fansub-dev\VFR-AutoTimecode\VFR-AutoTimecode.avsi")
    
    v = DGSource("H:\fansub-work\[任务\[存档\2013.11.20 Kimamani Arinomamani\src\Kimamani Arinomamani.dgi")
    a = WavSource("H:\fansub-work\[任务\[存档\2013.11.20 Kimamani Arinomamani\src\Kimamani_Arinomamani--track02.wav").DelayAudio(0.000)
    AudioDub(v, a)
    
    tcInit()
    Trim(7451,7666).Yadif(mode=3).tcAppend() + Trim(727,1536).tcAppend()
    tcWrite()
    

**Timecode File Example**

    # timecode format v1
    # generated by Mikey's Fansub Utilities Pack - VFR-AutoTimecode 1.4 at 2016-07-08 14:19:03
    Assume 29.970030
    0,431,59.940060
    432,1241,29.970030
