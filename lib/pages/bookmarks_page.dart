import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:letmecook/assets/icons/custom_icons.dart';
import 'package:letmecook/assets/themes/app_colors.dart';
import 'package:letmecook/widgets/post_tile.dart';
import 'package:letmecook/widgets/styled_container.dart';
import 'package:letmecook/widgets/styled_text.dart';
import 'package:letmecook/widgets/styled_textbox.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
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
        'ImageUrl': '',
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
      body: Column(
        children: [
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
                        title: post['Title'],
                        user: post['UserEmail'],
                        timestamp: post['TimeStamp'],
                        imageUrl: 'imageUrl',
                        likes: List<String>.from(post['Likes'] ?? []),
                        bookmarkCount: post['BookmarkCount'],
                        postId: post.id,
                      );
                    }),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: StyledText(text: 'Error:${snapshot.error}'),
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
