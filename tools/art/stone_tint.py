#!/usr/bin/env python3
"""Recolours a PixelLab frame to pale lilac shrine stone, keeping its gold (art loop batch 4).

The Spire Sentinel's base came out as steel plate; its clips start from this recoloured frame:
  python3 tools/art/stone_tint.py art/pixellab/enemies/spire_sentinel/base2/south-east.png \
      art/pixellab/enemies/spire_sentinel/base/guard.png
"""
import colorsys
import sys

from PIL import Image

src,dst=sys.argv[1:3]
im=Image.open(src).convert('RGBA'); px=im.load()
ramp=[(0.0,(0x24,0x1e,0x30)),(0.25,(0x5e,0x56,0x74)),(0.5,(0x9a,0x93,0xb0)),(0.75,(0xc9,0xc4,0xd8)),(1.0,(0xec,0xe8,0xf2))]
def lerp(a,b,t): return tuple(round(a[i]+(b[i]-a[i])*t) for i in range(3))
def ramp_at(v):
    for (t0,c0),(t1,c1) in zip(ramp,ramp[1:]):
        if v<=t1: return lerp(c0,c1,(v-t0)/(t1-t0))
    return ramp[-1][1]
for y in range(im.height):
    for x in range(im.width):
        r,g,b,a=px[x,y]
        if a==0: continue
        h,s,v=colorsys.rgb_to_hsv(r/255,g/255,b/255)
        if s>0.45 and 0.08<h<0.17 and v>0.45: continue   # gold glyph and trim stay
        l=(0.3*r+0.59*g+0.11*b)/255
        if l<0.09: px[x,y]=(*ramp[0][1],a); continue   # outline stays dark
        l=0.18+0.82*min(1,l*1.25)   # lift: pale stone
        px[x,y]=(*ramp_at(l),a)
im.save(dst)
