class RadioWheel {
    constructor() {
        this.stations = [];
        this.selectedIndex = 0;
        this.currentStation = null;
        this.isOpen = false;
        this.inVehicle = false;
        this.wheelEl = document.getElementById('radio-wheel');
        this.stationsRing = document.getElementById('stations-ring');
        this.npTitle = document.getElementById('np-title');
        this.npArtist = document.getElementById('np-artist');
        this.nowPlaying = document.getElementById('now-playing');
        this.npBar = document.getElementById('now-playing-bar');
        this.npbTitle = document.getElementById('npb-title');
        this.npbArtist = document.getElementById('npb-artist');
        this.npbLogo = document.getElementById('npb-logo');
        this.volumeSlider = document.getElementById('volume-slider');
        this.volumeValue = document.getElementById('volume-value');
    }

    get offSlotIndex() { return this.stations.length; }
    isOffSelected() { return this.selectedIndex === this.offSlotIndex; }
    get totalSlots() { return this.stations.length + 1; }

    open(stations, currentStation, volume) {
        this.stations = stations || [];
        this.currentStation = currentStation;
        this.selectedIndex = currentStation ? currentStation - 1 : this.offSlotIndex;
        this.isOpen = true;

        this.volumeSlider.value = Math.round((volume || 0.7) * 100);
        this.volumeValue.textContent = this.volumeSlider.value + '%';

        this.renderStations();
        this.wheelEl.classList.remove('hidden');
        this.hideNowPlayingBar();
    }

    close() {
        this.isOpen = false;
        this.wheelEl.classList.add('hidden');

        if (this.isOffSelected()) {
            if (this.currentStation !== null) {
                fetch('https://ob_radio_2/turnOff', { method: 'POST', body: '{}' });
                this.currentStation = null;
                this.hideNowPlayingBar();
                this.updateNowPlaying(null);
            }
        } else {
            const newStationIndex = this.selectedIndex + 1;
            if (this.stations[this.selectedIndex] && newStationIndex !== this.currentStation) {
                fetch('https://ob_radio_2/selectStation', {
                    method: 'POST',
                    body: JSON.stringify({ stationIndex: newStationIndex })
                });
            }
            if (this.currentStation || this.stations[this.selectedIndex]) {
                this.showNowPlayingBar();
            }
        }
    }

    renderStations() {
        this.stationsRing.innerHTML = '';
        this.stationsRing.style.transform = 'none';
        const total = this.totalSlots;
        const step = 360 / total;
        const radius = 300;
        const offIdx = this.offSlotIndex;

        const placeItem = (i, content, extraClasses) => {
            const angleDeg = 180 - (offIdx - i) * step;
            const el = document.createElement('div');
            el.className = 'station-item' + (extraClasses ? ' ' + extraClasses : '');
            el.dataset.index = i;
            el.dataset.angle = angleDeg;
            el.style.transform = `rotate(${angleDeg}deg) translateY(-${radius}px) rotate(${-angleDeg}deg)`;

            const inner = document.createElement('div');
            inner.className = 'icon-inner';
            if (content instanceof Node) inner.appendChild(content);
            else inner.textContent = content;
            el.appendChild(inner);

            this.stationsRing.appendChild(el);
        };

        this.stations.forEach((station, i) => {
            const extra = (this.currentStation === i + 1) ? 'active' : '';
            let content;
            if (station.logo) {
                content = document.createElement('img');
                content.src = 'img/' + station.logo;
                content.alt = station.label || '';
                content.onerror = () => { content.replaceWith(document.createTextNode('📻')); };
            } else {
                content = '📻';
            }
            placeItem(i, content, extra);
        });

        placeItem(offIdx, '⏻', 'off-slot' + (this.currentStation === null ? ' active' : ''));

        this.updateSelection();
    }

    updateSelection() {
        const items = this.stationsRing.querySelectorAll('.station-item');

        items.forEach((el, i) => {
            const isSel = i === this.selectedIndex;
            el.classList.toggle('selected', isSel);
            const base = parseFloat(el.dataset.angle);
            const scale = isSel ? 1.7 : 1;
            el.style.transform = `rotate(${base}deg) translateY(-300px) rotate(${-base}deg) scale(${scale})`;
        });

        const centerLabel = document.getElementById('center-label');
        if (this.isOffSelected()) {
            centerLabel.textContent = 'Radio Off';
            this.nowPlaying.classList.add('hidden');
        } else {
            const station = this.stations[this.selectedIndex];
            if (station) {
                centerLabel.textContent = station.label;
                if (this.currentStation === this.selectedIndex + 1 && this.currentSong) {
                    this.npTitle.textContent = this.currentSong.title || '';
                    this.npArtist.textContent = this.currentSong.artist || '';
                    this.nowPlaying.classList.remove('hidden');
                } else {
                    this.nowPlaying.classList.add('hidden');
                }
            }
        }
    }

    scrollUp() {
        if (!this.isOpen) return;
        this.selectedIndex = (this.selectedIndex - 1 + this.totalSlots) % this.totalSlots;
        this.updateSelection();
    }

    scrollDown() {
        if (!this.isOpen) return;
        this.selectedIndex = (this.selectedIndex + 1) % this.totalSlots;
        this.updateSelection();
    }

    updateNowPlaying(song) {
        if (!song) {
            this.nowPlaying.classList.add('hidden');
            return;
        }
        this.npTitle.textContent = song.title || '';
        this.npArtist.textContent = song.artist || '';
        this.nowPlaying.classList.remove('hidden');
    }

    _setScrollText(container, text) {
        const inner = container.querySelector('.scroll-inner');
        if (!inner) return;
        // Avoid resetting the animation if text didn't change
        if (container.dataset.text === text) return;
        container.dataset.text = text;

        inner.textContent = text;
        container.classList.remove('scrolling');
        requestAnimationFrame(() => {
            if (inner.scrollWidth > container.clientWidth) {
                const gap = '\u00A0\u00A0\u00A0\u00A0\u00A0\u00A0';
                inner.textContent = text + gap + text + gap;
                container.classList.add('scrolling');
            }
        });
    }

    showNowPlayingBar() {
        if (!this.currentSong || !this.inVehicle) return;
        const { title = '', artist = '' } = this.currentSong;
        if (this.currentStationLogo) {
            this.npbLogo.src = 'img/' + this.currentStationLogo;
            this.npbLogo.style.display = '';
        } else {
            this.npbLogo.style.display = 'none';
        }
        this.npBar.classList.remove('hidden');
        // Needs to be in the DOM/visible before measuring overflow
        this._setScrollText(this.npbTitle, title);
        this._setScrollText(this.npbArtist, artist);
    }

    hideNowPlayingBar() {
        this.npBar.classList.add('hidden');
    }

    setVolumeDisplay(vol) {
        const pct = Math.round((vol || 0) * 100);
        this.volumeSlider.value = pct;
        this.volumeValue.textContent = pct + '%';
    }

    setInVehicle(inVehicle) {
        this.inVehicle = inVehicle;
        if (inVehicle && !this.isOpen && this.currentSong) this.showNowPlayingBar();
        else if (!inVehicle) this.hideNowPlayingBar();
    }

    setCurrentSong(song, station) {
        this.currentSong = song;
        if (station) {
            if (station.logo) this.currentStationLogo = station.logo;
            if (station.label) this.currentStationName = station.label;
        }
        this.updateNowPlaying(song);
        if (!this.isOpen) this.showNowPlayingBar();
    }

    _formatTime(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        const m = Math.floor(s / 60);
        const sec = s % 60;
        return m + ':' + (sec < 10 ? '0' : '') + sec;
    }

    startProgress(duration, offset) {
        this.stopProgress();
        if (!duration || duration <= 0) return;

        const fill = document.getElementById('npb-progress-fill');
        const dot = document.getElementById('npb-progress-dot');
        const timeCurrent = document.getElementById('npb-time-current');
        const timeTotal = document.getElementById('npb-time-total');
        if (!fill) return;

        if (timeTotal) timeTotal.textContent = this._formatTime(duration);

        const startTime = Date.now() - (offset * 1000);
        const durationMs = duration * 1000;

        const tick = () => {
            const elapsed = Date.now() - startTime;
            const elapsedSec = elapsed / 1000;
            const pct = Math.min(100, (elapsed / durationMs) * 100);
            fill.style.width = pct + '%';
            if (dot) dot.style.left = pct + '%';
            if (timeCurrent) timeCurrent.textContent = this._formatTime(Math.min(elapsedSec, duration));
            if (pct < 100) {
                this._progressRaf = requestAnimationFrame(tick);
            }
        };
        tick();
    }

    stopProgress() {
        if (this._progressRaf) {
            cancelAnimationFrame(this._progressRaf);
            this._progressRaf = null;
        }
        const fill = document.getElementById('npb-progress-fill');
        const dot = document.getElementById('npb-progress-dot');
        const timeCurrent = document.getElementById('npb-time-current');
        const timeTotal = document.getElementById('npb-time-total');
        if (fill) fill.style.width = '0%';
        if (dot) dot.style.left = '0%';
        if (timeCurrent) timeCurrent.textContent = '0:00';
        if (timeTotal) timeTotal.textContent = '0:00';
    }
}

const radioWheel = new RadioWheel();
