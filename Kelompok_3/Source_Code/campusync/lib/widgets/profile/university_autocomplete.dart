import 'package:flutter/material.dart';

class UniversityAutocomplete extends StatelessWidget {
  final TextEditingController controller;
  final List<String> universities;
  final void Function(String) onSelected;
  final void Function(String) onChanged;
  final String? Function(String?)? validator;

  const UniversityAutocomplete({
    Key? key,
    required this.controller,
    required this.universities,
    required this.onSelected,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Asal Universitas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE8A5C9),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return universities.where((String option) {
                return option
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: onSelected,
            fieldViewBuilder:
                (context, controller, focusNode, onEditingComplete) {
              controller.text = this.controller.text;
              return TextFormField(
                controller: this.controller,
                focusNode: focusNode,
                validator: validator,
                onEditingComplete: () {
                  onChanged(this.controller.text);
                  onEditingComplete();
                },
                onChanged: onChanged,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  hintText: 'Choose your University',
                  hintStyle: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    width: MediaQuery.of(context).size.width - 32,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(option),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
