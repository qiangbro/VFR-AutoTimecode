Import("H:\fansub-work\[fansub-dev\VFR-AutoTimecode\VFR-AutoTimecode.avsi")

LoadPlugin("E:\program_media\DGDecNV2049\DGDecodeNV.dll")
LoadPlugin("E:\program_media\avisynth-plugin\ffms2-2.22-msvc\x86\ffms2.dll")
#~ LoadPlugin("E:\program_media\avisynth-plugin\LSMASHSource-AviSynth-plugin-r879-msvc-32bit\LSMASHSource.dll")
LoadPlugin("E:\program_media\xiaowan_rev190\tools\avsfilter\TIVTC.dll")
LoadCPlugin("E:\program_media\avisynth-plugin\yadif17\yadif.dll")
#~ LoadPlugin("E:\program_media\avisynth-plugin\NNEDI3_v0_9_4_22\x86\Release_W7\nnedi3.dll")
#~ LoadPlugin("E:\program_media\avisynth-plugin\mvtools2-2.7.0.22\Win32\mvtools2.dll")
#~ LoadPlugin("E:\program_media\avisynth-plugin\masktools\masktools2-b1-x86.dll")
#~ LoadPlugin("E:\program_media\xiaowan_rev190\tools\avsfilter\RemoveGrain.dll")
#~ LoadPlugin("E:\program_media\xiaowan_rev190\tools\avsfilter\FFT3DFilter.dll")
#~ LoadPlugin("E:\program_media\xiaowan_rev190\tools\avsfilter\FFT3dGPU.dll")
#~ Import("E:\program_media\avisynth-plugin\QTGMC-3.33.avsi")
#~ LoadPlugin("E:\program_media\avisynth-plugin\delogo\delogo_avisynth_005a\delogo.dll")
#~ Import("E:\program_media\avisynth-plugin\logoNR_v0.1.avsi")
#~ Import("E:\program_media\[A.K.] Mikey's Fansub Utilities Pack\avisynth_plugin\DelogoFunction\delogo.avsi")
#~ LoadPlugin("E:\program_media\avisynth-plugin\VSFilter-2.41.322_x86.dll")
#~ Import("E:\program_media\[A.K.] Mikey's Fansub Utilities Pack\avisynth_plugin\SSOverlay-1.1.3.avsi")
Import("E:\program_media\Mikey's Fansub Utilities\avisynth_plugin\MtModes.avsi")

global MeGUI_darx = 16 global MeGUI_dary = 9

v = DGSource("H:\fansub-work\[任务\[存档\2013.11.20 Kimamani Arinomamani\src\Kimamani Arinomamani.dgi")
a = WavSource("H:\fansub-work\[任务\[存档\2013.11.20 Kimamani Arinomamani\src\Kimamani_Arinomamani--track02.wav").DelayAudio(0.000)
AudioDub(v, a)

#~ Trim(7451,7666) ++ Trim(727,1536)

#~ Trim(7451,7666).Yadif(mode=3).AssumeFPS("ntsc_video") + Trim(727,1536).AssumeFPS("ntsc_video")


tcInit(default_fps="ntsc_video", auto_assume_fps=true)

Trim(7451,7666).Yadif(mode=3).tcAppend() + Trim(727,1536).tcAppend()

tcWrite()


#~ LanczosResize(960, 540)
Spline36Resize(1280, 720)
#~ Spline36Resize(1440, 810)
#~ BlackmanResize(1920, 1080)

Prefetch(8)

