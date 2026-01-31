import 'package:image_picker/image_picker.dart';

class PhotoService {
  PhotoService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<String?> pickFromCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    return image?.path;
  }

  Future<String?> pickFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }
}
