import 'dart:io';

import 'package:google_fonts/google_fonts.dart';
import 'package:luthfi_thesis/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luthfi_thesis/pages/result_page.dart';
import 'package:luthfi_thesis/widgets/headers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

import '../result.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = ScrollController();
  double offset = 0;
  String result;
  String path;
  var confidence;
  var label;
  var message;
  bool isResult = false;
  File imageURI;

  var percentageConfidence;

  Future getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(
      () {
        imageURI = image;
        path = image.path;
      },
    );
  }

  Future classifyImage() async {
    await Tflite.loadModel(
        model: "assets/model_unquant.tflite", labels: "assets/labels.txt");
    var output = await Tflite.runModelOnImage(path: path);
    var data = getResult(output);

    setState(
      () {
        result = data.toString();
        print(result);
        confidence = (data[0].confidence * 100).round().toString();
        label = data[0].label.toString();
      },
    );

    setState(() {
      result = data.toString();
      print(result);
      confidence = (data[0].confidence * 100).toStringAsFixed(2);
      label = data[0].label.toString();
      double confidenceInt = double.parse(confidence);
      if (confidenceInt > 70 && label == 'Pneumonia') {
        message = "Kamu terdeteksi tidak baik!";
      } else if (confidenceInt > 70 && label == 'Covid-19') {
        message = "Kamu terdeteksi tidak baik!";
      } else if (confidenceInt > 70 && label == 'Kanker') {
        message = "Kamu terdeteksi tidak baik!";
      } else if (confidenceInt > 70 && label == 'Normal') {
        message = "Kamu relatif baik!";
      } else if (confidenceInt <= 70 &&
          confidenceInt > 50 &&
          label == 'Pneumonia') {
        message = "Kamu perlu melakukan check up!";
      } else if (confidenceInt <= 70 &&
          confidenceInt > 50 &&
          label == 'Covid-19') {
        message = "Kamu perlu melakukan check up!";
      } else if (confidenceInt <= 70 &&
          confidenceInt > 50 &&
          label == 'Kanker') {
        message = "Kamu perlu melakukan check up!";
      } else if (confidenceInt <= 70 &&
          confidenceInt > 50 &&
          label == 'Normal') {
        message = "Kamu baik-baik saja!";
      } else {
        message = "Semua terlihat baik!";
      }
      // else if (confidenceInt <= 70 &&
      //     confidenceInt > 50 &&
      //     label == 'cataracts') {
      //   message = "Kamu harus mulai mencari perhatian medis!";
      // } else {
      //   message = "Kamu relatif baik!";
      // }
    });
    isResult = true;
  }

  List<Result> getResult(List<dynamic> output) {
    List<Result> data = List();

    output.forEach((element) {
      Result item = Result(
          confidence: element['confidence'],
          label: element['label'],
          message: element['message'],
          index: element['index']);
      data.add(item);
    });
    return data;
  }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   controller.addListener(onScroll);
  // }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   controller.dispose();
  //   super.dispose();
  // }

  void onScroll() {
    setState(() {
      offset = (controller.hasClients) ? controller.offset : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: controller,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MyHeader(
              image: "assets/icons/coronadr.svg",
              textTop: "Lebih tau",
              textBottom: "Penyakit Anda.",
              offset: offset,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Gejala",
                    style: kTitleTextstyle,
                  ),
                  SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SymptomCard(
                          image: "assets/images/headache.png",
                          title: "Sesak Nafas",
                          isActive: true,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        SymptomCard(
                          image: "assets/images/caugh.png",
                          title: "Batuk",
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        SymptomCard(
                          image: "assets/images/fever.png",
                          title: "Nyeri Dada",
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        SymptomCard(
                          image: "assets/images/fever.png",
                          title: "Asma",
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        SymptomCard(
                          image: "assets/images/caugh.png",
                          title: "Mudah Lelah",
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("Pencegahan", style: kTitleTextstyle),
                  SizedBox(height: 20),
                  PreventCard(
                    text:
                        "Kenakanlah masker pelindung saat sedang bekerja dan dalam kondisi udara yang kurang baik.",
                    image: "assets/images/3.png",
                    title: "Gunakan Masker",
                  ),
                  PreventCard(
                    text:
                        "Sebagian besar kuman atau virus penyebab penyakit paru-paru atau penyakit lainnya akan mudah menyebar melalui sentuhan.",
                    image: "assets/images/4.png",
                    title: "Mencuci Tangan",
                  ),
                  SizedBox(height: 20),
                  PreventCard(
                    text:
                        "Penyakit paru-paru disebabkan oleh zat-zat berbahaya, seperti toksin dan karsinogen, yang terkandung dalam rokok.",
                    image: "assets/images/2.png",
                    title: "Berhenti Merokok",
                  ),
                  SizedBox(height: 50),
                  Text("Lakukan Pengecekan", style: kTitleTextstyle),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => getImageFromGallery(),
                    child: UploadCard(
                      text:
                          "Anda dapat mengunggah foto CT-Scan Anda di sini dan sistem kami akan membantu memprediksi keluhan Anda.",
                      image: "assets/images/5.png",
                      title: "Unggah foto di sini",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 20),
                          // ElevatedButton(
                          //   style: ElevatedButton.styleFrom(
                          //     primary: Colors.white,
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(20),
                          //     ),
                          //   ),
                          //   onPressed: () => getImageFromGallery(),
                          //   child: UploadCard(
                          //     text:
                          //         "Anda dapat mengunggah foto CT-Scan Anda di sini dan sistem kami akan membantu memprediksi keluhan Anda.",
                          //     image: "assets/images/5.png",
                          //     title: "Unggah foto di sini",
                          //   ),
                          // ),
                          imageURI == null
                              ? Text("Belum ada gambar")
                              : Image.file(imageURI,
                                  width: 100, height: 100, fit: BoxFit.cover),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0)),
                              ),
                              child: Text(
                                'Jalankan Pendeteksi',
                                style: TextStyle(color: Colors.white),
                                // selectionColor: Colors.white,
                              ),
                              onPressed: () async {
                                classifyImage();
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ResultsPage(
                                        confidence: confidence,
                                        label: label,
                                        message: message,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          isResult
                              ? Container(
                                  margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(30.0)),
                                    ),
                                    child: Text(
                                      'Hasil Deteksi',
                                      style: TextStyle(color: Colors.white),
                                      // selectionColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      classifyImage();
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ResultsPage(
                                              confidence: confidence,
                                              label: label,
                                              message: message,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Text(
                                  "Klik untuk proses pendeteksian",
                                  style: GoogleFonts.raleway(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                          SizedBox(height: 50),
                          // confidence == null
                          //     ? Text("Confidence")
                          //     : Text(confidence + " %"),
                          // label == null ? Text("Label") : Text(label),
                          // message == null ? Text("Message") : Text(message)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class UploadCard extends StatelessWidget {
  final String image;
  final String title;
  final String text;
  final String path;

  const UploadCard({
    Key key,
    this.image,
    this.title,
    this.text,
    this.path,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 160,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            Container(
              height: 136,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 9),
                    blurRadius: 24,
                    color: kShadowColor,
                  ),
                ],
              ),
            ),
            Image.asset(image),
            Positioned(
              left: 150,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                height: 136,
                width: MediaQuery.of(context).size.width - 170,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      title,
                      style: kTitleTextstyle.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),
                    Expanded(
                      child: Text(
                        text,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.drive_folder_upload,
                        color: Colors.lightBlue[500],
                      ),
                      // child: SvgPicture.asset("assets/icons/forward.svg"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PreventCard extends StatelessWidget {
  final String image;
  final String title;
  final String text;
  const PreventCard({
    Key key,
    this.image,
    this.title,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 156,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            Container(
              height: 136,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 8),
                    blurRadius: 24,
                    color: kShadowColor,
                  ),
                ],
              ),
            ),
            Image.asset(image),
            Positioned(
              left: 135,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                height: 136,
                width: MediaQuery.of(context).size.width - 170,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      title,
                      style: kTitleTextstyle.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        text,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: SvgPicture.asset("assets/icons/forward.svg"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SymptomCard extends StatelessWidget {
  final String image;
  final String title;
  final bool isActive;
  const SymptomCard({
    Key key,
    this.image,
    this.title,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          isActive
              ? BoxShadow(
                  offset: Offset(0, 10),
                  blurRadius: 20,
                  color: kActiveShadowColor,
                )
              : BoxShadow(
                  offset: Offset(0, 3),
                  blurRadius: 6,
                  color: kShadowColor,
                ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Image.asset(image, height: 90),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
