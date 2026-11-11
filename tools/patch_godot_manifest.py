#!/usr/bin/env python3
"""Work around Godot 4.6.3 non-Gradle exporter rewriting two provider authorities
into the same string. Input/output are APKs; output must then be zipaligned and
signed. This performs only an equal-length string-pool change, preserving AXML.
"""
import struct, sys, zipfile, shutil

source, output = sys.argv[1:3]
with zipfile.ZipFile(source, 'r') as zin:
    manifest = bytearray(zin.read('AndroidManifest.xml'))
    typ, header_size, _ = struct.unpack_from('<HHI', manifest, 8)
    assert typ == 1
    count, _, flags, string_start, _ = struct.unpack_from('<IIIII', manifest, 16)
    assert flags & 0x100 == 0, 'This patch currently expects UTF-16 AXML strings.'
    offsets = struct.unpack_from('<' + 'I' * count, manifest, 8 + header_size)
    strings, locations = [], []
    for offset in offsets:
        pos = 8 + string_start + offset
        length = struct.unpack_from('<H', manifest, pos)[0]
        assert length < 0x8000
        pos += 2
        strings.append(bytes(manifest[pos:pos+length*2]).decode('utf-16le'))
        locations.append((pos, length))
    p = 8
    found = {}
    while p < len(manifest):
        chunk_type, _, size = struct.unpack_from('<HHI', manifest, p)
        assert size >= 8
        if chunk_type == 0x102:
            _, tag, attr_start, attr_size, attr_count, _, _, _ = struct.unpack_from('<IIHHHHHH', manifest, p+16)
            if strings[tag] == 'provider':
                attrs = {}
                for i in range(attr_count):
                    q = p + 16 + attr_start + i * attr_size
                    _, name_idx, raw, _ = struct.unpack_from('<IIII', manifest, q)
                    data = struct.unpack_from('<I', manifest, q+16)[0]
                    idx = raw if raw != 0xffffffff else data
                    attrs[strings[name_idx]] = idx
                if 'name' in attrs and 'authorities' in attrs:
                    found[strings[attrs['name']]] = attrs['authorities']
        p += size
    init_idx = found['androidx.startup.InitializationProvider']
    file_idx = found['androidx.core.content.FileProvider']
    assert init_idx != file_idx and strings[init_idx] == strings[file_idx]
    original = strings[init_idx]
    assert original.endswith('.fileprovider')
    replacement = original[:-len('.fileprovider')] + '.initprovider'
    encoded = replacement.encode('utf-16le')
    pos, length = locations[init_idx]
    assert len(encoded) == length*2
    manifest[pos:pos+length*2] = encoded
    print('Patched startup authority:', replacement)
    with zipfile.ZipFile(output, 'w', allowZip64=True) as zout:
        for info in zin.infolist():
            name = info.filename
            # APK v2/v3 signatures live outside ZIP entries and are re-created later.
            if name == 'AndroidManifest.xml':
                zout.writestr(info, manifest)
            elif name.upper().startswith('META-INF/') and name.upper().endswith(('.RSA', '.DSA', '.EC', '.SF')):
                continue
            else:
                with zin.open(info) as src, zout.open(info, 'w') as dst:
                    shutil.copyfileobj(src, dst, 1024*1024)
