import 'package:cached_network_image/cached_network_image.dart';
import 'package:cash_admin/models/agent.dart';
import 'package:flutter/material.dart';

class AgentDetailScreen extends StatefulWidget {
  final Agent agent;
  const AgentDetailScreen({super.key, required this.agent});

  @override
  State<AgentDetailScreen> createState() => _AgentDetailScreenState();
}

class _AgentDetailScreenState extends State<AgentDetailScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    _nameController.text = widget.agent.name;
    _phoneNumberController.text = widget.agent.phoneNumber;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF24274A),
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
        automaticallyImplyLeading: false,
        title: Text(
          widget.agent.name,
          style: TextStyle(color: Color(0xFFD6DBEE)),
        ),
      ),
      backgroundColor: Color(0xFFD6DBEE),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // pickImage("profile");
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
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(widget.agent.profileImageUrl),
                          fit: BoxFit.fill,
                        ),
                      ),
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
                    readOnly: true,
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
                    readOnly: true,
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
                height: 16,
              ),
              // GestureDetector(
              //   onTap: () {
              //     // pickImage('panCard');
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
              //         child:
              //             // panCardImage != null
              //             //     ?
              //             Container(
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(26),
              //         image: DecorationImage(
              //           image: CachedNetworkImageProvider(widget.user.panCardImageUrl),
              //           // CachedNetworkImage(
              //           //   imageUrl: widget.user.panCardImageUrl,
              //           // ).imageUrl,
              //           // Image.file(
              //           //   File(panCardImage!.path),
              //           //   // fit: BoxFit.cover,
              //           // ).image,
              //           fit: BoxFit.fill,
              //         ),
              //       ),
              //     )
              //         // : Text('Pan Card'),
              //         ),
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
              //             // pickImage('aadharFront');
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
              //                 child:
              //                     // aadharFrontImage != null
              //                     //     ?
              //                     Container(
              //               decoration: BoxDecoration(
              //                 borderRadius: BorderRadius.circular(26),
              //                 image: DecorationImage(
              //                   image: CachedNetworkImageProvider(widget.user.aadharFrontImageUrl),
              //                   // Image.file(
              //                   //   File(aadharFrontImage!.path),
              //                   //   // fit: BoxFit.cover,
              //                   // ).image,
              //                   fit: BoxFit.fill,
              //                 ),
              //               ),
              //             )
              //                 // : const Text(
              //                 //     'Aadhar Card \n front',
              //                 //     textAlign: TextAlign.center,
              //                 //   ),
              //                 ),
              //           ),
              //         ),
              //       ),
              //       const SizedBox(
              //         width: 8,
              //       ),
              //       Expanded(
              //         child: GestureDetector(
              //           onTap: () {
              //             // pickImage('aadharBack');
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
              //                 child:
              //                     // aadharBackImage != null
              //                     //     ?
              //                     Container(
              //               decoration: BoxDecoration(
              //                 borderRadius: BorderRadius.circular(26),
              //                 image: DecorationImage(
              //                   image: CachedNetworkImageProvider(widget.agent.aadharBackImageUrl),
              //                   // Image.file(
              //                   //   File(aadharBackImage!.path),
              //                   //   // fit: BoxFit.cover,
              //                   // ).image,
              //                   fit: BoxFit.fill,
              //                 ),
              //               ),
              //             )
              //                 // : const Text(
              //                 //     'Aadhar Card \n back',
              //                 //     textAlign: TextAlign.center,
              //                 //   ),
              //                 ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // // const SizedBox(
              //   height: 20,
              // ),
              // GestureDetector(
              //   onTap: () {
              //     // _saveUserPhoneNumber();
              //   },
              //   child: loading
              //       ? const Center(
              //           child: CircularProgressIndicator(),
              //         )
              //       : Container(
              //           height: 40,
              //           width: MediaQuery.of(context).size.width * 0.4,
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(10),
              //             color: Color(0xFF30315C),
              //           ),
              //           child: const Center(
              //             child: Text(
              //               "SUBMIT",
              //               style: TextStyle(
              //                 color: Color(0xFFD6DBEE),
              //                 fontSize: 16,
              //               ),
              //             ),
              //           ),
              //         ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
