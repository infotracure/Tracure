import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tracure/features/homepage/view/CircularProgressWidget.dart'
    show CircularProgressWidget;
import 'package:tracure/servies/health_service.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F3F7),
      appBar: AppBar(
        actions: [Icon(Icons.notifications), SizedBox(width: 10)],
        backgroundColor: Color(0xFFF2F3F7),
      ),
      drawer: Drawer(child: ListView()),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              WelcomeHeader(),
              SleepStepCalories(),
              BookSpecialistCard(),
              HealthEcosystem(),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Welcome back, Dave",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

class SleepStepCalories extends StatelessWidget {
  const SleepStepCalories({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 0,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You're Doing Great!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Keep up the momentum by finishing your daily goals.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                CircularProgressWidget(percent: 0.8),
              ],
            ),
          ),
          SizedBox(height: 10),
          Divider(height: 8, thickness: 1, color: Colors.grey.shade300),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  iconLabelCard(
                    label: "Sleep",
                    img: "assets/images/fluent-emoji_sleeping-face.png",
                    color: 0xFF228BE6,
                  ),
                  VerticalDivider(thickness: 1, color: Colors.grey.shade300),
                  iconLabelCard(
                    label: "Calories",
                    img: "assets/images/emojione_running-shoe.png",
                    color: 0xFF40B8B2,
                  ),
                  VerticalDivider(thickness: 1, color: Colors.grey.shade300),

                  iconLabelCard(
                    label: "Steps",
                    img: "assets/images/fluent-emoji_fire.png",
                    color: 0xFFFAB005,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container iconLabelCard({
    required String label,
    required String img,
    required int color,
  }) {
    return Container(
      height: 80,
      width: 100,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "8h 14m",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Image.asset(img, height: 20, width: 20),
            ],
          ),
          SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.8,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Color(color)),
            ),
          ),
        ],
      ),
    );
  }
}

class BookSpecialistCard extends StatelessWidget {
  const BookSpecialistCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 0,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Yoga Gurukul",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Know the benefits of yoga from world renowned specialist Dr. David Frawley",
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  "02 June 2025",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap: () async {
                      await PermissionManager.requestActivityPermission();
                      printTodaySteps();
                      printWeeklySteps();
                      printMonthlySteps();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Wraps content tightly
                      children: [
                        Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage("assets/images/bg_quickaction.png"),
          ),
        ],
      ),
    );
  }
}

class HealthEcosystem extends StatelessWidget {
  const HealthEcosystem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage("assets/images/bg_quickaction.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        children: [Ecosystem(), SizedBox(height: 10), TrackWellbeing()],
      ),
    );
  }
}

class TrackWellbeing extends StatelessWidget {
  const TrackWellbeing({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Track you well-being",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: iconLabelCard(
                  label: "BMI Calculator",
                  img: "assets/images/fluent-emoji_man-standing.png",
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: iconLabelCard(
                  label: "Fasting Blood Pressure Tracker",
                  img: "assets/images/fluent-emoji_drop-of-blood.png",
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: iconLabelCard(
                  label: "Breathing Exercise",
                  img: "assets/images/fluent-emoji_sleeping-face.png",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Container iconLabelCard({required String label, required String img}) {
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(img, height: 20, width: 20),
          SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.visible,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class Ecosystem extends StatelessWidget {
  const Ecosystem({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Explore Health Ecosystem",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Here’s our recommendations based on your history",
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(
                child: iconLabelCard(
                  label: "Water Intake",
                  img: "assets/images/fluent-emoji_glass-of-milk.png",
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: iconLabelCard(
                  label: "Medicine Tracker",
                  img: "assets/images/fluent-emoji_pill.png",
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: iconLabelCard(
                  label: "Menstrual Cycle",
                  img: "assets/images/fluent-emoji_female-sign.png",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Container iconLabelCard({required String label, required String img}) {
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(img, height: 20, width: 20),
          SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.visible,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
