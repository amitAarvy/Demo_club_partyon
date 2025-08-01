import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class AppMultiDropdown extends StatelessWidget {
  final List<DropdownItem<String>> items;
  final String title;
  final OnSelectionChanged onSelectionChanged;
  final bool loading;
  const AppMultiDropdown({super.key, required this.items, required this.title, required this.onSelectionChanged, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: MultiDropdown<String>(
        items: items,
        chipDecoration: ChipDecoration(
          labelStyle: TextStyle(color: Colors.white),
          deleteIcon: Icon(Icons.cancel, color: Colors.white, size: 18,),
          backgroundColor: Colors.black,
            borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 0.5)
        ),
        onSelectionChange: onSelectionChanged,
        dropdownDecoration: DropdownDecoration(
          backgroundColor: Colors.black,
        ),
        dropdownItemDecoration: DropdownItemDecoration(
          textColor: Colors.white,
          selectedBackgroundColor: Colors.grey.withOpacity(0.3),
          selectedTextColor: Colors.white,
        ),
        fieldDecoration: FieldDecoration(
            borderRadius: 1000,
            labelText: title,
            labelStyle: GoogleFonts.merriweather(color: Colors.white, fontWeight: FontWeight.w300, fontSize: 14),
            hintText: "",
            showClearIcon: false,
            suffixIcon: loading
                    ? CircularProgressIndicator()
                : const Icon(Icons.arrow_drop_down_rounded, size: 25, color: Colors.white),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white70, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              const BorderSide(color: Colors.blue, width: 1.0)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              const BorderSide(color: Colors.red, width: 1.0)),
        ),
      ),
    );
  }
}
