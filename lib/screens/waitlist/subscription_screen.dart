import 'package:flutter/material.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final membership = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset("assets/tempImages/subscription_bg.png"),
            ),
            Text(
              "Claim your membership",
              style: TextStyle(
                  color: Colors.orange,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'CustomFont'),
            ),
            Text(
              "Unlimited Likes,Date recommendations and more",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'CustomFont'),
            ),
            GestureDetector(
              onTap: () {
                print("sub:pressed");
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                    width: 500,
                    height: 200,
                    child: Image.asset("assets/tempImages/sub6.webp")),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.orange),
                  minimumSize: WidgetStateProperty.all(Size(300, 65)),
                  maximumSize: WidgetStateProperty.all(Size(300, 65)),
                ),
                onPressed: () {},
                child: Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Get exclusive membership",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'CustomFont',
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.blueGrey[200]),
                  minimumSize: WidgetStateProperty.all(Size(300, 70)),
                  maximumSize: WidgetStateProperty.all(Size(300, 70)),
                ),
                onPressed: () {},
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                    ),
                    Text(
                      "Give it to a friend",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'CustomFont',
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
