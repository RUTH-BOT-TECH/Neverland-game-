"""Create the original decorative Eldorian banner. Requires Pillow, only for regeneration."""
from PIL import Image, ImageDraw
import random, math
random.seed(55)
w,h=512,768
im=Image.new('RGBA',(w,h)); d=ImageDraw.Draw(im)
shape=[(16,12),(496,12),(496,610),(256,750),(16,610)]
d.polygon(shape,fill=(24,57,83,255))
for y in range(23,615,3):
 c=3 if (y//3)%4 else 8
 d.line((26,y,486,y),fill=(29+c,62+c,88+c,255),width=1)
d.line(shape+[shape[0]],fill=(214,171,85,255),width=13,joint='curve')
d.line([(39,36),(473,36),(473,595),(256,718),(39,595),(39,36)],fill=(199,150,71,255),width=4,joint='curve')
# Five empty settings: a quiet reminder that the Orbs are missing.
for angle in [-90,-18,54,126,198]:
 r=154;x=256+math.cos(math.radians(angle))*r;y=316+math.sin(math.radians(angle))*r
 box=(x-38,y-38,x+38,y+38);d.ellipse(box,outline=(222,184,100,255),width=8);d.ellipse((x-26,y-26,x+26,y+26),outline=(128,145,151,255),width=3)
d.ellipse((204,264,308,368),outline=(222,184,100,255),width=7)
d.polygon([(256,269),(268,302),(302,316),(268,329),(256,363),(244,329),(210,316),(244,302)],fill=(223,187,108,255))
for y in [525,548]: d.line((120,y,392,y),fill=(207,167,91,255),width=4)
im.save('assets/textures/eldoria/royal_banner.png',optimize=True)
