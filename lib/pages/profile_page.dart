import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:letmecook/assets/themes/app_colors.dart';
import 'package:letmecook/pages/settings_page.dart';
import 'package:letmecook/widgets/preview_tile.dart';
import 'package:letmecook/widgets/styled_text.dart';
import 'package:letmecook/auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _controllerUsername = TextEditingController();
  bool usernameError = false;
  late String username = '';
  late String profilePictureUrl = '';

  void toSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUsername();
    fetchProfilePicture();
  }

  void fetchUsername() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Usernames')
        .doc(currentUser!.email)
        .get();
    setState(() {
      username = snapshot.data()?['Username'] ?? currentUser!.email;
    });
  }

  void fetchProfilePicture() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Usernames')
          .doc(currentUser!.email)
          .get();
      setState(() {
        profilePictureUrl =
            snapshot.data()?['ProfilePicture'] ?? currentUser!.email;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Div
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(profilePictureUrl),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: StyledText(
                        text: username,
                        size: 20,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: toSettings,
                    iconSize: 30,
                    color: AppColors.dark,
                    icon: const Icon(
                      Icons.settings,
                    ),
                  ),
                ],
              ),
            ),
            // Bookmark Div
            GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                    const Icon(
                      Icons.bookmark_rounded,
                      size: 40,
                      color: AppColors.dark,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 15),
                      child: const StyledText(
                        text: 'Bookmarks',
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sign Out Div
            GestureDetector(
              onTap: () {
                Auth().signOut();
              },
              child: Container(
                margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                    const Icon(
                      Icons.logout_sharp,
                      size: 40,
                      color: AppColors.dark,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 15),
                      child: const StyledText(
                        text: 'Log Out',
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Post Div
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.only(bottom: 15),
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
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 15),
                    alignment: Alignment.centerLeft,
                    child: const StyledText(
                      text: 'Posts',
                      size: 24,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const PreviewTile(),
                  const PreviewTile(),
                  const PreviewTile(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
