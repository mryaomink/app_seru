import 'package:flutter/material.dart';

Widget buildDropdown(List<dynamic> items, int selectedIndex, String label,
    ValueChanged<int?> onChanged) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: DropdownButton<int>(
      value: selectedIndex,
      onChanged: onChanged,
      items: items.asMap().entries.map<DropdownMenuItem<int>>((entry) {
        return DropdownMenuItem<int>(
          value: entry.key,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              entry.value['name'],
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        );
      }).toList(),
      style: const TextStyle(fontSize: 18.0, color: Colors.black),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
      iconSize: 36,
      isExpanded: true,
      underline: const SizedBox(),
      hint: Text('Select $label'),
    ),
  );
}
