LoadPlugin("E:\program_media\DG2044\dgindexnv\DGDecodeNV.dll")
LoadCPlugin("E:\program_media\avisynth-plugin\yadif17\yadif.dll")
Import("H:\fansub-work\[fansub-dev\VFR-AutoTimecode\VFR-AutoTimecode.avsi")

global MeGUI_darx = 16
global MeGUI_dary = 9

v = DGSource("H:\fansub-work\[任务\[存档\2013.11.20 Kimamani Arinomamani\src\Kimamani Arinomamani.dgi")
a = WavSource("H:\fansub-work\[任务\[存档\2013.11.20 Kimamani Arinomamani\src\Kimamani_Arinomamani--track02.wav").DelayAudio(0.000)
AudioDub(v, a)


#~ Trim(7451,7666) ++ Trim(727,1536)

#~ Trim(7451,7666).Yadif(mode=3).AssumeFPS("ntsc_video") + Trim(727,1536).AssumeFPS("ntsc_video")


tcInit(default_fps="ntsc_video", auto_assume_fps=true)

Trim(7451,7666).Yadif(mode=3).tcAppend() + Trim(727,1536).tcAppend()

tcWrite()


#~ LanczosResize(960, 540)
#~ Spline36Resize(1280, 720)
#~ Spline36Resize(1440, 810)
#~ BlackmanResize(1920, 1080)



