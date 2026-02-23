import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'services/task_service.dart';
import 'services/auth_service.dart';
import 'models/task.dart';
import 'screens/auth_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        StreamProvider<User?>(
          create: (context) => context.read<AuthService>().userChanges,
          initialData: null,
        ),
      ],
      child: const TaskSharingApp(),
    ),
  );
}

class TaskSharingApp extends StatelessWidget {
  const TaskSharingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task List',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F6F3),
        textTheme: GoogleFonts.dmSansTextTheme(),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    return user != null ? const HomeScreen() : const AuthScreen();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _taskController = TextEditingController();
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);
    final user = Provider.of<User?>(context);

    if (user == null) return const AuthScreen();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Logout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MY WORKSPACE',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFB0AA9F),
                        ),
                      ),
                      Text(
                        'Task List',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 38,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Color(0xFFB0AA9F)),
                    onPressed: () => authService.signOut(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Progress Section
              StreamBuilder<List<Task>>(
                stream: firestoreService.getTasks(user.uid),
                builder: (context, snapshot) {
                  final tasks = snapshot.data ?? [];
                  final completedCount = tasks.where((t) => t.isCompleted).length;
                  final totalCount = tasks.length;
                  final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Progress', style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF999999))),
                          Text('$completedCount/$totalCount completed',
                              style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF2C2C2C))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: const Color(0xFFECEAE5),
                          color: const Color(0xFF2C2C2C),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Add Task Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _taskController,
                      style: GoogleFonts.dmSans(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Add a new task...',
                        hintStyle: const TextStyle(color: Color(0xFFBDB9B1)),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFECEAE5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFECEAE5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      final title = _taskController.text.trim();
                      if (title.isNotEmpty) {
                        firestoreService.addTask(title, user.uid);
                        _taskController.clear();
                      }
                    },
                    child: Container(
                      height: 48,
                      width: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Filter Buttons
              Row(
                children: ['all', 'active', 'done'].map((f) {
                  final isActive = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(f[0].toUpperCase() + f.substring(1)),
                      selected: isActive,
                      onSelected: (_) => setState(() => _filter = f),
                      selectedColor: const Color(0xFF2C2C2C),
                      backgroundColor: Colors.transparent,
                      labelStyle: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: isActive ? Colors.white : const Color(0xFF888888),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: BorderSide.none,
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Task List
              Expanded(
                child: StreamBuilder<List<Task>>(
                  stream: firestoreService.getTasks(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF2C2C2C)));
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Database error. Check permissions or network.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(color: const Color(0xFFC0BAB0), fontSize: 14),
                        ),
                      );
                    }

                    var tasks = snapshot.data ?? [];
                    if (_filter == 'active') tasks = tasks.where((t) => !t.isCompleted).toList();
                    if (_filter == 'done') tasks = tasks.where((t) => t.isCompleted).toList();

                    if (tasks.isEmpty) {
                      return Center(
                        child: Text(
                          'No tasks here',
                          style: GoogleFonts.dmSans(color: const Color(0xFFC0BAB0), fontSize: 14),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) => TaskItem(task: tasks[index], userId: user.uid),
                    );
                  },
                ),
              ),

              // Footer: Remaining count
              StreamBuilder<List<Task>>(
                stream: firestoreService.getTasks(user.uid),
                builder: (context, snapshot) {
                  final tasks = snapshot.data ?? [];
                  final remaining = tasks.where((t) => !t.isCompleted).length;
                  if (tasks.isEmpty) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      '$remaining remaining',
                      style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFFC0BAB0)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final Task task;
  final String userId;
  const TaskItem({super.key, required this.task, required this.userId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => firestoreService.deleteTask(userId, task.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      child: GestureDetector(
        onTap: () => firestoreService.updateTaskStatus(userId, task.id, !task.isCompleted),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFECEAE5)),
          ),
          child: Row(
            children: [
              // Custom Circular Checkbox
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? const Color(0xFF2C2C2C) : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted ? const Color(0xFF2C2C2C) : const Color(0xFFD4CFC7),
                    width: 2,
                  ),
                ),
                child: task.isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: task.isCompleted ? const Color(0xFFB0AA9F) : const Color(0xFF1A1A1A),
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, h:mm a').format(task.createdAt),
                      style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFFC5C0B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
