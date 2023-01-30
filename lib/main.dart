import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import 'package:window_manager/window_manager.dart';



// colors to be placed in a different location
final closeButton = WindowButtonColors(
  iconNormal: Colors.transparent,
  mouseOver: Colors.transparent,
  mouseDown: Colors.transparent,
  iconMouseOver: Colors.transparent,
  iconMouseDown: Colors.transparent,
);

final minimizeButton = WindowButtonColors(
  iconNormal: Colors.transparent,
  mouseOver: Colors.transparent,
  mouseDown: Colors.transparent,
  iconMouseOver: Colors.transparent,
  iconMouseDown: Colors.transparent,
);

final maximizeButton = WindowButtonColors(
  iconNormal: Colors.transparent,
  mouseOver: Colors.transparent,
  mouseDown: Colors.transparent,
  iconMouseOver: Colors.transparent,
  iconMouseDown: Colors.transparent,
  
);



void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  windowManager.ensureInitialized();

  Window.initialize();
  Window.hideWindowControls();
  
  Window.setEffect(effect: WindowEffect.transparent);
  
  doWhenWindowReady(() async {

    await windowManager.setAsFrameless();
    await windowManager.setHasShadow(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    const initialSize = Size(550, 405);

    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    windowManager.show();


  });
  

  runApp(const MyApp());

  
}




class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            children: [
              
              /// Fake window border
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: child!,
                  ),
                ),
              ),
              

              /// Resizable Border
              const DragToResizeArea(
                enableResizeEdges: [
                  ResizeEdge.topLeft,
                  ResizeEdge.top,
                  ResizeEdge.topRight,
                  ResizeEdge.left,
                  ResizeEdge.right,
                  ResizeEdge.bottomLeft,
                  ResizeEdge.bottomLeft,
                  ResizeEdge.bottomRight,
                ],
                child: SizedBox(),
              ),



              Column(children: [

                  //TITLEBAR
                  Container(
                    height: 31, 
                    width: double.infinity, 
                    color: const Color.fromARGB(255, 240, 241, 240),
                    child: MoveWindow(
                      child: const Center(
                        child: Material(
                          child: Text(
                            "Samuel - -bash -- 80x24",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ),

              ]),

                  
              
              //BUTTONS
              Row(children: [

                

                const SizedBox(height: 10,width: 8.586),
              
                Container(
                  height: 12.7,
                  width: 12.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 255, 95, 87),
                    border: Border.all(width: 0.3, color: const Color(0xCCB4604F)),
                  ),
                  child: CloseWindowButton(colors: closeButton,),
                  
                  
                ),

                const SizedBox(height: 10,width: 8),
                
                Container(
                  height: 12.7,
                  width: 12.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(193, 255, 189, 46),
                    border: Border.all(width: 0.3, color: const Color(0xCCCBA049)),
                  ),
                  child: MinimizeWindowButton(colors: minimizeButton,),
                  
                  
                ),
                
                const SizedBox(height: 10,width: 8.2),

                Container(
                  height: 12.7,
                  width: 12.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(204, 38, 200, 65),
                    border: Border.all(width: 0.3, color: const Color(0xCC599548)),
                  ),
                  child: MaximizeWindowButton(colors: maximizeButton,),
                  
                ),

                
                
                const Padding(padding:EdgeInsets.only(bottom: 35)),

              ]),
              
            ],
          ),
        );
      },
      title: 'Flutter Demo',
      theme: ThemeData(
            primarySwatch: Colors.blue,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            scrollbarTheme: const ScrollbarThemeData().copyWith(
              thickness: MaterialStateProperty.all(6.15),
            )),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
  
  
}




class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  final _controller = TextEditingController();
  String _output = '';


  
  
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: Column(
      children: [

        
        Expanded(
          child: Container(
            width: double.infinity,
            color: Colors.black,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_output, style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ),


        Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(prefix: Text('Samuel~ ',style: TextStyle(color: Colors.white)),isDense: false,),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (value) async {
                _output = '';
                setState(() {});
                final process = await Process.start('powershell', ['-NoExit']);
                process.stdout.listen((data) {
                  setState(() {
                    _output += utf8.decode(data);
                  });
                });
                process.stderr.listen((data) {
                  setState(() {
                    _output += utf8.decode(data);
                  });
                });
                int exitCode = await process.exitCode;
                print("Exit code: $exitCode");
              },
            ),
          ),
        ),



      ],
    ),
  );


    
  }
}
























































 
  



 
 




           
                


                
                    
                                                            
                      
                   







