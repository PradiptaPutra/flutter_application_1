class Question {
  final String no;
  final String indikator;
  final String subIndikator;
  final String kriteria;

  Question({
    required this.no,
    required this.indikator,
    required this.subIndikator,
    required this.kriteria,
  });
}

final List<Question> questions = [
  Question(
    no: '1.1',
    indikator: 'Sistem Vertikal Bangunan Lebih dari 1 Lantai',
    subIndikator: 'Tangga',
    kriteria: 'Jika ada beberapa tangga dalam satu bangunan, tangga yang diukur adalah tangga yang paling besar dan/atau menghubungkan ruangan yang memiliki fungsi vital di layanan kesehatan tersebut (Contoh: IGD, bangsal, poli).\nStandar Tangga:\nTinggi anak tangga (h) antara 15 – 17 cm.\n≤ 1\nMemiliki rambu petunjuk evakuasi.\nh = tinggi anak tangga\nl = lebar tangga\nKriteria:\n● Ada dan sesuai standar = 2\n● Ada dan tidak sesuai standar = 1\n● Tidak ada = 0',
  ),
  Question(
    no: '1.2',
    indikator: 'Sistem Vertikal Bangunan Lebih dari 1 Lantai',
    subIndikator: 'Ram',
    kriteria: 'Standar ram:\nMemiliki kemiringan sesuai standar\nMemiliki lebar (I) ≤ 120 cm.Kemiringan ram diukur dengan menghitung ketinggian pada jarak 1m dari ujung ram. Standar tinggi ram pada jarak 1m dari ujung ram adalah (h = 12,5 cm).\n● Ada dan sesuai standar = 2\n● Ada dan tidak sesuai standar = 1\n● Tidak ada = 0',
  ),
  Question(
    no: '2.1',
    indikator: 'Sistem Sanitasi',
    subIndikator: 'Sistem Air Bersih',
    kriteria: 'Standar air bersih adalah air bisa dialirkan melalui keran air dan air dalam kondisi baik (ditinjau dari segi bau dan warna)\n● Ada dan sesuai standar = 2\n● Ada dan tidak sesuai standar = 1\n● Tidak ada = 0',
  ),
  Question(
    no: '2.2',
    indikator: 'Sistem Sanitasi',
    subIndikator: 'Sistem Penyaluran Air Kotor dan/atau Limbah',
    kriteria: 'Standar sistem penyaluran air kotor dan atau limbah adalah memiliki septicktank, memiliki sumur resapan, dan aluran air limbah kedap air, bersih dari sampah dan dilengkapi penutup\n● Ada dan sesuai standar = 2\n● Ada dan tidak sesuai standar = 1\n● Tidak ada = 0',
  ),
  Question(
    no: '2.3',
    indikator: 'Sistem Sanitasi',
    subIndikator: 'Sistem Pembuangan Limbah Infeksius',
    kriteria: '● Limbah dipisah, dikumpul dan diolah sendiri atau diolah orang lain = 2\n● Dikumpul, tidak dipisah dan tidak diolah = 1\n● Tidak ada = 0',
  ),
  Question(
    no: '3.1',
    indikator: 'Sistem Kelistrikan',
    subIndikator: 'Penerangan',
    kriteria: '● Sumber penerangan (lampu) dapat dioperasikan di bangunan fasilitas kesehatan dan berfungsi sebagai mana mestinya = 2\n● Sumber penerangan (lampu) ada, namun tidak dapat dioperasikan atau tidak memadai untuk penerangan = 1\n● Tidak tersedia = 0',
  ),
  Question(
    no: '3.2',
    indikator: 'Sistem Kelistrikan',
    subIndikator: 'Operasional Alat',
    kriteria: '● Jika aliran listrik tersedia dan alat bisa digunakan seperti biasanya = 2\n● Alatnya bisa digunakan hanya saja aliran listrik yang tidak tersedia = 1\n● Tidak ada aliran listrik dan tidak ada alat = 0',
  ),
  Question(
    no: '3.3',
    indikator: 'Sistem Kelistrikan',
    subIndikator: 'Listrik Cadangan',
    kriteria: 'Standar listrik darurat jika sumber dari PLN padam:\nKapasitasnya 75% dari 2200VA\n● Tersedianya sumber listrik sesuai standar dan bisa digunakan, serta sesuai dengan standar. Sebutkan sumbernya = 2\n● Tersedianya sumber listrik yang sesuai standar akan tetapi tidak bisa digunakan = 1\n● Tidak tersedia = 0',
  ),
  Question(
    no: '4',
    indikator: 'Sistem Komunikasi',
    subIndikator: 'Jenis Komunikasi',
    kriteria: 'Sistem Komunikasi adalah seperangkat komponen dan peralatan komunikasi yang memiliki fungsi komunikasi dan menghasilkan output untuk tujuan komunikasi\n● Memiliki 2 jaringan komunikasi = 2\n● Memiliki 1 jaringan komunikasi = 1\n● Jaringan Komunikasi terputus = 0',
  ),
  Question(
    no: '5',
    indikator: 'Sistem Gas Medik',
    subIndikator: '',
    kriteria: 'Sistem gas medik adalah instalasi kebutuhan gas untuk keperluan medis di fasilitas pelayanan kesehatan. Salah satu contohnya adalah oksigen. Pilih: Sentral / Tabung\nKriteria:\n● Ada (baik sentral maupun tabung) dan berfungsi = 2\n● Ada (baik sentral maupun tabung) dan tidak berfungsi = 1\n● Tidak ada = 0',
  ),
  Question(
    no: '6.1',
    indikator: 'Sistem K3 Fasyankes',
    subIndikator: 'APAR',
    kriteria: 'Standar APAR:\n-Pemasangannya 125 cm dari dasar lantai\n-Jarak pemasangan antara APAR tidak boleh melebihi 15 meter\n-Semua tabung APAR sebaiknya warna merah\nKriteria:\n● Jika ada alat proteksi kebakaran, sesuai standar dan berfungsi = 2\n● Ada, tidak sesuai standar dan/atau tidak berfungsi =1\n● Tidak ada alat proteksi kebakaran = 0',
  ),
  Question(
    no: '6.2',
    indikator: 'Sistem K3 Fasyankes',
    subIndikator: 'Jalur Evakuasi',
    kriteria: 'Jalur evakuasi adalah jalur yang digunakan ketika dalam keadaan darurat, seperti kebakaran, gempa bumi, dan keadaan darurat lainnya yang dapat mengancam jiwa seseorang ketika sedang berada dalam bangunan fasilitas pelayanan kesehatan\nStandar jalur evakuasi adalah memiliki tanda jalur evakuasi/evacuation route, memiliki tanda keluar/exit, dan ada titik kumpul/Assembly point\nKriteria:\n● Fasyankes memiliki jalur evakuasi sesuai standar = 2\n● Fasyankes memiliki jalur evakuasi tapi tidak sesuai standar = 1\n● Tidak ada jalur evakuasi = 0',
  ),
  // Add more questions here if necessary...
];
