import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DailyList',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> archivedTasks = [];
  int _selectedIndex = 0; // Untuk menentukan halaman yang aktif

  List<String> notes = [];
  final TextEditingController _noteController = TextEditingController();

  List<Offset?> points = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 5.0;

  // Fungsi untuk menambah tugas baru
  void _addTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTask = '';
        return AlertDialog(
          title: const Text('Tambah Tugas Baru'),
          content: TextField(
            onChanged: (value) {
              newTask = value;
            },
            decoration: const InputDecoration(hintText: 'Masukkan nama tugas'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Tambah'),
              onPressed: () {
                setState(() {
                  tasks.add({'name': newTask, 'isChecked': false});
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menghapus tugas
  void _removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  // Fungsi untuk menambah catatan baru
  void _addNote() {
    if (_noteController.text.isNotEmpty) {
      setState(() {
        notes.add(_noteController.text);
        _noteController.clear();
      });
    }
  }

  // Fungsi untuk menghapus catatan
  void _removeNote(int index) {
    setState(() {
      notes.removeAt(index);
    });
  }

  // Fungsi untuk membersihkan gambar
  void _clearDrawing() {
    setState(() {
      points.clear();
    });
  }

  // Fungsi untuk berpindah ke halaman arsip
  void _goToArchivePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArchivePage(
          archivedTasks: archivedTasks,
          clearArchive: _clearArchive, // Tambahkan fungsi clear
        ),
      ),
    );
  }


  // Fungsi untuk menghapus semua arsip
  void _clearArchive() {
    setState(() {
      archivedTasks.clear();
    });
  }

  // Halaman Beranda (Tugas)
  Widget _buildTasksPage() {
    return Column(
      children: [
        Expanded(
          child: tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.note_add,
                          size: 100, color: Colors.pink.shade200),
                      const Text(
                        'Mulailah menjadwalkan tugas-tugas anda agar lebih produktif',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Checkbox(
                        value: tasks[index]['isChecked'],
                        onChanged: (value) {
                          setState(() {
                            tasks[index]['isChecked'] = value!;
                            if (tasks[index]['isChecked']) {
                              archivedTasks.add(tasks[index]);
                              tasks.removeAt(index);
                            }
                          });
                        },
                      ),
                      title: Text(
                        tasks[index]['name'],
                        style: TextStyle(
                          decoration: tasks[index]['isChecked']
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () => _removeTask(index),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Halaman Catatan
  Widget _buildNotesPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  onSubmitted: (value) {
                    _addNote();
                  },
                  decoration: const InputDecoration(
                    labelText: 'Tulis catatan baru...',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                color: Colors.pink,
                onPressed: _addNote,
              )
            ],
          ),
        ),
        Expanded(
          child: notes.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada catatan',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(notes[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () => _removeNote(index),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Halaman Coretan
  Widget _buildDrawingPage() {
    return Stack(
      children: [
        GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              points.add(details.localPosition);
            });
          },
          onPanEnd: (details) {
            points.add(null);
          },
          child: CustomPaint(
            painter: DrawingPainter(points, selectedColor, strokeWidth),
            child: Container(),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _clearDrawing,
            backgroundColor: Colors.pink,
            child: const Icon(Icons.clear),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _buildTasksPage(),
      _buildNotesPage(),
      _buildDrawingPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('DailyList'),
        centerTitle: true,
        actions: [
          if (_selectedIndex ==
              0) // Tambahkan ikon arsip jika di halaman beranda
            IconButton(
              icon: const Icon(Icons.archive),
              onPressed: _goToArchivePage,
            ),
        ],
      ),
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _addTask,
              backgroundColor: Colors.pink,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.pink.shade50,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notes),
            label: 'Catatan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Coretan',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class ArchivePage extends StatelessWidget {
  final List<Map<String, dynamic>> archivedTasks;
  final VoidCallback clearArchive; // Tambahkan parameter ini

  const ArchivePage({
    super.key,
    required this.archivedTasks,
    required this.clearArchive, // Inisialisasi parameter
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arsip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear), // Ikon "X"
            onPressed: () {
              clearArchive(); // Panggil fungsi untuk menghapus arsip
              Navigator.pop(context); // Kembali ke halaman sebelumnya setelah penghapusan
            },
          ),
        ],
      ),
      body: archivedTasks.isEmpty
          ? const Center(
              child: Text(
                'Tidak ada arsip.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: archivedTasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(archivedTasks[index]['name']),
                );
              },
            ),
    );
  }
}


class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  final double strokeWidth;

  DrawingPainter(this.points, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
} 