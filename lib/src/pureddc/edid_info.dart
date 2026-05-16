import 'dart:typed_data';

class EdidInfo {
  final String manufacturerName;
  final String productCode;
  final String serialNumber;
  final String manufactured;
  final String edidVersion;
  final String inputType;
  final String preferredTiming;
  final int extensionBlocks;
  final String rawData;

  const EdidInfo({
    required this.manufacturerName,
    required this.productCode,
    required this.serialNumber,
    required this.manufactured,
    required this.edidVersion,
    required this.inputType,
    required this.preferredTiming,
    required this.extensionBlocks,
    required this.rawData,
  });

  static EdidInfo? parse(Uint8List edidData) {
    if (edidData.length < 128) {
      return null;
    }

    if (edidData[0] != 0x00 || edidData[1] != 0xFF || edidData[7] != 0x00) {
      return null;
    }

    try {
      final manufacturerName = _parseManufacturerName(edidData);
      final productCode = _parseProductCode(edidData);
      final serialNumber = _parseSerialNumber(edidData);
      final manufactured = _parseManufactured(edidData);
      final edidVersion = _parseEdidVersion(edidData);
      final inputType = _parseInputType(edidData);
      final preferredTiming = _parsePreferredTiming(edidData);
      final extensionBlocks = edidData[126];
      final rawData = _formatRawData(edidData);

      return EdidInfo(
        manufacturerName: manufacturerName,
        productCode: productCode,
        serialNumber: serialNumber,
        manufactured: manufactured,
        edidVersion: edidVersion,
        inputType: inputType,
        preferredTiming: preferredTiming,
        extensionBlocks: extensionBlocks,
        rawData: rawData,
      );
    } catch (e) {
      return null;
    }
  }

  static String _parseManufacturerName(Uint8List data) {
    final int byte1 = data[8];
    final int byte2 = data[9];

    final int char1 = ((byte1 >> 2) & 0x1F) + 64;
    final int char2 = (((byte1 & 0x03) << 3) | ((byte2 >> 5) & 0x07)) + 64;
    final int char3 = (byte2 & 0x1F) + 64;

    final String manufacturerCode = String.fromCharCodes([char1, char2, char3]);

    final String? monitorName = _parseMonitorName(data);
    if (monitorName != null && monitorName.isNotEmpty) {
      return '$manufacturerCode $monitorName';
    }

    return manufacturerCode;
  }

  static String? _parseMonitorName(Uint8List data) {
    int offset = 54;
    for (int i = 0; i < 4; i++) {
      final int descriptorStart = offset + (i * 18);
      if (descriptorStart + 17 >= data.length) break;

      final int pixelClock = data[descriptorStart] | (data[descriptorStart + 1] << 8);
      if (pixelClock != 0) continue;

      final int tag = data[descriptorStart + 3];
      if (tag == 0xFC) {
        final buffer = StringBuffer();
        for (int j = 5; j < 18; j++) {
          final int char = data[descriptorStart + j];
          if (char == 0x0A || char == 0x00) break;
          if (char >= 0x20 && char <= 0x7E) {
            buffer.writeCharCode(char);
          }
        }
        final name = buffer.toString().trim();
        return name.isNotEmpty ? name : null;
      }
    }
    return null;
  }

  static String _parseProductCode(Uint8List data) {
    final int byte1 = data[8];
    final int byte2 = data[9];

    final int char1 = ((byte1 >> 2) & 0x1F) + 64;
    final int char2 = (((byte1 & 0x03) << 3) | ((byte2 >> 5) & 0x07)) + 64;
    final int char3 = (byte2 & 0x1F) + 64;

    final String manufacturerCode = String.fromCharCodes([char1, char2, char3]);

    final int productId = data[10] | (data[11] << 8);
    final String productCode = productId.toRadixString(16).toUpperCase().padLeft(4, '0');

    return '$manufacturerCode$productCode';
  }

  static String _parseSerialNumber(Uint8List data) {
    final int serial = data[12] | (data[13] << 8) | (data[14] << 16) | (data[15] << 24);
    if (serial == 0 || serial == 1) {
      return _parseSerialFromDescriptor(data) ?? serial.toString();
    }
    return serial.toString();
  }

  static String? _parseSerialFromDescriptor(Uint8List data) {
    int offset = 54;
    for (int i = 0; i < 4; i++) {
      final int descriptorStart = offset + (i * 18);
      if (descriptorStart + 17 >= data.length) break;

      final int pixelClock = data[descriptorStart] | (data[descriptorStart + 1] << 8);
      if (pixelClock != 0) continue;

      final int tag = data[descriptorStart + 3];
      if (tag == 0xFF) {
        final buffer = StringBuffer();
        for (int j = 5; j < 18; j++) {
          final int char = data[descriptorStart + j];
          if (char == 0x0A || char == 0x00) break;
          if (char >= 0x20 && char <= 0x7E) {
            buffer.writeCharCode(char);
          }
        }
        final serial = buffer.toString().trim();
        return serial.isNotEmpty ? serial : null;
      }
    }
    return null;
  }

  static String _parseManufactured(Uint8List data) {
    final int week = data[16];
    final int year = data[17] + 1990;

    if (week == 0xFF) {
      return '$year';
    } else if (week == 0) {
      return '$year';
    } else {
      return '$year ISO week $week';
    }
  }

  static String _parseEdidVersion(Uint8List data) {
    final int major = data[18];
    final int minor = data[19];
    return '$major.$minor';
  }

  static String _parseInputType(Uint8List data) {
    final int videoInput = data[20];
    final bool isDigital = (videoInput & 0x80) != 0;

    if (isDigital) {
      final int bitDepth = (videoInput >> 4) & 0x07;
      final int interface = videoInput & 0x0F;

      String bitDepthStr = switch (bitDepth) {
        0 => 'undefined',
        1 => '6-bit',
        2 => '8-bit',
        3 => '10-bit',
        4 => '12-bit',
        5 => '14-bit',
        6 => '16-bit',
        _ => 'reserved',
      };

      String interfaceStr = switch (interface) {
        0 => 'undefined',
        1 => 'DVI',
        2 => 'HDMI-a',
        3 => 'HDMI-b',
        4 => 'MDDI',
        5 => 'DisplayPort',
        _ => 'reserved',
      };

      return '$interfaceStr ($bitDepthStr)';
    } else {
      return 'Analog';
    }
  }

  static String _parsePreferredTiming(Uint8List data) {
    int offset = 54;
    for (int i = 0; i < 4; i++) {
      final int descriptorStart = offset + (i * 18);
      if (descriptorStart + 17 >= data.length) break;

      final int pixelClock = data[descriptorStart] | (data[descriptorStart + 1] << 8);
      if (pixelClock == 0) continue;

      final int hActive = data[descriptorStart + 2] | ((data[descriptorStart + 4] & 0xF0) << 4);
      final int hBlank = data[descriptorStart + 3] | ((data[descriptorStart + 4] & 0x0F) << 8);
      final int vActive = data[descriptorStart + 5] | ((data[descriptorStart + 7] & 0xF0) << 4);
      final int vBlank = data[descriptorStart + 6] | ((data[descriptorStart + 7] & 0x0F) << 8);

      if (hActive > 0 && vActive > 0) {
        final double pixelClockMHz = pixelClock / 100.0;
        final int hTotal = hActive + hBlank;
        final int vTotal = vActive + vBlank;
        final double refreshRate = (pixelClockMHz * 1000000) / (hTotal * vTotal);

        return '${hActive}x${vActive} at ${refreshRate.round()}Hz x 2';
      }
    }

    return 'Not available';
  }

  static String _formatRawData(Uint8List data) {
    final buffer = StringBuffer();
    for (int i = 0; i < data.length && i < 128; i++) {
      if (i > 0 && i % 16 == 0) {
        buffer.write(' ');
      }
      buffer.write(data[i].toRadixString(16).toUpperCase().padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
