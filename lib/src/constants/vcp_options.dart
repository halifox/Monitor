const Map<int, String> vcpColorPresetOptions = <int, String>{0x01: 'sRGB', 0x02: 'Display native', 0x03: '4000K', 0x04: '5000K', 0x05: '6500K', 0x06: '7500K', 0x07: '8200K', 0x08: '9300K', 0x09: '10000K', 0x0A: '11500K', 0x0B: 'User 1', 0x0C: 'User 2', 0x0D: 'User 3'};

const Map<int, String> vcpInputSourceOptions = <int, String>{
  0x01: 'Analog video 1 (RGB)',
  0x02: 'Analog video 2 (RGB)',
  0x03: 'Digital video 1 (TMDS)',
  0x04: 'Digital video 2 (TMDS)',
  0x05: 'Composite video 1',
  0x06: 'Composite video 2',
  0x07: 'S-video 1',
  0x08: 'S-video 2',
  0x09: 'Tuner 1',
  0x0A: 'Tuner 2',
  0x0B: 'Tuner 3',
  0x0C: 'Component video 1',
  0x0D: 'Component video 2',
  0x0E: 'Component video 3',
  0x0F: 'DisplayPort 1',
  0x10: 'DisplayPort 2',
  0x11: 'HDMI 1',
  0x12: 'HDMI 2',
};

const Map<int, String> vcpOsdLanguageOptions = <int, String>{
  0x01: 'Chinese (Traditional/Hantai)',
  0x02: 'English',
  0x03: 'French',
  0x04: 'German',
  0x05: 'Italian',
  0x06: 'Japanese',
  0x07: 'Korean',
  0x08: 'Portuguese (Portugal)',
  0x09: 'Russian',
  0x0A: 'Spanish',
  0x0B: 'Swedish',
  0x0C: 'Turkish',
  0x0D: 'Chinese (Simplified/Kanta)',
  0x10: 'Portuguese (Br)',
  0x11: 'Arabic',
  0x12: 'Bulgarian',
  0x13: 'Croatian',
  0x14: 'Czech',
  0x15: 'Danish',
  0x16: 'Dutch',
  0x17: 'Estonian',
  0x18: 'Finnish',
  0x19: 'Greek',
  0x1A: 'Hebrew',
  0x1B: 'Hindi',
  0x1C: 'Hungarian',
  0x1D: 'Latvian',
  0x1E: 'Lithuanian',
  0x1F: 'Norwegian',
  0x20: 'Polish',
  0x21: 'Romanian',
  0x22: 'Serbian',
  0x23: 'Slovak',
  0x24: 'Slovenian',
  0x25: 'Thai',
  0x26: 'Ukrainian',
  0x27: 'Vietnamese',
};

const Map<int, String> vcpPowerModeOptions = <int, String>{0x01: 'On', 0x02: 'Standby', 0x03: 'Suspend', 0x04: 'Reduced power off', 0x05: 'Power off'};

const Map<int, String> vcpMuteOptions = <int, String>{0x01: 'Mute', 0x02: 'Unmute'};

const Map<int, String> vcpOsdEnableOptions = <int, String>{0x01: 'Disabled', 0x02: 'Enabled'};

const Map<int, String> vcpMirrorOptions = <int, String>{0x01: 'Normal mode', 0x02: 'Mirror mode'};

const Map<int, String> vcpDisplayScalingOptions = <int, String>{
  0x01: 'No scaling, 1:1',
  0x02: 'Max. image size with no AR distortion',
  0x03: 'Max. vertical size with no AR distortion',
  0x04: 'Max. horizontal size with no AR distortion',
  0x05: 'Max. vertical size with AR distortion',
  0x06: 'Max. horizontal size with AR distortion',
  0x07: 'Full mode',
  0x08: 'Zoom mode',
  0x09: 'Squeeze mode',
  0x0A: 'Variable',
};

const Map<int, String> vcpFlashToneEnhancementOptions = <int, String>{0x8000: 'Off - no enhancement', 0x4000: 'Enhancement 1 - not including skin tone', 0x2000: 'Enhancement 2 - including skin tone', 0x1000: 'Demo mode', 0x0800: 'User mode'};

const Map<int, String> vcpAutoColorSetupOptions = <int, String>{0x00: 'Inactive', 0x01: 'Activate', 0x02: 'Periodic'};

const Map<int, String> vcpAmbientLightSensorOptions = <int, String>{0x01: 'Disabled', 0x02: 'Enabled'};

const Map<int, String> vcpStereoModeOptions = <int, String>{0x00: 'Speaker off', 0x01: 'Mono', 0x02: 'Stereo', 0x03: 'Stereo expanded', 0x11: 'SRS 2.0', 0x12: 'SRS 2.1', 0x13: '5.1', 0x14: '7.1', 0xFF: 'Processor determined by source'};

const Map<int, String> vcpAutoSetupOnOffOptions = <int, String>{0x01: 'Off', 0x02: 'On'};

const Map<int, String> vcpScanModeOptions = <int, String>{0x00: 'Normal operation', 0x01: 'Underscan', 0x02: 'Overscan', 0x03: 'Widescreen'};

const Map<int, String> vcpDisplayApplicationOptions = <int, String>{
  0x00: 'Standard/default',
  0x01: 'Productivity',
  0x02: 'Mixed',
  0x03: 'Movie',
  0x04: 'User-defined',
  0x05: 'Games',
  0x06: 'Sports',
  0x07: 'Professional',
  0x08: 'Standard/default, intermediate power consumption',
  0x09: 'Standard/default, low power consumption',
  0x0A: 'Demonstration',
  0xF0: 'Dynamic contrast',
};

const Map<int, String> vcpOutputSelectOptions = <int, String>{
  0x01: 'Analog video 1 (RGB)',
  0x02: 'Analog video 2 (RGB)',
  0x03: 'Digital video 1 (TMDS)',
  0x04: 'Digital video 2 (TMDS)',
  0x05: 'Composite video 1',
  0x06: 'Composite video 2',
  0x07: 'S-video 1',
  0x08: 'S-video 2',
  0x09: 'Tuner 1',
  0x0A: 'Tuner 2',
  0x0B: 'Tuner 3',
  0x0C: 'Component video 1',
  0x0D: 'Component video 2',
  0x0E: 'Component video 3',
  0x0F: 'DisplayPort 1',
  0x10: 'DisplayPort 2',
  0x11: 'HDMI 1',
  0x12: 'HDMI 2',
};

const Map<int, String> vcpStereoVideoModeOptions = <int, String>{
  0x00: 'Disabled',
  0x01: 'Side-by-side interleave',
  0x02: '4-way interleave, even scan lines',
  0x04: '4-way interleave, odd scan lines',
  0x08: '2-way interleave, left eye first',
  0x10: '2-way interleave, right eye first',
  0x20: 'Field-sequential, left eye first',
  0x40: 'Field-sequential, right eye first',
};
