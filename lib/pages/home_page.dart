import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:letmecook/assets/icons/logos.dart';
import 'package:letmecook/assets/themes/app_colors.dart';
import 'package:letmecook/pages/post_page.dart';
import 'package:letmecook/pages/profile_page.dart';
import 'package:letmecook/pages/search_page.dart';
import 'package:letmecook/widgets/post_tile.dart';
import 'package:letmecook/widgets/styled_text.dart';
import 'package:letmecook/widgets/styled_textbox.dart';
import 'package:letmecook/widgets/text_field.dart';
import 'package:letmecook/assets/icons/custom_icons.dart';
import 'package:letmecook/widgets/wall_post.dart';
import 'package:letmecook/widgets/top_appbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Variables

  // Username display (uncomment as needed)
  final currentUser = FirebaseAuth.instance.currentUser;
  final _controllerPost = TextEditingController();

  //FUNCTIONS

  void postMessage() {
    if (_controllerPost.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser!.email,
        'Message': _controllerPost.text,
        'TimeStamp': Timestamp.now(),
      });
    }

    // Clear Text after sending
    setState(() {
      _controllerPost.clear();
    });

    print(_controllerPost.text);
  }

  void attachImage() {}

  // CODE PROPER

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // WALL POST
      body: Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 16, right: 16, top: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dark.withOpacity(0.25),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: CustomIcons.profile(
                      color: AppColors.dark,
                      size: 40,
                    ),
                  ),
                  Expanded(
                    child: StyledTextbox(
                      maxLines: 50,
                      height: 40,
                      controller: _controllerPost,
                      obscureText: false,
                      hintText: "Write a recipe...",
                    ),
                  ),
                  IconButton(
                    padding: const EdgeInsets.only(left: 5),
                    onPressed: postMessage,
                    icon: CustomIcons.arrowRight(color: AppColors.dark),
                    iconSize: 30,
                  ),
                ],
              ),
            ),

            // Wall Display (boxes)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy(
                      "TimeStamp",
                      descending: false,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: ((context, index) {
                          final post = snapshot.data!.docs[index];
                          return PostTile(
                            post: post['Message'],
                            user: post['UserEmail'],
                          );
                        }));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error:${snapshot.error}'),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            // Logged in as : section

            Text("Logged in as : ${currentUser!.email}")
          ],
        ),
      ),
    );
  }
}
