import 'package:flutter/material.dart';

class DataSeru extends StatelessWidget {
  const DataSeru({
    super.key,
    required this.nama,
    required this.bio,
    required List provinces,
    required int? selectedProvinceIndex,
    required List cities,
    required int? selectedCityIndex,
    required List kecamatan,
    required int? selectedKecamatanIndex,
    required List kelurahan,
    required int? selectedKelurahanIndex,
    required this.nik,
    required this.imageUrls,
  })  : _provinces = provinces,
        _selectedProvinceIndex = selectedProvinceIndex,
        _cities = cities,
        _selectedCityIndex = selectedCityIndex,
        _kecamatan = kecamatan,
        _selectedKecamatanIndex = selectedKecamatanIndex,
        _kelurahan = kelurahan,
        _selectedKelurahanIndex = selectedKelurahanIndex;

  final String nama;
  final String bio;
  final List _provinces;
  final int? _selectedProvinceIndex;
  final List _cities;
  final int? _selectedCityIndex;
  final List _kecamatan;
  final int? _selectedKecamatanIndex;
  final List _kelurahan;
  final int? _selectedKelurahanIndex;
  final String nik;
  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      primary: false,
      padding: const EdgeInsets.all(16.0),
      children: [
        ListTile(
          title: const Text(
            'Nama',
            style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
          subtitle: Text(nama),
        ),
        ListTile(
          title: const Text('Bio',
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          subtitle: Text(bio),
        ),
        ListTile(
          title: const Text('Provinsi',
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          subtitle: Text(_provinces.isNotEmpty
              ? _provinces[_selectedProvinceIndex!]['name']
              : 'Belum Dipilih'),
        ),
        ListTile(
          title: const Text('Kota',
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          subtitle: Text(_cities.isNotEmpty
              ? _cities[_selectedCityIndex!]['name']
              : 'Belum Dipilih'),
        ),
        ListTile(
          title: const Text('Kecamatan',
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          subtitle: Text(_kecamatan.isNotEmpty
              ? _kecamatan[_selectedKecamatanIndex!]['name']
              : 'Belum Dipilih'),
        ),
        ListTile(
          title: const Text('Kelurahan',
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          subtitle: Text(_kelurahan.isNotEmpty
              ? _kelurahan[_selectedKelurahanIndex!]['name']
              : 'Belum Dipilih'),
        ),
        ListTile(
          title: const Text('NIK',
              style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          subtitle: Text(nik),
        ),
        ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: SizedBox(
              height: 60,
              width: 60,
              child: Image.network(
                imageUrls[0],
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: const Text(
            'Foto KTP',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle:
              Text(imageUrls.isNotEmpty ? imageUrls[0] : 'Belum Diupload'),
        ),
        ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: SizedBox(
              height: 60,
              width: 60,
              child: Image.network(
                imageUrls[1],
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: const Text(
            'Fot Selfie',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle:
              Text(imageUrls.length > 1 ? imageUrls[1] : 'Belum Diupload'),
        ),
        // Add other ListTiles as needed
      ],
    );
  }
}
