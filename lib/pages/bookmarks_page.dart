import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:letmecook/assets/icons/custom_icons.dart';
import 'package:letmecook/assets/themes/app_colors.dart';
import 'package:letmecook/widgets/post_tile.dart';
import 'package:letmecook/widgets/styled_container.dart';
import 'package:letmecook/widgets/styled_text.dart';
import 'package:letmecook/widgets/styled_textbox.dart';
import 'package:letmecook/widgets/top_appbar.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({Key? key}) : super(key: key);

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Usernames")
                  .doc(currentUser!.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final bookmarks = List<String>.from(
                    snapshot.data!['Bookmarks'] ?? [],
                  );

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("User Posts")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<DocumentSnapshot> filteredPosts = snapshot
                            .data!.docs
                            .where((post) => bookmarks.contains(post.id))
                            .toList();

                        if (filteredPosts.isEmpty) {
                          return const Center(
                            child: StyledText(
                              text: 'Bookmarks is empty.',
                              size: 20,
                              weight: FontWeight.w400,
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: filteredPosts.length,
                          itemBuilder: (context, index) {
                            final post = filteredPosts[index];
                            return PostTile(
                              title: post['Title'],
                              user: post['UserEmail'],
                              timestamp: post['TimeStamp'],
                              imageUrl: 'imageUrl', // Replace with actual field
                              likes: List<String>.from(post['Likes'] ?? []),
                              bookmarkCount: post['BookmarkCount'],
                              postId: post.id,
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: StyledText(text: 'Error: ${snapshot.error}'),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: StyledText(text: 'Error: ${snapshot.error}'),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
