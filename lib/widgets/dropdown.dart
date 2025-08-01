import 'package:flutter/material.dart';



class AppDropdown extends StatefulWidget {
  AppDropdown({
    Key? key,
    required this.items,
    required this.onChanged,
    this.selectedItemBuilder,
    required this.value,
    required this.hintText,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.itemHeight,
    this.fillColor,
    this.focusColor,
    this.focusNode,
    this.dropdownColor,
    this.decoration,
    this.onSaved,
    this.validator,
    this.loading, required this.showTitle, required this.title,
  }) : super(key: key);

  final ValueChanged onChanged;
  final List<DropdownMenuItem<String>>? items;
  final DropdownButtonBuilder? selectedItemBuilder;
  String? value;
  final String hintText;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final double? itemHeight;
  final Color? focusColor;
  final Color? fillColor;
  final bool showTitle;
  final String title;
  final FocusNode? focusNode;
  final Color? dropdownColor;
  final InputDecoration? decoration;
  final FormFieldSetter? onSaved;
  final FormFieldValidator? validator;
  final String? icon;
  final bool? loading;

  @override
  State<AppDropdown> createState() => _AppDropdownState();
}

class _AppDropdownState extends State<AppDropdown> {
  final bool isDense = true;

  final bool isExpanded = false;

  final bool autofocus = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if(widget.showTitle) Padding(
          padding: const EdgeInsets.only(left: 0),
          child: Row(
            children: [
              Text(widget.title, style: const TextStyle(fontSize: 13,color: Colors.white)),
              // if(validate==true)Text("*", style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),)
            ],
          ),
        ),
        if(widget.showTitle) const SizedBox(height: 5),
        Material(
          elevation: 1.8,
          shadowColor: const Color(0xffFAFDFF),
          borderRadius: BorderRadius.circular(8),

          child: DropdownButtonFormField<String>(
            isExpanded: true,
            style:  TextStyle(color: Colors.white,fontWeight: FontWeight.w400),
            hint: Text(widget.hintText,style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400),),
            dropdownColor: Colors.grey,
            value: widget.value,
            validator: widget.validator,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 9.5,
              ),
              isDense: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade100),
              ),
              focusedBorder:  OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade100),
              ),
              filled: true,
              fillColor: widget.fillColor ==null?Colors.black:widget.fillColor,
            ),
            icon: widget.loading == true
                ? SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(color: Colors.white,))
                : const Icon(Icons.keyboard_arrow_down),
            onChanged: (value) {
              setState(() {
                widget.value = value;
              });
              if (widget.onChanged != null) widget.onChanged(value);
            },
            items: widget.items,
          ),
        ),
      ],
    );
  }
}
