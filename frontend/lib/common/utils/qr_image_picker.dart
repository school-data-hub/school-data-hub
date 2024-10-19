import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

Future<String?> scanPickedQrImage() async {
  final MobileScannerController controller = MobileScannerController();
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
  );

  if (image == null) {
    return null;
  }

  final BarcodeCapture? barcodes = await controller.analyzeImage(
    image.path,
  );
  final File imageFile = File(image.path);
  await imageFile.delete();
  if (barcodes == null || barcodes.barcodes.isEmpty) {
    return null;
  }
  return barcodes.barcodes.last.rawValue;
}
