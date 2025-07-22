import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FilterScreen extends StatefulWidget {
  final Map<String, dynamic> currentFilters;

  const FilterScreen({
    Key? key,
    required this.currentFilters,
  }) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  List<String> _prodiOptions = [];
  List<String> _hobbyOptions = [];
  final List<String> _genderOptions = ['Laki-laki', 'Perempuan', 'Lainnya'];

  // Filter selections
  String? _selectedProdi;
  String? _selectedGender;
  String? _selectedHobby;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _loadProdiOptions(),
      _loadHobbies(),
    ]);

    // Set current filters
    _selectedProdi = widget.currentFilters['prodi'];
    _selectedGender = widget.currentFilters['gender'];
    _selectedHobby = widget.currentFilters['hobby'];

    setState(() => _isLoading = false);
  }

  // Tambahkan di method _loadProdiOptions() dan _loadHobbies()
  Future<void> _loadProdiOptions() async {
    try {
      final response = await rootBundle.loadString('assets/prodi.json');
      final data = jsonDecode(response);
      _prodiOptions = List<String>.from(data.map((e) => e['nama_prodi']));
      _prodiOptions.sort();

      // Debug: Print prodi options
      print('=== PRODI OPTIONS ===');
      _prodiOptions.forEach((prodi) => print('  "$prodi"'));
    } catch (e) {
      debugPrint('Error loading prodi: $e');
    }
  }

  Future<void> _loadHobbies() async {
    try {
      final response = await rootBundle.loadString('assets/hobbies.json');
      final data = jsonDecode(response);
      _hobbyOptions = List<String>.from(data.map((e) => e['nama_hobi']));
      _hobbyOptions.sort();

      // Debug: Print hobby options
      print('=== HOBBY OPTIONS ===');
      _hobbyOptions.forEach((hobby) => print('  "$hobby"'));
    } catch (e) {
      debugPrint('Error loading hobbies: $e');
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedProdi = null;
      _selectedGender = null;
      _selectedHobby = null;
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{
      'prodi': _selectedProdi,
      'gender': _selectedGender,
      'hobby': _selectedHobby,
    };
    Navigator.pop(context, filters);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5E6D3),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF689DB4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: const Text(
          'Filter Pencarian',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Filters Count
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.tune, color: Color(0xFF5B9BD5)),
                        const SizedBox(width: 12),
                        Text(
                          'Filter Aktif: ${_getActiveFiltersCount()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Program Studi Filter
                  _buildFilterSection(
                    'Program Studi',
                    Icons.school,
                    _selectedProdi,
                    _prodiOptions,
                    (value) => setState(() => _selectedProdi = value),
                    const Color(0xFFB8C5D1),
                  ),

                  const SizedBox(height: 20),

                  // Gender Filter
                  _buildFilterSection(
                    'Gender',
                    Icons.person,
                    _selectedGender,
                    _genderOptions,
                    (value) => setState(() => _selectedGender = value),
                    const Color(0xFFE8A5C9),
                  ),

                  const SizedBox(height: 20),

                  // Hobby Filter
                  _buildFilterSection(
                    'Hobby',
                    Icons.interests,
                    _selectedHobby,
                    _hobbyOptions,
                    (value) => setState(() => _selectedHobby = value),
                    const Color(0xFFB8C5D1),
                  ),

                  const SizedBox(height: 30),

                  // Selected Filters Preview
                  if (_hasActiveFilters()) ...[
                    const Text(
                      'Filter yang Dipilih:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _buildFilterChips(),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearAllFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Reset Filter',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B9BD5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Terapkan Filter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    IconData icon,
    String? selectedValue,
    List<String> options,
    ValueChanged<String?> onChanged,
    Color backgroundColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              hint: Text(
                'Pilih $title',
                style: const TextStyle(color: Colors.black54),
              ),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              dropdownColor: backgroundColor,
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'Semua $title',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                ...options.map((option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(
                        option,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    )),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (_selectedProdi != null) count++;
    if (_selectedGender != null) count++;
    if (_selectedHobby != null) count++;
    return count;
  }

  bool _hasActiveFilters() {
    return _selectedProdi != null ||
        _selectedGender != null ||
        _selectedHobby != null;
  }

  List<Widget> _buildFilterChips() {
    List<Widget> chips = [];

    if (_selectedProdi != null) {
      chips.add(_buildFilterChip('Prodi: $_selectedProdi', () {
        setState(() => _selectedProdi = null);
      }));
    }

    if (_selectedGender != null) {
      chips.add(_buildFilterChip('Gender: $_selectedGender', () {
        setState(() => _selectedGender = null);
      }));
    }

    if (_selectedHobby != null) {
      chips.add(_buildFilterChip('Hobby: $_selectedHobby', () {
        setState(() => _selectedHobby = null);
      }));
    }

    return chips;
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF5B9BD5).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5B9BD5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF5B9BD5),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: Color(0xFF5B9BD5),
            ),
          ),
        ],
      ),
    );
  }
}
