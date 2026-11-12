"""Downsize embedded PNG/JPEG images in a GLB to at most 1024px.

Usage: python3 tools/optimize_glb_textures.py input.glb output.glb
Requires Pillow. Original non-image binary data and animation tracks are copied.
"""
import io
import json
import struct
import sys
from PIL import Image

src, dst = sys.argv[1:3]
data = open(src, 'rb').read()
magic, version, length = struct.unpack_from('<4sII', data)
if magic != b'glTF' or version != 2 or length != len(data):
    raise ValueError('Expected a valid GLB 2.0 file')
json_len, json_type = struct.unpack_from('<II', data, 12)
if json_type != 0x4E4F534A:
    raise ValueError('Expected GLB JSON chunk')
meta = json.loads(data[20:20 + json_len])
chunk_offset = 20 + json_len
bin_len, bin_type = struct.unpack_from('<II', data, chunk_offset)
if bin_type != 0x004E4942 or chunk_offset + 8 + bin_len != len(data):
    raise ValueError('Expected exactly one GLB binary chunk')
if len(meta.get('buffers', [])) != 1 or meta.get('extensionsUsed'):
    raise ValueError('Only single-buffer, extension-free GLBs are supported')
binary = data[chunk_offset + 8:]
image_views = {i['bufferView']: i for i in meta.get('images', [])}
if len(image_views) != len(meta.get('images', [])):
    raise ValueError('Expected a unique bufferView per embedded image')
if image_views.keys() & {a.get('bufferView') for a in meta.get('accessors', [])}:
    raise ValueError('Image buffer views must not contain mesh or animation data')
output = bytearray()
for idx, view in enumerate(meta['bufferViews']):
    if view.get('buffer', 0) != 0:
        raise ValueError('Buffer view references an unsupported buffer')
    start = view.get('byteOffset', 0)
    raw = binary[start:start + view['byteLength']]
    if len(raw) != view['byteLength']:
        raise ValueError('Truncated buffer view')
    if idx in image_views:
        image = Image.open(io.BytesIO(raw))
        if max(image.size) > 1024:
            image.thumbnail((1024, 1024), Image.Resampling.LANCZOS)
            b = io.BytesIO()
            mime = image_views[idx].get('mimeType')
            if mime == 'image/jpeg':
                image.convert('RGB').save(b, format='JPEG', quality=90, optimize=True)
            elif mime == 'image/png':
                image.save(b, format='PNG', optimize=True)
            else:
                raise ValueError('Unsupported embedded image type')
            raw = b.getvalue()
    while len(output) % 4:
        output.append(0)
    view['byteOffset'] = len(output)
    view['byteLength'] = len(raw)
    output.extend(raw)
meta['buffers'][0]['byteLength'] = len(output)
while len(output) % 4:
    output.append(0)
new_json = json.dumps(meta, separators=(',', ':'), ensure_ascii=False).encode('utf-8')
new_json += b' ' * ((-len(new_json)) % 4)
body = struct.pack('<II', len(new_json), 0x4E4F534A) + new_json + struct.pack('<II', len(output), 0x004E4942) + output
with open(dst, 'wb') as f:
    f.write(struct.pack('<4sII', b'glTF', 2, 12 + len(body)) + body)
print('Optimized embedded textures:', len(data), '->', 12 + len(body), 'bytes')
