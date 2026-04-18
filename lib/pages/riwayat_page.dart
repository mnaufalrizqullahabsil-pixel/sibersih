import 'package:flutter/material.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _filter = 'Semua';

  final List<_RiwayatItem> _allItems = [
    _RiwayatItem(
      emoji: '🥤',
      jenis: 'Plastik',
      berat: '1.2 kg',
      poin: 120,
      tanggal: '4 Apr 2025',
      waktu: '09:35',
      status: 'Terverifikasi',
      lokasi: 'Depan Gedung A',
    ),
    _RiwayatItem(
      emoji: '📰',
      jenis: 'Kertas',
      berat: '0.8 kg',
      poin: 80,
      tanggal: '3 Apr 2025',
      waktu: '14:20',
      status: 'Terverifikasi',
      lokasi: 'Perpustakaan',
    ),
    _RiwayatItem(
      emoji: '🥫',
      jenis: 'Logam',
      berat: '2.5 kg',
      poin: 250,
      tanggal: '1 Apr 2025',
      waktu: '11:00',
      status: 'Terverifikasi',
      lokasi: 'Kantin Kampus',
    ),
    _RiwayatItem(
      emoji: '🍂',
      jenis: 'Organik',
      berat: '3.0 kg',
      poin: 0,
      tanggal: '30 Mar 2025',
      waktu: '08:15',
      status: 'Menunggu',
      lokasi: 'Taman Kampus',
    ),
    _RiwayatItem(
      emoji: '🪟',
      jenis: 'Kaca',
      berat: '1.8 kg',
      poin: 216,
      tanggal: '28 Mar 2025',
      waktu: '16:45',
      status: 'Terverifikasi',
      lokasi: 'Lab Kimia',
    ),
    _RiwayatItem(
      emoji: '📱',
      jenis: 'Elektronik',
      berat: '0.5 kg',
      poin: 0,
      tanggal: '25 Mar 2025',
      waktu: '13:30',
      status: 'Ditolak',
      lokasi: 'Ruang IT',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_RiwayatItem> get _filteredItems {
    switch (_tabController.index) {
      case 1:
        return _allItems
            .where((i) => i.status == 'Terverifikasi')
            .toList();
      case 2:
        return _allItems
            .where((i) => i.status == 'Menunggu' || i.status == 'Ditolak')
            .toList();
      default:
        return _allItems;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Stats
    final totalBerat = _allItems
        .where((i) => i.status == 'Terverifikasi')
        .map((i) =>
            double.parse(i.berat.replaceAll(' kg', '')))
        .fold(0.0, (a, b) => a + b);
    final totalPoin = _allItems
        .where((i) => i.status == 'Terverifikasi')
        .map((i) => i.poin)
        .fold(0, (a, b) => a + b);

    return Scaffold(
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            title: const Text(
              'Riwayat Laporan',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            centerTitle: true,
            backgroundColor: const Color(0xFF1007BA),
            foregroundColor: Colors.white,
            pinned: true,
            expandedHeight: 220,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0A05A0), Color(0xFF2519D4)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Row(
                        children: [
                          _statCard(
                              '📦', '${_allItems.length}', 'Total Laporan',
                              Colors.blue.shade200),
                          const SizedBox(width: 12),
                          _statCard(
                              '⚖️',
                              '${totalBerat.toStringAsFixed(1)} kg',
                              'Total Sampah',
                              Colors.green.shade200),
                          const SizedBox(width: 12),
                          _statCard('⭐', '$totalPoin',
                              'Total Poin', Colors.amber.shade200),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: 'Semua'),
                Tab(text: 'Terverifikasi'),
                Tab(text: 'Proses'),
              ],
              onTap: (_) => setState(() {}),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildList(_allItems),
            _buildList(_allItems
                .where((i) => i.status == 'Terverifikasi')
                .toList()),
            _buildList(_allItems
                .where((i) =>
                    i.status == 'Menunggu' || i.status == 'Ditolak')
                .toList()),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
      String emoji, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<_RiwayatItem> items) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📭', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text(
              'Belum ada riwayat',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              'Mulai buang sampah & dapatkan poin!',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (_, i) => _RiwayatCard(item: items[i], index: i),
    );
  }
}

class _RiwayatCard extends StatefulWidget {
  final _RiwayatItem item;
  final int index;

  const _RiwayatCard({required this.item, required this.index});

  @override
  State<_RiwayatCard> createState() => _RiwayatCardState();
}

class _RiwayatCardState extends State<_RiwayatCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnim = CurvedAnimation(
        parent: _expandController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.item.status) {
      case 'Terverifikasi':
        return Colors.green;
      case 'Menunggu':
        return Colors.orange;
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get _statusEmoji {
    switch (widget.item.status) {
      case 'Terverifikasi':
        return '✅';
      case 'Menunggu':
        return '⏳';
      case 'Ditolak':
        return '❌';
      default:
        return '❓';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() => _expanded = !_expanded);
        if (_expanded) {
          _expandController.forward();
        } else {
          _expandController.reverse();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _expanded
                ? const Color(0xFF1007BA).withOpacity(0.3)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1007BA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(widget.item.emoji,
                          style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Sampah ${widget.item.jenis}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color:
                                    _statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$_statusEmoji ${widget.item.status}',
                                style: TextStyle(
                                  color: _statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.scale_rounded,
                                size: 13, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              widget.item.berat,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.access_time_rounded,
                                size: 13, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.item.tanggal} · ${widget.item.waktu}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Points and expand
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1007BA), Color(0xFF4C3FE8)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.item.poin > 0
                          ? '⭐ +${widget.item.poin} Poin'
                          : '⭐ Poin Pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Expanded detail
            SizeTransition(
              sizeFactor: _expandAnim,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1007BA).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _detailRow(
                          Icons.location_on_outlined,
                          'Lokasi',
                          widget.item.lokasi),
                      const Divider(height: 16),
                      _detailRow(Icons.category_outlined, 'Jenis',
                          widget.item.jenis),
                      const Divider(height: 16),
                      _detailRow(Icons.scale_rounded, 'Berat',
                          widget.item.berat),
                      const Divider(height: 16),
                      _detailRow(Icons.verified_rounded, 'Status',
                          widget.item.status),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1007BA)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _RiwayatItem {
  final String emoji,
      jenis,
      berat,
      tanggal,
      waktu,
      status,
      lokasi;
  final int poin;

  _RiwayatItem({
    required this.emoji,
    required this.jenis,
    required this.berat,
    required this.poin,
    required this.tanggal,
    required this.waktu,
    required this.status,
    required this.lokasi,
  });
}
