import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:letmecook/assets/icons/logos.dart';
import 'package:letmecook/assets/themes/app_colors.dart';
import 'package:letmecook/pages/post_page.dart';
import 'package:letmecook/pages/profile_page.dart';
import 'package:letmecook/pages/search_page.dart';
import 'package:letmecook/pages/hub_page.dart';
import 'package:letmecook/utils.dart';
import 'package:letmecook/widget_tree.dart';
import 'package:letmecook/widgets/styled_text.dart';
import 'package:letmecook/widgets/styled_button.dart';
import 'package:letmecook/widgets/styled_textbox.dart';
import 'package:letmecook/widgets/text_field.dart';
import 'package:letmecook/assets/icons/custom_icons.dart';
import 'package:letmecook/widgets/wall_post.dart';
import 'package:letmecook/widgets/top_appbar.dart';
import 'package:letmecook/resources/add_data.dart';
import 'package:letmecook/auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:html' as html;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerOldPassword = TextEditingController();
  final TextEditingController _controllerNewPassword = TextEditingController();
  bool usernameError = false;
  bool passwordError = false;
  bool usernameSuccess = false;
  bool passwordSuccess = false;
  bool uploadImageError = false;
  bool uploadImageSuccess = false;
  String errorMessage = '';
  late String username = '';
  late String profilePictureUrl = '';
  String profilePicURL = '';
  PlatformFile? pickedFile;
  Widget? fromPicker;
  Uint8List? _image;

  void toWidgetTree() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WidgetTree()),
    );
  }

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  void uploadImage() async {
    try {
      String? response = await StoreData().saveData(
          file: _image!,
          username: username,
          email: currentUser!.email,
          fileName: fileName);
      setState(() {
        uploadImageSuccess = true;
      });
    } catch (e) {
      setState(() {
        uploadImageError = true;
      });
    }
  }

  void saveUsername() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Usernames')
        .where('Username', isEqualTo: _controllerUsername.text)
        .get();

    if (querySnapshot.docs.isEmpty ||
        querySnapshot.docs.first.get('Username') == username) {
      await FirebaseFirestore.instance
          .collection('Usernames')
          .doc(currentUser!.email)
          .set({
        'Username': _controllerUsername.text,
        'UserEmail': currentUser!.email,
      });
      setState(() {
        username = _controllerUsername.text;
        usernameError = false;
        usernameSuccess = true;
      });
    } else {
      setState(() {
        usernameError = true;
      });
    }
  }

  void changePassword() async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: _controllerOldPassword.text,
      );
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.updatePassword(_controllerNewPassword.text);
      setState(() {
        passwordError = false;
        passwordSuccess = true;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        passwordError = true;
        if (e.message == 'Error') {
          errorMessage = 'Wrong password!';
        } else {
          errorMessage = e.message ?? 'An error occurred';
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
    usernameError = false;
    usernameSuccess = false;
    passwordError = false;
    passwordSuccess = false;
    uploadImageError = false;
    uploadImageSuccess = false;
  }

  void fetchUserData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Usernames')
        .doc(currentUser!.email)
        .get();
    setState(() {
      username = snapshot.data()?['Username'] ?? currentUser!.email;
      profilePictureUrl =
          snapshot.data()?['ProfilePicture'] ?? currentUser!.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      alignment: Alignment.center,
                      child: _image != null
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage: MemoryImage(_image!),
                            )
                          : CircleAvatar(
                              radius: 64,
                              backgroundImage: NetworkImage(profilePictureUrl),
                            ),
                    ),
                    uploadImageError
                        ? const StyledText(
                            text: 'Unable to upload!',
                            size: 16,
                            color: Colors.red,
                          )
                        : uploadImageSuccess
                            ? const StyledText(
                                text: 'Image uploaded!',
                                size: 16,
                                color: Colors.green,
                              )
                            : const SizedBox(height: 0),
                    const SizedBox(height: 10),
                    StyledButton(
                      text: 'Select Image',
                      size: 16,
                      buttonStyle: 'primary',
                      onPressed: selectImage,
                    ),
                    const SizedBox(height: 10),
                    StyledButton(
                      text: 'Upload',
                      size: 16,
                      buttonStyle: 'primary',
                      onPressed: uploadImage,
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: const StyledText(
                        text: 'Username',
                        size: 18,
                      ),
                    ),
                    StyledTextbox(
                      controller: _controllerUsername,
                      text: username,
                    ),
                    usernameError
                        ? const StyledText(
                            text: 'Username is already taken!',
                            size: 16,
                            color: Colors.red,
                          )
                        : usernameSuccess
                            ? const StyledText(
                                text: 'Username changed!',
                                size: 16,
                                color: Colors.green,
                              )
                            : const SizedBox(height: 0),
                    Container(
                      padding: const EdgeInsets.only(top: 15, bottom: 5),
                      child: StyledButton(
                        onPressed: saveUsername,
                        text: 'Save',
                        size: 18,
                        buttonStyle: 'primary',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: const StyledText(
                        text: 'Change Password',
                        size: 18,
                      ),
                    ),
                    const StyledText(
                      text: 'Old Password',
                      size: 16,
                      weight: FontWeight.bold,
                    ),
                    StyledTextbox(
                      controller: _controllerOldPassword,
                      obscureText: true,
                    ),
                    const StyledText(
                      text: 'New Password',
                      size: 16,
                      weight: FontWeight.bold,
                    ),
                    StyledTextbox(
                      controller: _controllerNewPassword,
                      obscureText: true,
                    ),
                    passwordError
                        ? StyledText(
                            text: errorMessage,
                            size: 16,
                            color: Colors.red,
                          )
                        : passwordSuccess
                            ? const StyledText(
                                text: 'Password changed!',
                                size: 16,
                                color: Colors.green,
                              )
                            : const SizedBox(height: 0),
                    Container(
                      padding: const EdgeInsets.only(top: 15, bottom: 5),
                      child: StyledButton(
                        onPressed: changePassword,
                        text: 'Change Password',
                        size: 18,
                        buttonStyle: 'primary',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
