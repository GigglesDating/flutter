import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LikedAccounts extends StatefulWidget {
  const LikedAccounts({super.key});

  @override
  State<LikedAccounts> createState() => _SwipeFilterPage();
}

class _SwipeFilterPage extends State<LikedAccounts> {
  final List<Color> colors = [
    Colors.black87,
    Colors.blue,
    Colors.yellow,
    Colors.yellow,
    Colors.redAccent,
    Colors.pink,
    Colors.purple,
    Colors.greenAccent,
    Colors.yellowAccent,
    Colors.orangeAccent,
    Colors.blue,
    Colors.blue,
    Colors.yellow,
    Colors.yellow,
    Colors.redAccent,
    Colors.pink,
    Colors.purple,
    Colors.greenAccent,
    Colors.yellowAccent,
    Colors.orangeAccent,
    Colors.blue,
    Colors.redAccent,
    Colors.pink,
    Colors.purple,
    Colors.greenAccent,
    Colors.yellowAccent,
    Colors.orangeAccent,
    Colors.blue,
  ];
  List con = [
    'assets/tempImages/users/usera/1.png',
    'assets/tempImages/users/usera/2.png',
    'assets/tempImages/users/usera/3.png',
    'assets/tempImages/users/usera/4.png',
    'assets/tempImages/users/userb/1.png',
    'assets/tempImages/users/userb/2.png',
    'assets/tempImages/users/userb/3.png',
    'assets/tempImages/users/userb/4.png',
    'assets/tempImages/users/user1.jpg',
    'assets/tempImages/users/user2.jpg',
    'assets/tempImages/users/user3.jpg',
    'assets/tempImages/users/user4.jpg',
    'assets/tempImages/users/usera/1.png',
    'assets/tempImages/users/usera/2.png',
    'assets/tempImages/users/usera/3.png',
    'assets/tempImages/users/usera/4.png',
    'assets/tempImages/users/userb/1.png',
    'assets/tempImages/users/userb/2.png',
    'assets/tempImages/users/userb/3.png',
    'assets/tempImages/users/userb/4.png',
    'assets/tempImages/users/user1.jpg',
    'assets/tempImages/users/user2.jpg',
    'assets/tempImages/users/user3.jpg',
    'assets/tempImages/users/user4.jpg',
    'assets/tempImages/users/user1.jpg',
    'assets/tempImages/users/user2.jpg',
    'assets/tempImages/users/user3.jpg',
    'assets/tempImages/users/user4.jpg',
  ];

  List con1 = [
    'Aditi rao',
    'Rahul jakur',
    'Athul m',
    'Meena rama',
    'Drishya unni',
    'Nimisha ajayan',
    'meenakshi ramesh',
    'Lakshmi',
    'Arya lakshmi',
    'Pooja lakhra',
    'diksha mehta',
    'Priya varma',
    'anushka sharma',
    'pooja hedge',
    'sunny wayne',
    'appu kuttan',
    'Ben binoy',
    'harshida fathima',
    'swetha lakshmi',
    'Aditi rao',
    'Rahul jakur',
    'Athul m',
    'Meena rama',
    'Drishya unni',
    'Nimisha ajayan',
    'meenakshi ramesh',
    'Lakshmi',
    'Arya lakshmi',
    'Pooja lakhra',
    'diksha mehta',
    'Priya varma',
    'anushka sharma',
    'pooja hedge',
    'sunny wayne',
    'appu kuttan',
    'Ben binoy',
    'harshida fathima',
    'swetha lakshmi',
    'appu kuttan',
    'Ben binoy',
    'harshida fathima',
    'swetha lakshmi',
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      // Make it transparent or choose any color
      statusBarIconBrightness: Brightness.light,
      // Set icons to white
      statusBarBrightness: Brightness.light, // For iOS
    ));
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.black.withAlpha(15)
            : Colors.white.withAlpha(15),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withAlpha(25)
              : Colors.black.withAlpha(15),
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 15,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            titleTextStyle: TextStyle(
                fontSize: 20,
                color: isDarkMode ? Colors.grey[100] : Colors.grey[900]),
            bottom: PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width, 48),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 7.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color.fromARGB(255, 241, 242, 242)
                      : const Color.fromARGB(255, 188, 188, 188),
                  // Background color for entire tab section
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                child: TabBar(
                  dividerHeight: 0,
                  physics: const NeverScrollableScrollPhysics(),
                  // labelPadding: EdgeInsets.all(0),
                  isScrollable: false,
                  // textScaler: TextScaler.noScaling,
                  indicator: BoxDecoration(
                      color: isDarkMode ? Colors.grey[100] : Colors.grey[900],
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.zero,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 0),
                  labelStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black),
                  labelColor: Theme.of(context).colorScheme.brightness ==
                          Brightness.light
                      ? Colors.white
                      : Colors.black,
                  unselectedLabelColor: Colors.black,
                  tabs: [
                    Tab(text: "Liked You"),
                    Tab(text: "Liked By You"),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Text(
                      "Few people would like to hangout with you, find out who.",
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(1),
                        itemCount: colors.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.7,
                        ),
                        itemBuilder: (context, index) => Dismissible(
                          key: Key(con1[index]), // Unique key for each item
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              // Swiped left
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const Placeholder(), // Replace with your screen
                                ),
                              );
                            } else if (direction ==
                                DismissDirection.startToEnd) {
                              // Swiped right
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const Placeholder(), // Replace with your screen
                                ),
                              );
                            }
                          },
                          background: Container(
                            // Right swipe background
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 20),
                                child:
                                    Icon(Icons.favorite, color: Colors.green),
                              ),
                            ),
                          ),
                          secondaryBackground: Container(
                            // Left swipe background
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.only(right: 20),
                                child: Icon(Icons.close, color: Colors.red),
                              ),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: colors[index],
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    con[index],
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      con1[index],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      "People you have shown interest to hang out with.",
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: con1.length,
                      itemBuilder: (context, index) => Dismissible(
                        key: Key(con1[index]),
                        onDismissed: (direction) {
                          if (direction == DismissDirection.endToStart) {
                            // Swiped left
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Placeholder(),
                              ),
                            );
                          } else if (direction == DismissDirection.startToEnd) {
                            // Swiped right
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Placeholder(),
                              ),
                            );
                          }
                        },
                        background: Container(
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Icon(Icons.favorite, color: Colors.green),
                            ),
                          ),
                        ),
                        secondaryBackground: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.only(right: 20),
                              child: Icon(Icons.close, color: Colors.red),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: ListTile(
                                shape: ContinuousRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                tileColor: isDarkMode
                                    ? Colors.white.withAlpha(25)
                                    : Colors.black.withAlpha(15),
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage(con[index]),
                                ),
                                title: Text(
                                  con1[index],
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w700),
                                ),
                                subtitle: Text(
                                  "01/09/2002",
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                trailing: IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.delete_forever)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
