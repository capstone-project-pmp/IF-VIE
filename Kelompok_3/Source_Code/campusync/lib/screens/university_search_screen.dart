import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:campusync/screens/profile_screen.dart';
import 'package:campusync/screens/filter_screen.dart';

class UniversitySearchScreen extends StatefulWidget {
  const UniversitySearchScreen({Key? key}) : super(key: key);

  @override
  State<UniversitySearchScreen> createState() => _UniversitySearchScreenState();
}

class _UniversitySearchScreenState extends State<UniversitySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _universityList = [];
  String _searchMode = 'university';
  String _searchHint = 'Choose Your University';

  // Tambahkan variabel untuk auto filter
  bool _showFilteredResults = false;
  Stream<QuerySnapshot>? _currentStream;

  // Filter variables
  Map<String, dynamic> _currentFilters = {
    'prodi': null,
    'gender': null,
    'hobby': null,
  };

  @override
  void initState() {
    super.initState();
    _loadUniversities();

    // Auto search saat text berubah
    _searchController.addListener(() {
      setState(() {
        _showFilteredResults =
            _searchController.text.trim().isNotEmpty || _hasActiveFilters();
      });
      _updateStream();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUniversities() async {
    try {
      final response = await rootBundle.loadString('assets/universities.json');
      final data = jsonDecode(response);
      setState(() {
        _universityList =
            List<String>.from(data.map((e) => e['nama_institusi']));
      });
    } catch (e) {
      debugPrint('Error loading universities: $e');
    }
  }

  void _changeSearchMode(String mode) {
    setState(() {
      _searchMode = mode;
      _searchHint = mode == 'university'
          ? 'Choose Your University'
          : 'Search by username...';
      _searchController.clear();
      _showFilteredResults = _hasActiveFilters();
    });
    _updateStream();
    FocusScope.of(context).unfocus();
  }

  void _openFilterScreen() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(currentFilters: _currentFilters),
      ),
    );

    if (result != null) {
      setState(() {
        _currentFilters = result;
        // Otomatis show results jika ada filter aktif
        _showFilteredResults =
            _hasActiveFilters() || _searchController.text.trim().isNotEmpty;
      });

      // Update stream untuk auto search
      _updateStream();

      // Debug: Print filter yang dipilih
      print('=== FILTER DEBUG ===');
      print('Selected filters: $_currentFilters');
      print('Show filtered results: $_showFilteredResults');
    }
  }

  // Method untuk cek apakah ada filter aktif
  bool _hasActiveFilters() {
    return _currentFilters['prodi'] != null ||
        _currentFilters['gender'] != null ||
        _currentFilters['hobby'] != null;
  }

  // Method untuk update stream
  void _updateStream() {
    if (_showFilteredResults) {
      setState(() {
        _currentStream = _getStream();
      });
    } else {
      setState(() {
        _currentStream = null;
      });
    }
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (_currentFilters['prodi'] != null) count++;
    if (_currentFilters['gender'] != null) count++;
    if (_currentFilters['hobby'] != null) count++;
    return count;
  }

  // Method untuk clear semua filter
  void _clearAllFilters() {
    setState(() {
      _currentFilters = {
        'prodi': null,
        'gender': null,
        'hobby': null,
      };
      _showFilteredResults = _searchController.text.trim().isNotEmpty;
    });
    _updateStream();
  }

  @override
  Widget build(BuildContext context) {
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
          'Pencarian',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF5E6D3),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8A5C9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.black),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: _searchHint,
                              hintStyle: const TextStyle(color: Colors.black54),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon:
                              const Icon(Icons.more_vert, color: Colors.black),
                          onSelected: _changeSearchMode,
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'university',
                              child: Row(
                                children: [
                                  Icon(Icons.school, size: 18),
                                  SizedBox(width: 8),
                                  Text('Search University'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'username',
                              child: Row(
                                children: [
                                  Icon(Icons.person, size: 18),
                                  SizedBox(width: 8),
                                  Text('Search Username'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _openFilterScreen,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getActiveFiltersCount() > 0
                          ? const Color(0xFF5B9BD5)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getActiveFiltersCount() > 0
                            ? const Color(0xFF5B9BD5)
                            : Colors.grey,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_alt,
                          color: _getActiveFiltersCount() > 0
                              ? Colors.white
                              : Colors.grey[600],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getActiveFiltersCount() > 0
                              ? 'Filter (${_getActiveFiltersCount()})'
                              : 'Filter',
                          style: TextStyle(
                            color: _getActiveFiltersCount() > 0
                                ? Colors.white
                                : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active Filters Display dengan tombol clear
          if (_getActiveFiltersCount() > 0)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF5B9BD5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF5B9BD5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Aktif:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5B9BD5),
                        ),
                      ),
                      GestureDetector(
                        onTap: _clearAllFilters,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Clear All',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (_currentFilters['prodi'] != null)
                        _buildFilterChip('Prodi: ${_currentFilters['prodi']}'),
                      if (_currentFilters['gender'] != null)
                        _buildFilterChip(
                            'Gender: ${_currentFilters['gender']}'),
                      if (_currentFilters['hobby'] != null)
                        _buildFilterChip('Hobby: ${_currentFilters['hobby']}'),
                    ],
                  ),
                ],
              ),
            ),

          if (_getActiveFiltersCount() > 0) const SizedBox(height: 8),

          // Autocomplete for University
          if (_searchMode == 'university' && _searchController.text.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: _universityList
                    .where((uni) => uni
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase()))
                    .take(5)
                    .map((uni) => ListTile(
                          title: Text(uni,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black)),
                          onTap: () {
                            _searchController.text = uni;
                            setState(() {
                              _showFilteredResults = true;
                            });
                            _updateStream();
                            FocusScope.of(context).unfocus();
                          },
                        ))
                    .toList(),
              ),
            ),

          // Auto search notification
          if (_showFilteredResults &&
              _searchController.text.isEmpty &&
              _hasActiveFilters())
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome,
                      color: Colors.green.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Menampilkan hasil berdasarkan filter yang dipilih',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Results
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF5B9BD5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildResults() {
    // Jika tidak ada filter aktif dan tidak ada search text, tampilkan placeholder
    if (!_showFilteredResults) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchMode == 'university' ? Icons.school : Icons.person_search,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _searchMode == 'university'
                ? 'Pilih universitas atau gunakan filter untuk melihat mahasiswa'
                : 'Ketik username atau gunakan filter untuk mencari',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
        ],
      ));
    }

    // Jika ada filter aktif atau search text, tampilkan results
    return StreamBuilder<QuerySnapshot>(
      stream: _currentStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Mencari...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          print('Firestore error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Error loading data'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _updateStream(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<DocumentSnapshot> allUsers = snapshot.data?.docs ?? [];

        // Enhanced Debug
        print('\n=== ENHANCED DEBUG ===');
        print('Search text: "${_searchController.text.trim()}"');
        print('Search mode: $_searchMode');
        print('Active filters: $_currentFilters');
        print('Show filtered results: $_showFilteredResults');
        print('Total users from Firestore: ${allUsers.length}');

        // Apply client-side filtering
        List<DocumentSnapshot> filteredUsers =
            _applyClientSideFilters(allUsers);

        print('\n--- FILTER RESULTS ---');
        print('Users after client-side filtering: ${filteredUsers.length}');

        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _searchMode == 'university'
                      ? 'Tidak ada mahasiswa yang sesuai dengan filter'
                      : 'Pengguna tidak ditemukan',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                if (_getActiveFiltersCount() > 0) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Coba kurangi filter untuk hasil lebih banyak',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _clearAllFilters,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear All Filters'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index].data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5D5D5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: user['photoUrl'] != null
                      ? NetworkImage(user['photoUrl'])
                      : null,
                  backgroundColor: Colors.grey[300],
                  child: user['photoUrl'] == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                title: Text(
                  '${user['fullname'] ?? 'Unknown'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Username: ${user['username'] ?? 'Unknown'}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    Text(
                      'Gender: ${user['gender'] ?? 'Unknown'}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    Text(
                      'Ketertarikan: ${user['hobbies'] ?? 'Unknown'}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    Text(
                      'Prodi: ${user['prodi'] ?? 'Unknown'}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProfileScreen(uid: user['uid'])),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Client-side filtering untuk hasil yang lebih akurat
  List<DocumentSnapshot> _applyClientSideFilters(List<DocumentSnapshot> users) {
    print('\n=== CLIENT SIDE FILTER DEBUG ===');
    print('Current filters: $_currentFilters');
    print('Total users before filter: ${users.length}');

    int passedCount = 0;
    int failedProdi = 0;
    int failedGender = 0;
    int failedHobby = 0;

    final filtered = users.where((doc) {
      final user = doc.data() as Map<String, dynamic>;

      // Filter Prodi
      if (_currentFilters['prodi'] != null) {
        final userProdi = user['prodi']?.toString().trim() ?? '';
        final filterProdi = _currentFilters['prodi'].toString().trim();

        if (userProdi.toLowerCase() != filterProdi.toLowerCase()) {
          failedProdi++;
          return false;
        }
      }

      // Filter Gender
      if (_currentFilters['gender'] != null) {
        final userGender = user['gender']?.toString().trim() ?? '';
        final filterGender = _currentFilters['gender'].toString().trim();

        if (userGender.toLowerCase() != filterGender.toLowerCase()) {
          failedGender++;
          return false;
        }
      }

      // Filter Hobby
      if (_currentFilters['hobby'] != null) {
        final userHobbies = user['hobbies'];
        final filterHobby = _currentFilters['hobby'].toString().trim();

        bool hobbyMatch = false;

        if (userHobbies is String) {
          final userHobbiesStr = userHobbies.trim();
          hobbyMatch = userHobbiesStr
                  .toLowerCase()
                  .contains(filterHobby.toLowerCase()) ||
              userHobbiesStr.toLowerCase() == filterHobby.toLowerCase();
        } else if (userHobbies is List) {
          hobbyMatch = userHobbies.any((hobby) {
            final hobbyStr = hobby.toString().trim();
            return hobbyStr.toLowerCase().contains(filterHobby.toLowerCase()) ||
                hobbyStr.toLowerCase() == filterHobby.toLowerCase();
          });
        }

        if (!hobbyMatch) {
          failedHobby++;
          return false;
        }
      }

      passedCount++;
      return true;
    }).toList();

    print('\n=== FILTER SUMMARY ===');
    print('Total users: ${users.length}');
    print('Passed all filters: $passedCount');
    print('Failed prodi: $failedProdi');
    print('Failed gender: $failedGender');
    print('Failed hobby: $failedHobby');

    return filtered;
  }

  Stream<QuerySnapshot> _getStream() {
    Query query = FirebaseFirestore.instance.collection('users');

    // Jika ada filter aktif tapi tidak ada search text, ambil semua users
    if (_hasActiveFilters() && _searchController.text.trim().isEmpty) {
      // Ambil semua users untuk di-filter di client side
      return query.limit(100).snapshots();
    }

    // Base query berdasarkan search mode
    if (_searchMode == 'university') {
      if (_searchController.text.trim().isNotEmpty) {
        query =
            query.where('university', isEqualTo: _searchController.text.trim());
      }
    } else {
      final searchText = _searchController.text.trim();
      if (searchText.isNotEmpty) {
        query = query
            .where('username', isGreaterThanOrEqualTo: searchText)
            .where('username', isLessThan: '$searchText\uf8ff')
            .limit(50);
      }
    }

    // Hanya gunakan satu filter di Firestore untuk performa
    if (_currentFilters['gender'] != null) {
      query = query.where('gender', isEqualTo: _currentFilters['gender']);
    }

    return query.snapshots();
  }
}
