import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'instafetch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Insta reel downlaoder'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('app.channel.shared.data');
  String dataShared = 'No data';
  String dataShared1 = 'No data';
  Future<void> getSharedText() async {
    var sharedData = await platform.invokeMethod('getSharedText');

    if (sharedData != null) {
      setState(() {
        dataShared = sharedData;
      });
    }
  }


  Future<String> get_lambda(BuildContext context) async {
    try {
      String data_o = dataShared ;
      List<String> urlParts = data_o.split('/');

      // Ensure there are at least n+1 parts
      if (urlParts.length > 5) {
        urlParts.removeRange(5, urlParts.length);
      }

      data_o = urlParts.join("/");
      String uriString = 'https://s91n92jsr5.execute-api.ap-southeast-2.amazonaws.com/default/instasuck?image_url=${Uri.encodeFull(data_o)}';
      Uri uri = Uri.parse(uriString);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        String jsonString = response.body.toString();
        print(jsonString);
        // Find the index of the second backslash (\)
        int startIndex = jsonString.indexOf('\\', jsonString.indexOf('\\') + 1);

        // Find the index of the third backslash (\) after the second one
        int endIndex = jsonString.indexOf('\\', startIndex + 1);

        // Extract the substring between the second and third backslashes
        String videoUrlSubstring = jsonString.substring(startIndex + 1, endIndex);
        print(videoUrlSubstring);
        // Replace escaped double quotes (\") with a single double quote (")
        String videoUrl = videoUrlSubstring.replaceAll('\\"', '"');
        print(videoUrl);
        setState(() {
          dataShared1 =videoUrl.replaceAll('\"', '');
        });
        launchUrl(Uri.parse(dataShared1));
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
    return 'no';
  }

  @override
  void initState() {
    super.initState();
    getSharedText();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'YOUR INSTAGRAM REEL IS BELOW,\n      {CLICK + TO DOWNLOAD}',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            Text(
              '$dataShared',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          get_lambda(context);
        },

        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
