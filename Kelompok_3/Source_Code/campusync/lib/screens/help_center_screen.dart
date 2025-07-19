import 'package:flutter/material.dart';
import 'package:campusync/screens/help_detail_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEAE6), // Soft pink background
      appBar: AppBar(
        backgroundColor: const Color(0xFF689DB4), // Blue header
        centerTitle: false,
        elevation: 0,
        title: const Text(
          'Pusat Bantuan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: [
                  _buildHelpItem(
                    context,
                    'Bagaimana Saya bisa mencari Teman dari Universitas lain?',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpDetailScreen(
                          question:
                              'Bagaimana Saya bisa mencari Teman dari Universitas lain?',
                          answer:
                              'Untuk mencari teman dari universitas lain di CampuSync, Anda dapat menggunakan fitur pencarian yang tersedia di aplikasi. Cukup masukkan nama universitas yang Anda inginkan pada kolom pencarian, lalu aplikasi akan menampilkan daftar pengguna dari universitas tersebut yang dapat Anda jadikan teman. Selain itu, Anda juga bisa memfilter hasil pencarian berdasarkan minat atau jurusan agar lebih mudah menemukan teman yang sesuai dengan preferensi Anda.',
                        ),
                      ),
                    ),
                  ),
                  _buildHelpItem(
                    context,
                    'Bagaimana cara mengubah atau menambahkan minat Saya di Profil?',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpDetailScreen(
                          question:
                              'Bagaimana cara mengubah atau menambahkan minat Saya di Profil?',
                          answer:
                              'Untuk mengubah atau menambahkan minat (hobi) Anda di profil, buka halaman Edit Profile dari menu profil Anda. Gulir ke bawah hingga menemukan bagian bertuliskan Hobby dengan daftar pilihan. Ketuk bagian tersebut, lalu pilih minat yang paling sesuai dari daftar yang tersedia. Jika Anda belum pernah memilih sebelumnya, Anda wajib memilih salah satu agar perubahan bisa disimpan. Setelah selesai, tekan tombol Save Changes di bagian bawah layar untuk menyimpan pengaturan Anda. Jika minat Anda belum tersedia di daftar, hubungi tim pengembang untuk masukan fitur selanjutnya.',
                        ),
                      ),
                    ),
                  ),
                  _buildHelpItem(
                    context,
                    'Bagaimana cara Saya menyesuaikan preferensi Teman yang Saya cari dengan minat yang sama?',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpDetailScreen(
                          question:
                              'Bagaimana cara Saya menyesuaikan preferensi Teman yang Saya cari dengan minat yang sama?',
                          answer:
                              'Untuk menyesuaikan preferensi teman yang Anda cari berdasarkan minat yang sama di CampuSync, ikuti langkah berikut:\n\n1. Buka aplikasi CampuSync dan masuk ke fitur pencarian teman.\n2. Gunakan filter pencarian yang tersedia, seperti minat, hobi, atau jurusan."\n3. Pilih minat atau kategori yang sesuai dengan preferensi Anda. "\n4. Aplikasi akan menampilkan daftar pengguna yang memiliki minat yang sama sehingga memudahkan Anda menemukan teman yang cocok.\n\nDengan fitur ini, Anda dapat lebih mudah membangun koneksi dengan teman-teman yang memiliki kesamaan minat dan preferensi di universitas-universitas di Indonesia',
                        ),
                      ),
                    ),
                  ),
                  _buildHelpItem(
                    context,
                    'Bagaimana cara jika Saya ingin menghapus akun Saya?',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpDetailScreen(
                          question:
                              'Bagaimana cara jika Saya ingin menghapus akun Saya?',
                          answer:
                              'Anda dapat menghapus akun CampuSync Anda dengan mengikuti langkah-langkah berikut:\n\n1. Masuk ke aplikasi CampuSync dan buka menu pengaturan di Profil Anda.\n2. Cari opsi "Hapus Akun" atau "Delete Account".\n3. Ikuti instruksi yang diberikan untuk konfirmasi penghapusan akun.\n4. Harap diperhatikan bahwa penghapusan akun bersifat permanen dan semua data Anda akan dihapus secara permanen dari sistem. \n\nJika Anda memerlukan bantuan lebih lanjut, jangan ragu menghubungi tim support CampuSync melalui email atau fitur chat.',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(
      BuildContext context, String question, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE0E0E0),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF666666),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF689DB4),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Pertanyaan Lainnya',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Jika Anda memiliki pertanyaan lain yang tidak terdapat dalam daftar FAQ, '
            'silakan hubungi tim support kami melalui:\n\n'
            'Email: campusyc01@gmail.com\n'
            'WhatsApp: +62 856-5570-7689\n\n'
            'Tim kami akan merespons dalam 1x24 jam.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF689DB4),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
