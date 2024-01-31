import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mnc_identifier_ocr/mnc_identifier_ocr.dart';
import 'package:mnc_identifier_ocr/model/ocr_result_model.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/data_seru.dart';

class YaoHomePage extends StatefulWidget {
  const YaoHomePage({super.key});

  @override
  State<YaoHomePage> createState() => _YaoHomePageState();
}

class _YaoHomePageState extends State<YaoHomePage> {
  // variable index Stepper Widget
  int _currentStep = 0;
  // variable input nama dan bio
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
// variable untuk api wilayah
  List<dynamic> _cities = [];
  List<dynamic> _provinces = [];
  List<dynamic> _kecamatan = [];
  List<dynamic> _kelurahan = [];
  int? _selectedCityIndex = 0;
  int? _selectedProvinceIndex = 0;
  int? _selectedKecamatanIndex = 0;
  int? _selectedKelurahanIndex = 0;

  // variable image
  double scale = 1.0;
  ImagePicker imagePicker = ImagePicker();
  List<File> capturedImages = [];
  List<String> capturedImagePaths = [];
  bool isUploading = false;
  File? imageFile;
  File? fotoSelfie;
  TextEditingController nikController = TextEditingController();
  final List<TextEditingController> imageUrlControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  List<String> imageUrls = [];
  // variable untuk menampung data
  String nama = '';
  String bio = '';
  String provinsi = '';
  String kota = '';
  String kecamatan = '';
  String kelurahan = '';
  String nik = '';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProvinces();
  }

// fungsi mengambil gambar untuk KTP,dilanjutkan dengan proses pemindaian NIK KTP
  Future pickImage(ImageSource imageSource) async {
    try {
      PermissionStatus status = await Permission.camera.request();
      if (status.isGranted) {
        final pickedFile = await imagePicker.pickImage(source: imageSource);
        setState(() {
          imageFile = File(pickedFile!.path);
          capturedImages.add(imageFile!);
        });
        if (imageFile != null) {
          scanKtp(imageFile!);
        }
      } else {
        debugPrint(
            'Anda perlu memberikan izin kamera untuk menggunakan fitur ini');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  // fungsi Foto Selfie
  Future fotoDiri(ImageSource fotoS) async {
    try {
      PermissionStatus status = await Permission.camera.request();
      if (status.isGranted) {
        final pickedFile = await imagePicker.pickImage(source: fotoS);
        setState(() {
          fotoSelfie = File(pickedFile!.path);
        });
      } else {
        debugPrint(
            'Anda perlu memberikan izin kamera untuk menggunakan fitur ini');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future scanKtp(File imageFile) async {
    try {
      OcrResultModel result = await MncIdentifierOcr.startCaptureKtp(
        withFlash: false,
        cameraOnly: true,
      );

      if (result.ktp != null) {
        setState(() {
          nikController.text = result.ktp!.nik.toString();
        });
      }
    } catch (e) {
      debugPrint('Error scanning KTP: $e');
    }
  }

  Future<void> fetchProvinces() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('https://api.goapi.io/regional/provinsi'),
        headers: {
          'accept': 'application/json',
          'X-API-KEY': 'd7cf21cb-1bd6-5697-6529-6b2bc272'
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _provinces = json.decode(response.body)['data'];
        });
      } else {
        throw Exception('Failed to load provinces: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error fetching provinces: $error');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Error fetching provinces. Please check your internet connection.'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                fetchProvinces();
              }),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchCities(String provinceId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.goapi.io/regional/kota?provinsi_id=$provinceId'),
        headers: {
          'accept': 'application/json',
          'X-API-KEY': 'd7cf21cb-1bd6-5697-6529-6b2bc272'
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _cities = json.decode(response.body)['data'];
        });
      } else {
        throw Exception('Failed to load cities: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error fetching cities: $error');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Error fetching cities. Please check your internet connection.'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              fetchCities(provinceId);
            },
          ),
        ),
      );
    }
  }

  Future<void> fetchKecamatan(String cityId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('https://api.goapi.io/regional/kecamatan?kota_id=$cityId'),
        headers: {
          'accept': 'application/json',
          'X-API-KEY': 'd7cf21cb-1bd6-5697-6529-6b2bc272'
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _kecamatan = json.decode(response.body)['data'];
        });
        fetchKelurahan(_kecamatan[_selectedKecamatanIndex!]['id']);
      } else {
        throw Exception('Failed to load kecamatan: ${response.statusCode}');
      }
    } catch (error) {
      handleFetchError('kecamatan', error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchKelurahan(String kecamatanId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.goapi.io/regional/kelurahan?kecamatan_id=$kecamatanId'),
        headers: {
          'accept': 'application/json',
          'X-API-KEY': 'd7cf21cb-1bd6-5697-6529-6b2bc272'
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _kelurahan = json.decode(response.body)['data'];
        });
      } else {
        throw Exception('Failed to load kelurahan: ${response.statusCode}');
      }
    } catch (error) {
      handleFetchError('kelurahan', error);
    }
  }

  void handleFetchError(String dataType, dynamic error) {
    debugPrint('Error fetching $dataType: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Error fetching $dataType. Please check your internet connection.'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            if (dataType == 'provinces') {
              fetchProvinces();
            } else if (dataType == 'cities') {
              fetchCities(_provinces[_selectedProvinceIndex!]['id']);
            } else if (dataType == 'kecamatan') {
              fetchKecamatan(_cities[_selectedCityIndex!]['id']);
            } else if (dataType == 'kelurahan') {
              fetchKelurahan(_kecamatan[_selectedKecamatanIndex!]['id']);
            }
          },
        ),
      ),
    );
  }

  void clearKtpImage() {
    setState(() {
      imageFile = null;
    });
  }

  void clearSelfieImage() {
    setState(() {
      fotoSelfie = null;
    });
  }

  // Upload Gambar
  Future<void> uploadImage() async {
    try {
      setState(() {
        isUploading = true;
      });
      imageUrls = await uploadMultipleToCloudinary([imageFile!, fotoSelfie!]);

      // Update the URLs in your text fields or wherever needed
      for (int i = 0; i < imageUrls.length; i++) {
        imageUrlControllers[i].text = imageUrls[i];
      }
      setState(() {
        isUploading = false; // Set loading state to false
      });
      showUploadMessage();
    } catch (e) {
      debugPrint('Error uploading images: $e');
      setState(() {
        isUploading = false;
      });
    }
  }

  //menampilkan pesan untuk proses upload
  Future<dynamic> showUploadMessage() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Berhasil'),
        content: const Text('Gambar berhasil tersimpan di Server'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // fungsi untuk mengirim gambar ke Cloudinary
  Future<List<String>> uploadMultipleToCloudinary(List<File> imageFiles) async {
    try {
      String cloudinaryUrl =
          'https://api.cloudinary.com/v1_1/dqqczr75t/image/upload';
      String uploadPreset = 'bllw7mn8';

      Dio dio = Dio();

      List<String> uploadedUrls = [];

      for (File imageFile in imageFiles) {
        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(imageFile.path),
          'upload_preset': uploadPreset,
        });

        Response response = await dio.post(
          cloudinaryUrl,
          data: formData,
          options: Options(
            headers: {
              'Content-Type': 'multipart/form-data',
            },
          ),
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = response.data;
          uploadedUrls.add(responseData['secure_url']);
        } else {
          debugPrint(
              'Error uploading image to Cloudinary. Status code: ${response.statusCode}');
        }
      }

      return uploadedUrls;
    } catch (e, stackTrace) {
      debugPrint('Error uploading images to Cloudinary: $e\n$stackTrace');
      return [];
    }
  }

  void onStepContinue() {
    setState(() {
      if (_currentStep < 2) {
        _currentStep += 1; // Move to the next step
      } else {
        sendDataToApi();
        debugPrint('Form submitted successfully');
      }
    });
  }

  // mengirim Data Ke API
  void sendDataToApi() async {
    // Convert data to JSON format
    Map<String, dynamic> jsonData = {
      'nama': nama,
      'bio': bio,
      'provinsi': _provinces.isNotEmpty
          ? _provinces[_selectedProvinceIndex!]['name']
          : 'Belum Dipilih',
      'kota': _cities.isNotEmpty
          ? _cities[_selectedCityIndex!]['name']
          : 'Belum Dipilih',
      'kecamatan': _kecamatan.isNotEmpty
          ? _kecamatan[_selectedKecamatanIndex!]['name']
          : 'Belum Dipilih',
      'kelurahan': _kelurahan.isNotEmpty
          ? _kelurahan[_selectedKelurahanIndex!]['name']
          : 'Belum Dipilih',
      'nik': nik,
      'imageKtp': imageUrls.isNotEmpty ? imageUrls[0] : '',
      'imageSelfie': imageUrls.length > 1 ? imageUrls[1] : '',
    };

    // Convert to JSON string
    String jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data JSON'),
        content: SingleChildScrollView(
          child: Text(jsonString), // Display JSON string here
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // Di sini, Anda dapat mengirimkan jsonString ke API Anda menggunakan metode yang Anda preferensikan
    // Sebagai contoh, menggunakan http.post atau Dio.post
    // Pastikan untuk menangani kesalahan dan tanggapan dengan benar

    // Contoh menggunakan paket http
    // http.post(apiUrl, body: jsonString, headers: {'Content-Type': 'application/json'})
    //   .then((response) {
    //     if (response.statusCode == 200) {
    //       // Tangani keberhasilan
    //       print('Data berhasil dikirim');
    //     } else {
    //       // Tangani kesalahan
    //       print('Gagal mengirim data. Kode status: ${response.statusCode}');
    //     }
    //   })
    //   .catchError((error) {
    //     // Tangani kesalahan
    //     print('Error saat mengirim data: $error');
    //   });
  }

  void onStepCancel() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SERU'),
      ),
      body: Stepper(
        onStepContinue: onStepContinue,
        onStepCancel: onStepCancel,
        type: StepperType.horizontal,
        currentStep: _currentStep,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (details.onStepContinue != null)
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(_currentStep < 2 ? 'Continue' : 'Finish'),
                  ),
                if (_currentStep > 0 && details.onStepCancel != null)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
              ],
            ),
          );
        },
        onStepTapped: (int step) {
          setState(() {
            _currentStep = step;
          });
        },
        steps: [
          _stepOne(),
          _stepTwo(),
          _stepThree(),
        ],
      ),
    );
  }

  _stepThree() {
    List<String> imageUrls = [
      imageUrlControllers[0].text, // URL untuk KTP image
      imageUrlControllers[1].text, // URL untuk Selfie image
    ];
    return Step(
      state: _currentStep == 2 ? StepState.complete : StepState.indexed,
      title: const Text('Finish'),
      content: DataSeru(
          nama: nama,
          bio: bio,
          provinces: _provinces,
          selectedProvinceIndex: _selectedProvinceIndex,
          cities: _cities,
          selectedCityIndex: _selectedCityIndex,
          kecamatan: _kecamatan,
          selectedKecamatanIndex: _selectedKecamatanIndex,
          kelurahan: _kelurahan,
          selectedKelurahanIndex: _selectedKelurahanIndex,
          nik: nik,
          imageUrls: imageUrls),
      isActive: _currentStep == 2,
    );
  }

  _stepTwo() {
    return Step(
      title: const Text('Upload'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Gambar KTP'),
          const SizedBox(height: 20),
          imageFile != null
              ? Image.file(
                  imageFile!,
                  width: 320,
                  height: 100,
                )
              : SizedBox(
                  height: 100,
                  width: 320,
                  child: Image.network(
                    'https://i.ibb.co/S32HNjD/no-image.jpg',
                    fit: BoxFit.cover,
                  )),
          const SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  setState(() {
                    nik = value;
                  });
                },
                controller: nikController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'NIK',
                ),
              ),
              const SizedBox(height: 20),
              const Divider(
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 50.0,
                runSpacing: 20.0,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      pickImage(ImageSource.camera);
                    },
                    child: const Text('Foto KTP'),
                  ),
                  ElevatedButton(
                    onPressed: imageFile != null ? clearKtpImage : null,
                    child: const Text('Hapus'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
          const Text('Gambar Selfie'),
          const SizedBox(height: 20),
          fotoSelfie != null
              ? Image.file(
                  fotoSelfie!,
                  width: 320,
                  height: 100,
                )
              : SizedBox(
                  height: 100,
                  width: 320,
                  child: Image.network(
                    'https://i.ibb.co/S32HNjD/no-image.jpg',
                    fit: BoxFit.cover,
                  )),
          const SizedBox(height: 20),
          Wrap(
            spacing: 50.0,
            runSpacing: 20.0,
            children: [
              ElevatedButton(
                onPressed: () {
                  fotoDiri(ImageSource.camera);
                },
                child: const Text('Foto Selfie'),
              ),
              ElevatedButton(
                onPressed: fotoSelfie != null ? clearSelfieImage : null,
                child: const Text('Hapus'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              uploadImage();
            },
            child: isUploading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : const Text(
                    'Upload Images',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      isActive: _currentStep == 1,
    );
  }

  _stepOne() {
    return Step(
      title: const Text('Biodata'),
      content: Column(
        children: [
          TextFormField(
            controller: _namaController,
            decoration: const InputDecoration(
              labelText: "Nama",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                nama = value;
              });
            },
          ),
          const SizedBox(
            height: 20.0,
          ),
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
                labelText: "Bio", border: OutlineInputBorder()),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                bio = value;
              });
            },
          ),
          const SizedBox(
            height: 20.0,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildDropdown(_provinces, _selectedProvinceIndex!, 'Provinsi',
                  (int? newIndex) {
                setState(() {
                  _selectedProvinceIndex = newIndex!;
                  fetchCities(_provinces[_selectedProvinceIndex!]['id']);
                  _selectedCityIndex = 0;
                  _selectedKecamatanIndex = 0;
                  _selectedKelurahanIndex = 0;
                });
              }),
              const SizedBox(height: 20),
              buildDropdown(_cities, _selectedCityIndex!, 'Kota',
                  (int? newIndex) {
                setState(() {
                  _selectedCityIndex = newIndex!;
                  fetchKecamatan(_cities[_selectedCityIndex!]['id']);
                  _selectedKecamatanIndex = 0;
                  _selectedKelurahanIndex = 0;
                });
              }),
              const SizedBox(height: 20),
              buildDropdown(_kecamatan, _selectedKecamatanIndex!, 'Kecamatan',
                  (int? newIndex) {
                setState(() {
                  _selectedKecamatanIndex = newIndex!;
                  fetchKelurahan(_kecamatan[_selectedKecamatanIndex!]['id']);
                  _selectedKelurahanIndex = 0;
                });
              }),
              const SizedBox(height: 20),
              buildDropdown(_kelurahan, _selectedKelurahanIndex!, 'Kelurahan',
                  (int? newIndex) {
                setState(() {
                  _selectedKelurahanIndex = newIndex!;
                });
              }),
            ],
          ),
        ],
      ),
      isActive: _currentStep == 0,
    );
  }

  Widget buildDropdown(List<dynamic> items, int selectedIndex, String label,
      ValueChanged<int?> onChanged) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Stack(
        children: [
          DropdownButton<int>(
            value: selectedIndex,
            onChanged: onChanged,
            items: items.asMap().entries.map<DropdownMenuItem<int>>((entry) {
              return DropdownMenuItem<int>(
                value: entry.key,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    entry.value['name'],
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ),
              );
            }).toList(),
            style: const TextStyle(fontSize: 16.0, color: Colors.black),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            iconSize: 36,
            isExpanded: true,
            underline: const SizedBox(),
            hint: Text('Pilih $label'),
          ),
          if (_isLoading)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  List<String> getCapturedImagePaths() {
    return capturedImages.map((image) => image.path).toList();
  }
}
