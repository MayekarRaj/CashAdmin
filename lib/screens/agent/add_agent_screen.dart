import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';

class AddAgentScreen extends StatefulWidget {
  const AddAgentScreen({super.key});

  @override
  State<AddAgentScreen> createState() => _AddAgentScreenState();
}

class _AddAgentScreenState extends State<AddAgentScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool loading = false;
  final _picker = ImagePicker();
  XFile? profileImage;
  XFile? panCardImage;
  XFile? aadharFrontImage;
  XFile? aadharBackImage;

  Future<File> compressImage(XFile imageFile) async {
    final originalImage = img.decodeImage(await imageFile.readAsBytes());
    final compressedImage = img.copyResize(originalImage!, width: 800);

    // Create a new file for the compressed image
    final File compressedFile = File(imageFile.path)..writeAsBytesSync(img.encodeJpg(compressedImage));

    return compressedFile;
  }

  Future<void> _saveAgentDetails() async {
    setState(() {
      loading = true;
    });
    if (!_validateFields()) {
      setState(() {
        loading = false;
      });
      return;
    }
    if (_validateImages()) {
      setState(() {
        loading = false;
      });
      return;
    }

    // bool isDuplicate = await _checkIfPhoneExists(_phoneNumberController.text.trim());
    // if (isDuplicate) {
    //   setState(() {
    //     loading = false;
    //   });
    //   Fluttertoast.showToast(msg: "Phone number already exists. Please use a different number.");
    //   return;
    // }

    bool isDuplicate = await _checkIfPhoneAndOtherFieldsExist(_phoneNumberController.text.trim());
    if (isDuplicate) {
      setState(() {
        loading = false;
      });
      Fluttertoast.showToast(msg: "Agent already present.");
      return;
    }

    try {
      String profileImageUrl = await _uploadImageToStorage(
          profileImage!, 'profile', (_phoneNumberController.text + _nameController.text).toString().trim());
      // String panCardImageUrl = await _uploadImageToStorage(
      //     panCardImage!, 'panCard', (_phoneNumberController.text + _nameController.text).toString().trim());
      // String aadharFrontImageUrl = await _uploadImageToStorage(
      //     aadharFrontImage!, 'aadharFront', (_phoneNumberController.text + _nameController.text).toString().trim());
      // String aadharBackImageUrl = await _uploadImageToStorage(
      //     aadharBackImage!, 'aadharBack', (_phoneNumberController.text + _nameController.text).toString().trim());

      await FirebaseFirestore.instance.collection('agents').add({
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneNumberController.text.trim(),
        'profileImageUrl': profileImageUrl,
        "balance": 0,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // await FirebaseFirestore.instance.collection('agents').add({
      //   'name': _nameController.text.trim(),
      //   'phoneNumber': _phoneNumberController.text.trim(),
      //   'profileImageUrl': profileImageUrl,
      //   // 'panCardImageUrl': panCardImageUrl,
      //   // 'aadharFrontImageUrl': aadharFrontImageUrl,
      //   // 'aadharBackImageUrl': aadharBackImageUrl,
      //   'timestamp': FieldValue.serverTimestamp(),
      // });

      // bool shouldCreateNewDoc = await _checkIfPhoneExists(_phoneNumberController.text.trim());
      // if (!shouldCreateNewDoc) {
      //   // Create a new document
      //   await FirebaseFirestore.instance.collection('agents').add({
      //     'name': _nameController.text.trim(),
      //     'phoneNumber': _phoneNumberController.text.trim(),
      //     'profileImageUrl': profileImageUrl,
      //     'timestamp': FieldValue.serverTimestamp(),
      //   });
      // } else {
      //   // Update existing document with name and profileImageUrl
      //   DocumentReference docRef = await FirebaseFirestore.instance
      //       .collection('agents')
      //       .where('phoneNumber', isEqualTo: _phoneNumberController.text.trim())
      //       .get()
      //       .then((snapshot) => snapshot.docs.first.reference);
      //   await docRef.update({
      //     'name': _nameController.text.trim(),
      //     'profileImageUrl': profileImageUrl,
      //   });
      // }

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Customer details saved successfully'),
      //   ),
      // );
      Fluttertoast.showToast(msg: "Agent details saved successfully");
      Navigator.pop(context);
    } catch (error) {
      Fluttertoast.showToast(msg: "Failed to save agent details: $error");
      setState(() {
        loading = false;
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Failed to save customer details: $error'),
      //   ),
      // );
    }
  }

  Future<bool> _checkIfPhoneExists(String phoneNumber) async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('agents').where('phoneNumber', isEqualTo: phoneNumber).get();

    return snapshot.docs.isNotEmpty;
  }

  Future<bool> _checkIfPhoneAndOtherFieldsExist(String phoneNumber) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('agents')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .where('name', isNotEqualTo: null)
        .where('profileImageUrl', isNotEqualTo: null)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  bool _validateFields() {
    if (_nameController.text.isEmpty || _phoneNumberController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your name and phone number");
      return false;
    }
    if (!_isValidPhoneNumber(_phoneNumberController.text)) {
      Fluttertoast.showToast(msg: "Please enter a valid 10-digit phone number");
      return false;
    }
    return true;
  }

  bool _validateImages() {
    // if (profileImage == null || panCardImage == null || aadharFrontImage == null || aadharBackImage == null) {
    if (profileImage == null) {
      Fluttertoast.showToast(msg: "Please select all images (profile, PAN card, Aadhaar front and back)");
      return true;
    }
    return false;
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phoneNumber);
  }

  Future<String> _uploadImageToStorage(XFile image, String imageName, String folderName) async {
    try {
      Reference storageReference = FirebaseStorage.instance.ref().child('$folderName/$imageName.jpg');
      final compressedImageFile = await compressImage(image);

      UploadTask uploadTask = storageReference.putFile(compressedImageFile);
      await uploadTask.whenComplete(() => null);
      String downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      setState(() {
        loading = false;
      });
      throw Exception('Failed to upload image: $error');
    }
  }

  Future<void> pickImage(String forField) async {
    final imageSource = await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Pick Image Source'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Camera'),
          ),
          const SizedBox(
            height: 6,
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Gallery'),
          ),
        ],
      ),
    );
    if (imageSource != null) {
      final image = await _picker.pickImage(source: imageSource);
      setState(() {
        if (forField == 'profile') {
          profileImage = image;
        } else if (forField == 'panCard') {
          panCardImage = image;
        } else if (forField == 'aadharFront') {
          aadharFrontImage = image;
        } else if (forField == 'aadharBack') {
          aadharBackImage = image;
        }
      });
    }
  }

  // void _saveUserPhonNumber(String phoneNumber) {
  //   if (phoneNumber.trim().length == 10) {
  //     FirebaseFirestore.instance
  //         .collection('users')
  //         .where('phoneNumber', isEqualTo: phoneNumber)
  //         .get()
  //         .then((querySnapshot) {
  //       if (querySnapshot.docs.isEmpty) {
  //         FirebaseFirestore.instance.collection('users').add({
  //           'phoneNumber': phoneNumber,
  //           'timestamp': FieldValue.serverTimestamp(),
  //         }).then((value) {
  //           logger.i('User added with ID: ${value.id}');
  //           Fluttertoast.showToast(msg: "Number Added", backgroundColor: Colors.green);
  //           Navigator.pop(context);
  //         }).catchError((error) {
  //           logger.e('Failed to add user: $error');
  //         });
  //       } else {
  //         Fluttertoast.showToast(msg: "Number already exists");
  //       }
  //     }).catchError((error) {
  //       logger.e('Failed to check phone number: $error');
  //     });
  //   } else {
  //     Fluttertoast.showToast(msg: "Invalid Number");
  //     logger.e('Failed to add user');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF30315C),
        automaticallyImplyLeading: false,
        leadingWidth: 45,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
          ),
          color: Colors.white,
        ),
        title: const Text(
          'Add Agent',
          style: TextStyle(color: Color(0xFFD6DBEE)),
        ),
      ),
      backgroundColor: const Color(0xFFD6DBEE),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  pickImage("profile");
                },
                // onTap: profileImage == null
                //     ? () {
                //         pickImage("profile");
                //       }
                //     : null,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.16,
                  // height: double.infinity,
                  // width: double.infinity,
                  constraints: const BoxConstraints(
                    minHeight: 100.0, // Adjust minimum size as needed
                    minWidth: 100.0, // Adjust minimum size as needed
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF6F8CB0).withOpacity(0.55),
                        blurRadius: 16.0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: profileImage != null
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: Image.file(
                                  File(profileImage!.path),
                                  // fit: BoxFit.cover,
                                ).image,
                                fit: BoxFit.fill,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_outlined,
                            size: 32,
                            color: Color(0xFF30315C),
                          ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                height: 60,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF6F8CB0).withOpacity(0.55),
                      blurRadius: 16.0,
                    ),
                  ],
                ),
                child: Center(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Agent Name',
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.name,
                    onChanged: (val) {
                      setState(() {
                        _nameController.text = val;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                height: 60,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF6F8CB0).withOpacity(0.55),
                      blurRadius: 16.0,
                    ),
                  ],
                ),
                child: Center(
                  child: TextFormField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                      hintText: 'Agent Phone Number',
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.phone,
                    // validator: (value) {
                    //   if (value == null || value.isEmpty || value.length != 10) {
                    //     Fluttertoast.showToast(msg: "Invalid number");
                    //     // return ;
                    //   }
                    //   return value;
                    // },
                    onChanged: (val) {
                      setState(() {
                        _phoneNumberController.text = val;
                      });
                    },

                    // onEditingComplete: () {
                    //   setState(() {});
                    // },
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              // GestureDetector(
              //   onTap: () {
              //     pickImage('panCard');
              //   },
              //   child: Container(
              //     height: MediaQuery.of(context).size.height * 0.2,
              //     width: MediaQuery.of(context).size.width * 0.8,
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(26),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Color(0xFF6F8CB0).withOpacity(0.55),
              //           blurRadius: 16.0,
              //         ),
              //       ],
              //     ),
              //     child: Center(
              //       child: panCardImage != null
              //           ? Container(
              //               decoration: BoxDecoration(
              //                 borderRadius: BorderRadius.circular(26),
              //                 image: DecorationImage(
              //                   image: Image.file(
              //                     File(panCardImage!.path),
              //                     // fit: BoxFit.cover,
              //                   ).image,
              //                   fit: BoxFit.fill,
              //                 ),
              //               ),
              //             )
              //           : Text('Pan Card'),
              //     ),
              //   ),
              // ),
              // const SizedBox(
              //   height: 16,
              // ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 12.0),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: GestureDetector(
              //           onTap: () {
              //             pickImage('aadharFront');
              //           },
              //           child: Container(
              //             height: MediaQuery.of(context).size.height * 0.2,
              //             // width: MediaQuery.of(context).size.width * 0.8,
              //             decoration: BoxDecoration(
              //               color: Colors.white,
              //               borderRadius: BorderRadius.circular(26),
              //               boxShadow: [
              //                 BoxShadow(
              //                   color: Color(0xFF6F8CB0).withOpacity(0.55),
              //                   blurRadius: 16.0,
              //                 ),
              //               ],
              //             ),
              //             child: Center(
              //               child: aadharFrontImage != null
              //                   ? Container(
              //                       decoration: BoxDecoration(
              //                         borderRadius: BorderRadius.circular(26),
              //                         image: DecorationImage(
              //                           image: Image.file(
              //                             File(aadharFrontImage!.path),
              //                             // fit: BoxFit.cover,
              //                           ).image,
              //                           fit: BoxFit.fill,
              //                         ),
              //                       ),
              //                     )
              //                   : const Text(
              //                       'Aadhar Card \n front',
              //                       textAlign: TextAlign.center,
              //                     ),
              //             ),
              //           ),
              //         ),
              //       ),
              //       const SizedBox(
              //         width: 8,
              //       ),
              //       Expanded(
              //         child: GestureDetector(
              //           onTap: () {
              //             pickImage('aadharBack');
              //           },
              //           child: Container(
              //             height: MediaQuery.of(context).size.height * 0.2,
              //             // width: MediaQuery.of(context).size.width * 0.8,
              //             decoration: BoxDecoration(
              //               color: Colors.white,
              //               borderRadius: BorderRadius.circular(26),
              //               boxShadow: [
              //                 BoxShadow(
              //                   color: Color(0xFF6F8CB0).withOpacity(0.55),
              //                   blurRadius: 16.0,
              //                 ),
              //               ],
              //             ),
              //             child: Center(
              //               child: aadharBackImage != null
              //                   ? Container(
              //                       decoration: BoxDecoration(
              //                         borderRadius: BorderRadius.circular(26),
              //                         image: DecorationImage(
              //                           image: Image.file(
              //                             File(aadharBackImage!.path),
              //                             // fit: BoxFit.cover,
              //                           ).image,
              //                           fit: BoxFit.fill,
              //                         ),
              //                       ),
              //                     )
              //                   : const Text(
              //                       'Aadhar Card \n back',
              //                       textAlign: TextAlign.center,
              //                     ),
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // const SizedBox(
              //   height: 20,
              // ),
              GestureDetector(
                onTap: () {
                  _saveAgentDetails();
                },
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFF30315C),
                        ),
                        child: const Center(
                          child: Text(
                            "SAVE",
                            style: TextStyle(
                              color: Color(0xFFD6DBEE),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
