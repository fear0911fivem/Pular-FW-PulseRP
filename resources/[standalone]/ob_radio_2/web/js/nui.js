window.addEventListener('message', function(event) {
    const data = event.data;

    switch (data.action) {
        case 'openWheel':
            radioWheel.open(data.stations, data.currentStation, data.volume);
            break;

        case 'closeWheel':
            radioWheel.close();
            break;

        case 'scrollUp':
            radioWheel.scrollUp();
            break;

        case 'scrollDown':
            radioWheel.scrollDown();
            break;

        case 'playStation':
            if (data.song && data.song.file) {
                radioAudio.play(data.song.file, data.offset || 0, data.volume || 0.7);
                radioWheel.currentStation = data.stationIndex;
                radioWheel.setCurrentSong(data.song, data.station);
                radioWheel.startProgress(data.song.duration, data.offset || 0);
            }
            if (data.spatial) radioAudio.updateSpatial(data.spatial);
            break;

        case 'stopAudio':
            radioAudio.stop();
            radioWheel.currentStation = null;
            radioWheel.currentSong = null;
            radioWheel.currentStationLogo = null;
            radioWheel.currentStationName = null;
            radioWheel.hideNowPlayingBar();
            radioWheel.updateNowPlaying(null);
            radioWheel.stopProgress();
            break;

        case 'songChanged':
            if (data.song && data.song.file) {
                radioAudio.changeSong(data.song.file, data.offset || 0);
                radioWheel.setCurrentSong(data.song);
                radioWheel.startProgress(data.song.duration, data.offset || 0);
            }
            break;

        case 'setVolume':
            radioAudio.setVolume(data.volume);
            radioWheel.setVolumeDisplay(data.volume);
            break;

        case 'updateSpatial':
            radioAudio.updateSpatial(data.spatial);
            break;

        case 'setInVehicle':
            radioWheel.setInVehicle(!!data.inVehicle);
            break;
    }
});

document.addEventListener('contextmenu', e => e.preventDefault());
