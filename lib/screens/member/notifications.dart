import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    super.key,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPage();
}

class _NotificationsPage extends State<NotificationsPage> {
  List<String> userPRofile = [
    'assets/light/favicon.png',
    'assets/light/favicon.png',
    'assets/light/favicon.png',
    'assets/light/favicon.png',
    'assets/light/favicon.png',
  ];
  void _closeKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Method to show multi-select dialog

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.w700,
            height: 1,
            fontSize: 20,
            color: isDarkMode ? Colors.grey[100] : Colors.grey[900]),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 8),
                itemCount: userPRofile.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                        left: index == 0 ? 8 : 16,
                        right:
                            index == 0 || index == 1 || index == 2 || index == 3
                                ? 0
                                : 16),
                    child: GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => datingProfilePage(
                        //
                        //     ),
                        //   ),
                        // );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 148, 177, 67),
                                  width: 2,
                                )),
                            child: CircleAvatar(
                              backgroundImage: AssetImage(userPRofile[index]),
                              radius: 40,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text('Natuan',
                              style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.0))
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                thickness: 1,
                color: isDarkMode ? Colors.grey[100] : Colors.grey[900],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Today',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    color: isDarkMode ? Colors.grey[100] : Colors.grey[900]),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: userPRofile.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => datingProfilePage(
                      //
                      //     ),
                      //   ),
                      // );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color.fromARGB(255, 148, 177, 67),
                                width: 2,
                              )),
                          child: CircleAvatar(
                            backgroundImage: AssetImage(userPRofile[index]),
                            radius: 30,
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '@Natuan Express',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  height: 1.0,
                                  color: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  fontSize: 18),
                            ),
                            Text(
                              'Interest  2h',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  height: 1.0,
                                  color: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  fontSize: 14),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Yesterday',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    color: isDarkMode ? Colors.grey[100] : Colors.grey[900]),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => datingProfilePage(
                      //
                      //     ),
                      //   ),
                      // );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color.fromARGB(255, 148, 177, 67),
                                width: 2,
                              )),
                          child: CircleAvatar(
                            backgroundImage: AssetImage(userPRofile[index]),
                            radius: 30,
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '@Natuan Express',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  height: 1.0,
                                  color: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  fontSize: 18),
                            ),
                            Text(
                              'Interest ',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  height: 1.0,
                                  color: isDarkMode
                                      ? Colors.grey[100]
                                      : Colors.grey[900],
                                  fontSize: 14),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}
