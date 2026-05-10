// Reads duration from .ogg files in ob_radio_2/songs/
// Handles both real OGG Vorbis and WebM-in-.ogg containers.
// Usage: node tools/song_durations.js

const fs = require('fs');
const path = require('path');

const songsDir = path.resolve(__dirname, '..', 'songs');

// ---- WebM/Matroska parser ----
function readVint(buf, off) {
    const first = buf[off];
    if (first === 0) return null;
    let length = 0;
    for (let i = 7; i >= 0; i--) {
        if (first & (1 << i)) { length = 8 - i; break; }
    }
    let value = first & ((1 << (8 - length)) - 1);
    for (let i = 1; i < length; i++) value = value * 256 + buf[off + i];
    return { value, length };
}
function readId(buf, off) {
    const first = buf[off];
    let length = 0;
    for (let i = 7; i >= 0; i--) {
        if (first & (1 << i)) { length = 8 - i; break; }
    }
    let value = 0;
    for (let i = 0; i < length; i++) value = value * 256 + buf[off + i];
    return { value, length };
}
function findElement(buf, start, end, targetId) {
    let off = start;
    while (off < end) {
        const id = readId(buf, off); off += id.length;
        const size = readVint(buf, off); off += size.length;
        if (id.value === targetId) return { dataOff: off, dataSize: size.value };
        if (id.value === 0x18538067 || id.value === 0x1549A966) {
            const inner = findElement(buf, off, off + size.value, targetId);
            if (inner) return inner;
        }
        off += size.value;
    }
    return null;
}
function webmDuration(buf) {
    const tsEl = findElement(buf, 0, buf.length, 0x2AD7B1);
    let timecodeScale = 1000000;
    if (tsEl) {
        timecodeScale = 0;
        for (let i = 0; i < tsEl.dataSize; i++) timecodeScale = timecodeScale * 256 + buf[tsEl.dataOff + i];
    }
    const durEl = findElement(buf, 0, buf.length, 0x4489);
    if (!durEl) return null;
    const duration = durEl.dataSize === 4 ? buf.readFloatBE(durEl.dataOff) : buf.readDoubleBE(durEl.dataOff);
    return duration * timecodeScale / 1e9;
}

// ---- OGG Vorbis parser ----
function oggDuration(buf) {
    let sampleRate = 44100;
    for (let i = 0; i < Math.min(buf.length - 20, 8192); i++) {
        if (buf[i] === 0x01 && buf.slice(i + 1, i + 7).toString() === 'vorbis') {
            sampleRate = buf.readUInt32LE(i + 12);
            break;
        }
    }
    let maxGranule = 0;
    let i = 0;
    while (i < buf.length - 27) {
        if (buf[i]===0x4f && buf[i+1]===0x67 && buf[i+2]===0x67 && buf[i+3]===0x53) {
            const lo = buf.readUInt32LE(i + 6);
            const hi = buf.readInt32LE(i + 10);
            if (!(lo === 0xFFFFFFFF && hi === -1)) {
                const g = hi * 0x100000000 + lo;
                if (g > maxGranule) maxGranule = g;
            }
            const numSegs = buf[i + 26];
            if (i + 27 + numSegs > buf.length) break;
            let bodySize = 0;
            for (let s = 0; s < numSegs; s++) bodySize += buf[i + 27 + s];
            i += 27 + numSegs + bodySize;
        } else i++;
    }
    return maxGranule > 0 ? maxGranule / sampleRate : null;
}

function getDuration(filepath) {
    const buf = fs.readFileSync(filepath);
    // EBML magic = WebM/Matroska
    if (buf[0] === 0x1A && buf[1] === 0x45 && buf[2] === 0xDF && buf[3] === 0xA3) {
        return webmDuration(buf);
    }
    // OggS magic = Ogg container
    if (buf[0] === 0x4F && buf[1] === 0x67 && buf[2] === 0x67 && buf[3] === 0x53) {
        return oggDuration(buf);
    }
    return null;
}

const files = fs.readdirSync(songsDir).filter(f => f.toLowerCase().endsWith('.ogg')).sort();
console.log('-- Song durations for config.lua:');
console.log('');
for (const f of files) {
    try {
        const dur = getDuration(path.join(songsDir, f));
        if (dur) {
            console.log(`{ file = '${f}', title = '', artist = '', duration = ${Math.round(dur)} },`);
        } else {
            console.log(`-- ${f}: could not parse duration`);
        }
    } catch (e) {
        console.log(`-- ${f}: error ${e.message}`);
    }
}
