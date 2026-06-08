


extends Node


var _player:   AudioStreamPlayer
var _playback: AudioStreamGeneratorPlayback
var _gen:      AudioStreamGenerator

var music_volume := 0.50 : set = set_music_volume
var sfx_volume   := 0.80 : set = set_sfx_volume


var _sample_rate: float = 22050.0
var _mel_phase:   float = 0.0
var _bas_phase:   float = 0.0
var _arp_phase:   float = 0.0
var _kick_phase:  float = 0.0
var _hat_phase:   float = 0.0
var _time:        float = 0.0
var _playing_music := false


var _bpm:   float = 140.0
var _notes: Array = []
var _bass:  Array = []
var _wave:  int   = 2


var _sfx_player: AudioStreamPlayer
var _sfx_gen:    AudioStreamGenerator
var _sfx_pb:     AudioStreamGeneratorPlayback
var _sfx_phase:  float = 0.0
var _sfx_time:   float = 0.0
var _sfx_dur:    float = 0.0
var _sfx_freq:   float = 440.0
var _sfx_type:   int   = 0




const TRACKS := [

	{
		"bpm": 148.0, "wave": 2,
		"notes": [72, 76, 79, 84, 79, 76, 72, 74,
		          76, 79, 83, 84, 88, 84, 79, 76,
		          72, 74, 76, 79, 84, 83, 79, 76,
		          74, 72, 71, 72, 76, 79, 84, 79],
		"bass":  [48, 48, 52, 52, 55, 55, 53, 53,
		          48, 48, 52, 52, 55, 55, 53, 53,
		          48, 48, 52, 52, 55, 55, 53, 53,
		          48, 48, 52, 52, 55, 55, 48, 48],
	},

	{
		"bpm": 155.0, "wave": 0,
		"notes": [67, 71, 74, 79, 78, 74, 71, 67,
		          74, 78, 79, 83, 79, 78, 74, 71,
		          67, 69, 71, 74, 78, 79, 83, 79,
		          78, 74, 71, 69, 67, 71, 74, 79],
		"bass":  [43, 43, 47, 47, 50, 50, 47, 47,
		          43, 43, 47, 47, 50, 50, 47, 47,
		          43, 43, 47, 47, 50, 50, 47, 47,
		          43, 43, 47, 47, 50, 50, 43, 43],
	},

	{
		"bpm": 160.0, "wave": 2,
		"notes": [74, 78, 81, 86, 85, 81, 78, 74,
		          78, 81, 85, 86, 90, 86, 81, 78,
		          74, 76, 78, 81, 86, 85, 81, 78,
		          76, 74, 73, 74, 78, 81, 86, 81],
		"bass":  [50, 50, 54, 54, 57, 57, 55, 55,
		          50, 50, 54, 54, 57, 57, 55, 55,
		          50, 50, 54, 54, 57, 57, 55, 55,
		          50, 50, 54, 54, 57, 57, 50, 50],
	},

	{
		"bpm": 170.0, "wave": 0,
		"notes": [77, 81, 84, 89, 88, 84, 81, 77,
		          84, 88, 89, 93, 89, 88, 84, 81,
		          77, 79, 81, 84, 89, 88, 84, 81,
		          79, 77, 76, 77, 81, 84, 89, 84],
		"bass":  [53, 53, 57, 57, 60, 60, 58, 58,
		          53, 53, 57, 57, 60, 60, 58, 58,
		          53, 53, 57, 57, 60, 60, 58, 58,
		          53, 53, 57, 57, 60, 60, 53, 53],
	},

	{
		"bpm": 180.0, "wave": 0,
		"notes": [81, 85, 88, 93, 92, 88, 85, 81,
		          88, 92, 93, 97, 93, 92, 88, 85,
		          81, 83, 85, 88, 93, 92, 88, 85,
		          83, 81, 80, 81, 85, 88, 93, 88],
		"bass":  [57, 57, 61, 61, 64, 64, 62, 62,
		          57, 57, 61, 61, 64, 64, 62, 62,
		          57, 57, 61, 61, 64, 64, 62, 62,
		          57, 57, 61, 61, 64, 64, 57, 57],
	},
]


const MENU_TRACK := {
	"bpm": 132.0, "wave": 2,
	"notes": [72, 76, 79, 84, 83, 79, 76, 72,
	          76, 79, 83, 84, 88, 84, 83, 79,
	          72, 74, 76, 79, 84, 88, 84, 79,
	          76, 74, 72, 76, 79, 84, 79, 72],
	"bass":  [48, 48, 52, 52, 55, 55, 53, 53,
	          48, 48, 52, 52, 55, 55, 53, 53,
	          48, 48, 52, 52, 55, 55, 53, 53,
	          48, 48, 52, 52, 55, 55, 48, 48],
}


func _ready() -> void:
	_gen = AudioStreamGenerator.new()
	_gen.mix_rate      = _sample_rate
	_gen.buffer_length = 0.15

	_player = AudioStreamPlayer.new()
	_player.name      = "MusicPlayer"
	_player.stream    = _gen
	_player.volume_db = linear_to_db(music_volume)
	_player.bus       = "Master"
	add_child(_player)

	_sfx_gen = AudioStreamGenerator.new()
	_sfx_gen.mix_rate      = _sample_rate
	_sfx_gen.buffer_length = 0.1

	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name      = "SFXPlayer"
	_sfx_player.stream    = _sfx_gen
	_sfx_player.volume_db = linear_to_db(sfx_volume)
	_sfx_player.bus       = "Master"
	add_child(_sfx_player)




func play_level_music(level_idx: int) -> void:
	if level_idx >= 0 and level_idx < TRACKS.size():
		_apply_track(TRACKS[level_idx])
	else:
		_apply_track(MENU_TRACK)
	_start_music()

func play_menu_music() -> void:
	_apply_track(MENU_TRACK)
	_start_music()

func stop_music() -> void:
	_playing_music = false
	_player.stop()

func play_sfx_death() -> void:
	_sfx_type  = 1
	_sfx_time  = 0.0
	_sfx_dur   = 0.50
	_sfx_freq  = 440.0
	_sfx_phase = 0.0
	_sfx_player.volume_db = linear_to_db(sfx_volume)
	if not _sfx_player.playing:
		_sfx_player.play()
	_sfx_pb = _sfx_player.get_stream_playback() as AudioStreamGeneratorPlayback

func play_sfx_win() -> void:
	_sfx_type  = 2
	_sfx_time  = 0.0
	_sfx_dur   = 0.70
	_sfx_freq  = 523.0
	_sfx_phase = 0.0
	_sfx_player.volume_db = linear_to_db(sfx_volume)
	if not _sfx_player.playing:
		_sfx_player.play()
	_sfx_pb = _sfx_player.get_stream_playback() as AudioStreamGeneratorPlayback




func _apply_track(track: Dictionary) -> void:
	_bpm   = float(track["bpm"])
	_wave  = int(track["wave"])
	_notes = track["notes"]
	_bass  = track["bass"]
	_mel_phase  = 0.0
	_bas_phase  = 0.0
	_arp_phase  = 0.0
	_kick_phase = 0.0
	_hat_phase  = 0.0
	_time       = 0.0

func _start_music() -> void:
	if _player.playing:
		_player.stop()
	_player.play()
	_playback = _player.get_stream_playback() as AudioStreamGeneratorPlayback
	_playing_music = true

func _process(_delta: float) -> void:
	if _playing_music and _playback != null:
		_fill_music_buffer()
	if _sfx_type > 0 and _sfx_pb != null:
		_fill_sfx_buffer()


func _fill_music_buffer() -> void:
	var frames: int = _playback.get_frames_available()
	if frames <= 0:
		return

	var beat_dur:   float = 60.0 / _bpm
	var note_count: int   = _notes.size()

	for _i in frames:
		var beat_f:   float = _time / beat_dur
		var beat_idx: int   = int(beat_f) % note_count
		var beat_pos: float = fmod(beat_f, 1.0)

		var mel_midi: int = int(_notes[beat_idx])
		var bas_midi: int = int(_bass[beat_idx])

		var mel_freq: float = _midi_to_freq(mel_midi)
		var bas_freq: float = _midi_to_freq(bas_midi)


		var mel_env: float = 1.0 - beat_pos * 0.4
		var mel_sample: float = _oscillator(_mel_phase, _wave) * 0.20 * mel_env


		var bas_env: float = 1.0 - beat_pos * 0.25
		var bas_sample: float = _oscillator(_bas_phase, 2) * 0.20 * bas_env


		var arp_sample: float = 0.0
		var arp_beat: int = beat_idx % 4
		if arp_beat == 0 or arp_beat == 2:
			var arp_offset: int = 12 if arp_beat == 0 else 7
			var arp_freq: float = _midi_to_freq(mel_midi + arp_offset)
			var arp_env: float  = maxf(0.0, 1.0 - beat_pos * 1.5)
			arp_sample = _oscillator(_arp_phase, 3) * 0.08 * arp_env
			_arp_phase += arp_freq / _sample_rate
			if _arp_phase > 1.0:
				_arp_phase -= 1.0


		var kick: float = 0.0
		if arp_beat == 0 or arp_beat == 2:
			var kick_t: float = beat_pos
			if kick_t < 0.12:
				var kick_freq: float = 120.0 * (1.0 - kick_t * 6.0)
				kick = sin(_kick_phase * TAU) * (1.0 - kick_t / 0.12) * 0.28
				_kick_phase += kick_freq / _sample_rate
			else:
				_kick_phase = 0.0


		var hat: float = 0.0
		if arp_beat == 1 or arp_beat == 3:
			if beat_pos < 0.06:
				hat = (randf() * 2.0 - 1.0) * (1.0 - beat_pos / 0.06) * 0.12


		var sample: float = mel_sample + bas_sample + arp_sample + kick + hat


		sample = clampf(sample, -0.85, 0.85)

		_mel_phase += mel_freq / _sample_rate
		if _mel_phase > 1.0:
			_mel_phase -= 1.0
		_bas_phase += bas_freq / _sample_rate
		if _bas_phase > 1.0:
			_bas_phase -= 1.0

		_time += 1.0 / _sample_rate
		_playback.push_frame(Vector2(sample, sample))


func _fill_sfx_buffer() -> void:
	var frames: int = _sfx_pb.get_frames_available()
	if frames <= 0:
		return

	for _i in frames:
		if _sfx_time >= _sfx_dur:
			_sfx_type = 0
			break

		var t: float = _sfx_time / _sfx_dur
		var sample: float = 0.0

		if _sfx_type == 1:

			var freq: float = _sfx_freq * (1.0 - t * 0.7)
			var wobble: float = sin(_sfx_time * 35.0) * 0.3
			sample = _oscillator(_sfx_phase, 0) * (1.0 - t) * 0.40
			sample += wobble * (1.0 - t) * 0.15
			_sfx_phase += freq / _sample_rate
		elif _sfx_type == 2:

			var freq: float = _sfx_freq * (1.0 + t * 0.8)
			var sparkle: float = sin(_sfx_time * 60.0) * 0.15 * (1.0 - t)
			sample = _oscillator(_sfx_phase, 3) * (1.0 - t * 0.5) * 0.35
			sample += sparkle
			_sfx_phase += freq / _sample_rate

		if _sfx_phase > 1.0:
			_sfx_phase -= 1.0
		_sfx_time += 1.0 / _sample_rate
		_sfx_pb.push_frame(Vector2(sample, sample))


func _oscillator(phase: float, wave_type: int) -> float:
	var p: float = fmod(phase, 1.0)
	match wave_type:
		0:
			return 1.0 if p < 0.25 else -1.0
		1:
			return p * 2.0 - 1.0
		2:
			return 4.0 * absf(p - 0.5) - 1.0
		3:
			return sin(p * TAU)
	return 0.0

func _midi_to_freq(midi: int) -> float:
	return 440.0 * pow(2.0, float(midi - 69) / 12.0)


func set_music_volume(v: float) -> void:
	music_volume = clampf(v, 0.0, 1.0)
	if _player:
		_player.volume_db = linear_to_db(music_volume)

func set_sfx_volume(v: float) -> void:
	sfx_volume = clampf(v, 0.0, 1.0)
	if _sfx_player:
		_sfx_player.volume_db = linear_to_db(sfx_volume)
