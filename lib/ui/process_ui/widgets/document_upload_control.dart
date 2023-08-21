import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:registration_client/model/upload_document_data.dart';
import 'package:registration_client/pigeon/document_pigeon.dart';
import 'package:registration_client/provider/registration_task_provider.dart';
//import 'package:registration_client/ui/process_ui/widgets/dropdown_control.dart';
//import 'package:registration_client/ui/process_ui/widgets/dropdown_document_control.dart';
import 'package:registration_client/ui/scanner/scanner.dart';

import '../../../model/field.dart';
import '../../../provider/global_provider.dart';
import 'custom_label.dart';

class DocumentUploadControl extends StatefulWidget {
  const DocumentUploadControl(
      {super.key, required this.validation, required this.field});

  final RegExp validation;
  final Field field;
  //  final Field field;
  // final RegExp validation;
  // final Function(String) onChanged;

  @override
  State<DocumentUploadControl> createState() => _DocumentUploadControlState();
}

class _DocumentUploadControlState extends State<DocumentUploadControl> {
  @override
  void initState() {
    //load from the map
    final scannedPagesMap =
        context.read<GlobalProvider>().scannedPages[widget.field.id];

    if (scannedPagesMap != null) {
      setState(() {
        imageBytesList = scannedPagesMap;
      });
    }

    if (context
        .read<GlobalProvider>()
        .fieldInputValue
        .containsKey(widget.field.id ?? "")) {
      // _getSelectedValueFromMap("eng");
      selected = context
          .read<GlobalProvider>()
          .fieldInputValue[widget.field.id]
          .title!;
    }

    super.initState();
  }

  void focusNextField(FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  List<String> poaList = [];
  List<Uint8List?> imageBytesList = []; // list of image bytes

  void _getSavedDocument() async {
    final listofscannedDoc = await context
        .read<RegistrationTaskProvider>()
        .getScannedDocument(widget.field.id!);
    setState(() {
      imageBytesList = listofscannedDoc;
    });
  }

  Future<void> addDocument(String item, Field e) async {
    final bytes = await getImageBytes(item);

    print("The selected value for dropdown for ${e.id!} is ${selected}");
    Uint8List myBytes = Uint8List.fromList(bytes);
    context
        .read<RegistrationTaskProvider>()
        .addDocument(e.id!, selected!, "reference", myBytes);
  }

  Future<void> getScannedDocuments(Field e) async {
    try {
      final listofscannedDoc = await DocumentApi().getScannedPages(e.id!);
      context.read<GlobalProvider>().setScannedPages(e.id!, listofscannedDoc);
      setState(() {
        imageBytesList = listofscannedDoc;
        doc.listofImages = imageBytesList;
      });
      if (doc.title.isNotEmpty && doc.title != null) {
        context.read<GlobalProvider>().fieldInputValue[widget.field.id!] = doc;
      }
    } catch (e) {
      print("Error while getting scanned pages ${e}");
    }
  }

  Future<List<int>> getImageBytes(String imagePath) async {
    final File imageFile = File(imagePath);
    if (!imageFile.existsSync()) {
      throw Exception("File not found");
    }
    return await imageFile.readAsBytes();
  }

  //String selectedValue = '';
  UploadDocumentData doc = UploadDocumentData(
    title: "", //update this when ever the dropdown button value changes

    listofImages: [
      // "assets/images/Left Eye@2x.png",
      // "assets/images/Right Eye@2x.png" //update this whenever image is added
    ],
  );
  String? selected;
  // void onDropDownChanged(String value) {
  //   setState(() {
  //     selectedValue = value;
  //   });
  // }

  void saveData(value) {
    if (value != null) {
      if (widget.field.type == 'simpleType') {
        context
            .read<RegistrationTaskProvider>()
            .addSimpleTypeDemographicField(widget.field.id ?? "", value, "eng");
      } else {
        context
            .read<RegistrationTaskProvider>()
            .addDemographicField(widget.field.id ?? "", value);
      }
    }
  }

  void _saveDataToMap(value) {
    if (value != null) {
      if (widget.field.type == 'simpleType') {
        context.read<GlobalProvider>().setLanguageSpecificValue(
              widget.field.id ?? "",
              value!,
              "eng",
              context.read<GlobalProvider>().fieldInputValue,
            );
      } else {
        context.read<GlobalProvider>().setInputMapValue(
              widget.field.id ?? "",
              value!,
              context.read<GlobalProvider>().fieldInputValue,
            );
      }
    }
  }

  //void _getSelectedValueFromMap(String lang) {
  //  String response = "";
  // if (widget.field.type == 'simpleType') {
  //   if ((context.read<GlobalProvider>().fieldInputValue[widget.field.id ?? ""]
  //           as Map<String, dynamic>)
  //       .containsKey(lang)) {
  //     response = context
  //         .read<GlobalProvider>()
  //         .fieldInputValue[widget.field.id ?? ""][lang];
  //   }
  // } else {
  //   response =
  //       context.read<GlobalProvider>().fieldInputValue[widget.field.id ?? ""];
  // }
  //   setState(() {
  //     selected = response;
  //   });
  // }

  Future<List<String?>> _getDocumentValues(
      String fieldName, String langCode, String? applicantType) async {
    return await context
        .read<RegistrationTaskProvider>()
        .getDocumentValues(fieldName, langCode, applicantType);
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 750;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CustomLabel(field: widget.field),
                    // const SizedBox(
                    //   height: 10,
                    // ),
                    FutureBuilder(
                        future: _getDocumentValues(widget.field.subType!, "eng",
                            null), //TODO: drive the applicant type
                        builder: (BuildContext context,
                            AsyncSnapshot<List<String?>> snapshot) {
                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 1, horizontal: 12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 24, horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomLabel(field: widget.field),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  snapshot.hasData
                                      ? DropdownButtonFormField(
                                          icon: const Icon(null),
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16.0),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: const BorderSide(
                                                color: Colors.grey,
                                                width: 1.0,
                                              ),
                                            ),
                                            hintText: "Select Option",
                                            hintStyle: const TextStyle(
                                                color: Color(0xff999999)),
                                          ),
                                          items: snapshot.data!
                                              .map((option) => DropdownMenuItem(
                                                    value: option,
                                                    child: Text(option!),
                                                  ))
                                              .toList(),
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          value: selected,
                                          validator: (value) {
                                            if (!widget.field.required! &&
                                                widget.field.requiredOn!
                                                    .isEmpty) {
                                              return null;
                                            }
                                            if ((value == null ||
                                                    value.isEmpty) &&
                                                widget.field.inputRequired!) {
                                              return 'Please enter a value';
                                            }
                                            if (!widget.validation
                                                .hasMatch(value!)) {
                                              return 'Invalid input';
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {
                                            saveData(value);
                                            //_saveDataToMap(value);
                                            //create object for uploadDocument
                                            //update the title value with the  value

                                            setState(() {
                                              selected = value!;
                                              doc.title = value;
                                              // widget.onChanged(
                                              //     selected!); // Call the callback function
                                            });
                                          },
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                            ),
                          );
                        }),

                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              var doc = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Scanner(title: "Scan Document")),
                              );

                              await addDocument(doc, widget.field);
                              await getScannedDocuments(widget.field);
                            },
                            child: Text(
                              "Scan",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    imageBytesList.isNotEmpty
                        ? Container(
                            height: 80,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: imageBytesList.map((item) {
                                return Card(
                                  child: Container(
                                    height: 70,
                                    width: 90,
                                    child: Image.memory(item!),
                                  ),
                                );
                              }).toList(),
                            ))
                        : Container(),
                  ],
                )
              : Column(
                  children: [
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     CustomLabel(field: widget.field),
                    //   ],
                    // ),
                    // const SizedBox(
                    //   height: 10,
                    // ),
                    Row(
                      children: [
                        Expanded(
                            // child: DropDownDocumentControl(
                            //   field: widget.field,
                            //   validation: widget.validation,
                            //   onChanged: onDropDownChanged,
                            // ),
                            child: FutureBuilder(
                                future: _getDocumentValues(
                                    widget.field.subType!,
                                    "eng",
                                    null), //TODO: drive the applicant type
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<String?>> snapshot) {
                                  return Card(
                                    elevation: 0,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 1, horizontal: 12),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 24, horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomLabel(field: widget.field),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          snapshot.hasData
                                              ? DropdownButtonFormField(
                                                  icon: const Icon(null),
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 16.0),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      borderSide:
                                                          const BorderSide(
                                                        color: Colors.grey,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    hintText: "Select Option",
                                                    hintStyle: const TextStyle(
                                                        color:
                                                            Color(0xff999999)),
                                                  ),
                                                  items: snapshot.data!
                                                      .map((option) =>
                                                          DropdownMenuItem(
                                                            value: option,
                                                            child:
                                                                Text(option!),
                                                          ))
                                                      .toList(),
                                                  autovalidateMode:
                                                      AutovalidateMode
                                                          .onUserInteraction,
                                                  value: selected,
                                                  validator: (value) {
                                                    if (!widget
                                                            .field.required! &&
                                                        widget.field.requiredOn!
                                                            .isEmpty) {
                                                      return null;
                                                    }
                                                    if ((value == null ||
                                                            value.isEmpty) &&
                                                        widget.field
                                                            .inputRequired!) {
                                                      return 'Please select a value';
                                                    }
                                                    if (!widget.validation
                                                        .hasMatch(value!)) {
                                                      return 'Invalid input';
                                                    }
                                                    return null;
                                                  },
                                                  onChanged: (value) {
                                                    saveData(value);
                                                    //_saveDataToMap(value);
                                                    //create object for uploadDocument
                                                    //update the title value with the  value

                                                    setState(() {
                                                      selected = value!;
                                                      doc.title = value;
                                                      // widget.onChanged(
                                                      //     selected!); // Call the callback function
                                                    });
                                                  },
                                                )
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                  );
                                })),
                        const SizedBox(
                          width: 50,
                        ),
                        Container(
                          width: 300,
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    var doc = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Scanner(title: "Scan Document")),
                                    );

                                    await addDocument(doc, widget.field);

                                    await getScannedDocuments(widget.field);
                                  },
                                  child: Text(
                                    "Scan",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    imageBytesList.isNotEmpty
                        ? Container(
                            height: 80,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: imageBytesList.map((item) {
                                return Card(
                                  child: Container(
                                    height: 70,
                                    width: 90,
                                    child: Image.memory(item!),
                                  ),
                                );
                              }).toList(),
                            ))
                        : Container(),
                  ],
                ),
        ),
      ),
    );
  }
}

// class DropDownDocumentControl extends StatefulWidget {
//   const DropDownDocumentControl({
//     super.key,
//     required this.field,
//     required this.validation,
//     required this.onChanged,
//   });

//   @override
//   State<DropDownDocumentControl> createState() => _CustomDropDownState();
// }

// class _CustomDropDownState extends State<DropDownDocumentControl> {
//   String? selected;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future: _getDocumentValues(widget.field.subType!, "eng",
//             null), //TODO: drive the applicant type
//         builder: (BuildContext context, AsyncSnapshot<List<String?>> snapshot) {
//           return Card(
//             elevation: 0,
//             margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 12),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   CustomLabel(field: widget.field),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   snapshot.hasData
//                       ? DropdownButtonFormField(
//                           icon: const Icon(null),
//                           decoration: InputDecoration(
//                             contentPadding:
//                                 const EdgeInsets.symmetric(horizontal: 16.0),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8.0),
//                               borderSide: const BorderSide(
//                                 color: Colors.grey,
//                                 width: 1.0,
//                               ),
//                             ),
//                             hintText: "Select Option",
//                             hintStyle:
//                                 const TextStyle(color: Color(0xff999999)),
//                           ),
//                           items: snapshot.data!
//                               .map((option) => DropdownMenuItem(
//                                     value: option,
//                                     child: Text(option!),
//                                   ))
//                               .toList(),
//                           autovalidateMode: AutovalidateMode.onUserInteraction,
//                           value: selected,
//                           validator: (value) {
//                             if (!widget.field.required! &&
//                                 widget.field.requiredOn!.isEmpty) {
//                               return null;
//                             }
//                             if ((value == null || value.isEmpty) &&
//                                 widget.field.inputRequired!) {
//                               return 'Please enter a value';
//                             }
//                             if (!widget.validation.hasMatch(value!)) {
//                               return 'Invalid input';
//                             }
//                             return null;
//                           },
//                           onChanged: (value) {
//                             saveData(value);
//                             //_saveDataToMap(value);
//                             //create object for uploadDocument
//                             //update the title value with the  value

//                             setState(() {
//                               selected = value!;
//                               widget.onChanged(
//                                   selected!); // Call the callback function
//                             });
//                           },
//                         )
//                       : const SizedBox.shrink(),
//                 ],
//               ),
//             ),
//           );
//         });
//   }
// }
