import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const PcosDailyApp());
}

class PcosDailyApp extends StatelessWidget {
  const PcosDailyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PCOS Daily',
      theme: ThemeData(
        colorSchemeSeed: Colors.pink,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int water = 0;
  int steps = 0;
  bool breakfast = false;
  bool lunch = false;
  bool exercise = false;
  bool medicine = false;
  double? weight;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      water = p.getInt('water') ?? 0;
      steps = p.getInt('steps') ?? 0;
      breakfast = p.getBool('breakfast') ?? false;
      lunch = p.getBool('lunch') ?? false;
      exercise = p.getBool('exercise') ?? false;
      medicine = p.getBool('medicine') ?? false;
      weight = p.getDouble('weight');
    });
  }

  Future<void> save(String key, dynamic value) async {
    final p = await SharedPreferences.getInstance();

    if (value is bool) await p.setBool(key, value);
    if (value is int) await p.setInt(key, value);
    if (value is double) await p.setDouble(key, value);
  }

  int get completed {
    int n = 0;
    if (water >= 6) n++;
    if (breakfast) n++;
    if (lunch) n++;
    if (exercise) n++;
    if (medicine) n++;
    if (steps >= 6000) n++;
    return n;
  }

  void addWater() {
    setState(() {
      water++;
    });
    save('water', water);
  }

  void enterSteps() {
    final controller = TextEditingController(text: steps.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('عدد الخطوات'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'مثلاً 6000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text) ?? 0;
              setState(() => steps = value);
              save('steps', value);
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void enterWeight() {
    final controller =
        TextEditingController(text: weight?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('الوزن'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: 'مثلاً 70.5 kg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null) {
                setState(() => weight = value);
                save('weight', value);
              }
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Widget checkItem(
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(title),
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final percent = completed / 6;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PCOS Daily'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const Text(
                    '🎯 هدف اليوم',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: percent),
                  const SizedBox(height: 8),
                  Text('${completed}/6 أهداف مكتملة'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.water_drop),
              title: const Text('الماء'),
              subtitle: Text('$water / 6 كؤوس'),
              trailing: FilledButton(
                onPressed: addWater,
                child: const Text('+ ماء'),
              ),
            ),
          ),

          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.restaurant),
                  title: Text('وجبات اليوم'),
                ),
                checkItem(
                  '🍳 الفطور',
                  breakfast,
                  (v) {
                    setState(() => breakfast = v);
                    save('breakfast', v);
                  },
                ),
                checkItem(
                  '🥗 الغداء',
                  lunch,
                  (v) {
                    setState(() => lunch = v);
                    save('lunch', v);
                  },
                ),
              ],
            ),
          ),

          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.fitness_center),
                  title: Text('الرياضة'),
                  subtitle: Text('مشي سريع — 30 دقيقة'),
                ),
                checkItem(
                  'أكملت التمرين اليوم',
                  exercise,
                  (v) {
                    setState(() => exercise = v);
                    save('exercise', v);
                  },
                ),
              ],
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.directions_walk),
              title: const Text('المشي والخطوات'),
              subtitle: Text('$steps خطوة'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: enterSteps,
              ),
            ),
          ),

          Card(
            child: checkItem(
              '💊 أخذت الدواء / المكمل حسب وصف الطبيب',
              medicine,
              (v) {
                setState(() => medicine = v);
                save('medicine', v);
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.monitor_weight),
              title: const Text('الوزن'),
              subtitle: Text(
                weight == null ? 'لم يتم تسجيل الوزن' : '$weight kg',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: enterWeight,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                completed >= 5
                    ? '🌸 أحسنتِ! يوم ممتاز، كملي بنفس الطريقة.'
                    : '💗 مازال عندك أهداف اليوم. خطوة بخطوة تقدري توصلي.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
