import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_publitio/flutter_publitio.dart';
import 'dart:io';
import 'video_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Homepage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    
    return Sample();
  }

}

class Sample extends State<Homepage>{

  bool _uploading = false;
  List<VideoInfo> _videos = <VideoInfo>[];

  bool _imagePickerActive = false;

  void _takeVideo() async {
    if (_imagePickerActive) return;
    final picker = ImagePicker();
    _imagePickerActive = true;
    File videoFile =  await ImagePicker.pickVideo(source: ImageSource.gallery);
  //  videoFile = await videoFile.rename("${videoFile.path}.mp4");
    _imagePickerActive = false;

    if (videoFile == null) return;

    setState(() {
      // _videos.add(videoFile.path);
    });


    setState(() {
  _uploading = true;
});

try {
  final response = await _uploadVideo(videoFile);
  final width = response["width"];
  final height = response["height"];
  final double aspectRatio = width / height;
  setState(() {
  final video = VideoInfo(
  videoUrl: response["url_preview"],
  thumbUrl: response["url_thumbnail"],
  coverUrl: getCoverUrl(response),
  aspectRatio:aspectRatio,
);
  uploadvideodetails(video);

  });
} on PlatformException catch (e) {
  print('${e.code}: ${e.message}');
  //result = 'Platform Exception: ${e.code} ${e.details}';
} finally {
  setState(() {
    _uploading = false;
  });
}
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
         child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _videos.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Center(),
                  ),
                );
              }),

      ),
floatingActionButton: FloatingActionButton(
  child: _uploading
      ? CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        )
      : Icon(Icons.add),
  onPressed: _takeVideo),

    );
  }
   
@override
void initState() {
  configurePublitio();
  super.initState();
}



static const PUBLITIO_PREFIX = "https://media.publit.io/file";

static getCoverUrl(response) {
  final publicId = response["public_id"];
  return "$PUBLITIO_PREFIX/$publicId.jpg";
}






static configurePublitio() async {
  await DotEnv().load('.env');
  await FlutterPublitio.configure(
      DotEnv().env['PUBLITIO_KEY'], DotEnv().env['PUBLITIO_SECRET']);
}

static _uploadVideo(videoFile) async {
  print('starting upload');
  final uploadOptions = {
    "privacy": "1",
    "option_download": "1",
    "option_transform": "1"
  };
  final response =
      await FlutterPublitio.uploadFile(videoFile.path, uploadOptions);
    
  return response;
}

void uploadvideodetails(VideoInfo video) async
{
await Firestore.instance.collection('videos').document().setData({
  "videoUrl": video.videoUrl,
  "thumbUrl": video.thumbUrl,
  "coverUrl": video.coverUrl,
  "aspectRatio": video.aspectRatio,
}); 


}

}






