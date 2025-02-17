import 'package:flutter/material.dart';
import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';


void main() {
  runApp(MemoryGameApp());
}

class MemoryGameApp extends StatelessWidget {
  const MemoryGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      title: 'Memory Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DifficultySelectionScreen(),
    );
  }
}

class DifficultySelectionScreen extends StatelessWidget {
  const DifficultySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose difficulty level'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://raw.githubusercontent.com/MaysaaAbuRahma/Add-images/refs/heads/main/038561c8-7c76-4e0e-8043-581741c420df.jfif'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DifficultyButton(
                label: 'Easy',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(difficulty: 'easy'),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              DifficultyButton(
                label: 'Medium',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(difficulty: 'medium'),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              DifficultyButton(
                label: 'Hard',
                color: Colors.red,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(difficulty: 'hard'),
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

class DifficultyButton extends StatefulWidget {
  final String label;
  final Color color;
  final Function onTap;

  const DifficultyButton({super.key, required this.label, required this.color, required this.onTap});

  @override
  _DifficultyButtonState createState() => _DifficultyButtonState();
}

class _DifficultyButtonState extends State<DifficultyButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap(),
      onTapDown: (_) {
        setState(() {
          _scale = 0.6; // حجم أصغر عند الضغط
        });
      },
      onTapUp: (_) {
        setState(() {
          _scale = 1.0; // العودة للحجم الطبيعي بعد الإفلات
        });
      },
      onTapCancel: () {
        setState(() {
          _scale = 1.0; // العودة للحجم الطبيعي إذا تم إلغاء الضغط
        });
      },
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          width: 200,
          height: 60,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final String difficulty;

  const GameScreen({super.key, required this.difficulty});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<IconData> icons;
  late List<bool> flipped;
  late int timeLeft;
  late int score;
  late Timer? timer;
  List<int> flippedIndexes = [];

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    // تحديد عدد الأزواج بناءً على مستوى الصعوبة
    int pairs;
    switch (widget.difficulty) {
      case 'easy':
        pairs = 4;
        timeLeft = 90;
        break;
      case 'medium':
        pairs = 6;
        timeLeft = 60;
        break;
      case 'hard':
        pairs = 8;
        timeLeft = 30;
        break;
      default:
        pairs = 4;
        timeLeft = 60;
    }

    // إنشاء قائمة الأيقونات
    icons = [
      Icons.star,
      Icons.favorite,
      Icons.pets,
      Icons.home,
      Icons.airplanemode_active,
      Icons.beach_access,
      Icons.cake,
      Icons.directions_bike,
    ].sublist(0, pairs)..addAll([
        Icons.star,
        Icons.favorite,
        Icons.pets,
        Icons.home,
        Icons.airplanemode_active,
        Icons.beach_access,
        Icons.cake,
        Icons.directions_bike,
      ].sublist(0, pairs));

    icons.shuffle(); // خلط الأيقونات

    // تهيئة الحالة
    flipped = List.generate(icons.length, (index) => false);
    score = 0;
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          timer.cancel();
          endGame();
        }
      });
    });
  }

 void checkMatch(int index) {
  setState(() {
    flipped[index] = true;
    flippedIndexes.add(index);

    if (flippedIndexes.length == 2) {
      if (icons[flippedIndexes[0]] == icons[flippedIndexes[1]]) {
        // تطابق
        score += 10;
        flippedIndexes.clear();
        
        // تحقق مما إذا كانت اللعبة قد انتهت
        if (flipped.every((flipped) => flipped)) {
          timer?.cancel(); // إلغاء المؤقت
          endGame(); // عرض الاحتفال
        }
      } else {
        // لا تطابق، اقلب البطاقات مرة أخرى بعد تأخير
        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            flipped[flippedIndexes[0]] = false;
            flipped[flippedIndexes[1]] = false;
            flippedIndexes.clear();
          });
        });
      }
    }
  });
}

void endGame() {
  timer?.cancel(); // إلغاء المؤقت
  AwesomeDialog(
  
    context: context,
    dialogType: DialogType.success,
    headerAnimationLoop: false,
    title: 'Congratulations!',
    desc: "You've got a $score points.",
    btnOkOnPress: () {
      resetGame();
    },
    btnCancelOnPress: () {
      Navigator.of(context).pop();
    },
    body: Column(
      
      children: [
    
       // Image.network(
          //'https://raw.githubusercontent.com/MaysaaAbuRahma/Add-images/refs/heads/main/Balloon%20PNG%20-%20Free%20Download.jfif',
         // width: 120,
         // height: 120,
         // errorBuilder: (context, error, stackTrace) {
         //   return Container(color: Colors.red, width: 120, height: 120); // Placeholder for error
       //   },
      //  ),
      
        Image.network(
          'https://raw.githubusercontent.com/MaysaaAbuRahma/Add-images/refs/heads/main/Part%C3%ADculas%203d%20Decorativas%20De%20Confetes%20Dourados%20Caindo%20Em%20Fundo%20Transparente%20PNG%20%2C%20Confete%20Dourado%2C%20Colorful%20Confetti%2C%20Confete%20Imagem%20PNG%20e%20PSD%20Para%20Download%20Gratuito.jfif',
          width: 300,
          height:300,
          errorBuilder: (context, error, stackTrace) {
            return Container(color: Colors.blue, width: 120, height: 120); // Placeholder for error
          },
        ),
      ],
    ),
  ).show();
}
  void resetGame() {
    setState(() {
      initializeGame();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      appBar: AppBar(
  backgroundColor: Colors.blueAccent,
  title: Text('Memory Game- ${widget.difficulty}'),
  actions: [
    Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(Icons.timer, color: Colors.deepOrange), // أيقونة الوقت
          SizedBox(width: 4.0), // مسافة بين الأيقونة والنص
          Text('time: $timeLeft', style: TextStyle(color: Colors.red)),
        ],
      ),
    ),
    Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(Icons.score, color: Colors.lightBlue), // أيقونة النقاط
          SizedBox(width: 4.0), // مسافة بين الأيقونة والنص
          Text('score: $score', style: TextStyle(color: const Color.fromARGB(255, 2, 25, 63))),
        ],
      ),
    ),
  ],
),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://raw.githubusercontent.com/MaysaaAbuRahma/Add-images/refs/heads/main/038561c8-7c76-4e0e-8043-581741c420df.jfif'), // استبدل بالرابط الفعلي
            fit: BoxFit.cover,
          ),
        ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.difficulty == 'hard' ? 4 : 3, // عدد الأعمدة
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (!flipped[index] && flippedIndexes.length < 2) {
                checkMatch(index);
              }
            },
            child: Card(
              
              child: Center(
               
                child: flipped[index]
                    ? Icon(icons[index], size: 40) // عرض الأيقونة
                    : Text('❓', style: TextStyle(fontSize: 40)), // علامة استفهام
              ),
            ),
          );
        },
      ),
     ) );
  }
}



  