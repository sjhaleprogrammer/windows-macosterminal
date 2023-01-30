import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_pty/flutter_pty.dart';

import 'package:window_manager/window_manager.dart';
import 'package:xterm/xterm.dart';


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

  final terminal = Terminal(
    maxLines: 10000,
  );


  final terminalController = TerminalController();

  late final Pty pty;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.endOfFrame.then(
      (_) {
        if (mounted) _startPty();
      },
    );
  }

  void _startPty() {
    pty = Pty.start(
      shell,
      columns: terminal.viewWidth,
      rows: terminal.viewHeight,
    );

    pty.output
        .cast<List<int>>()
        .transform(const Utf8Decoder())
        .listen(terminal.write);

    pty.exitCode.then((code) {
      terminal.write('the process exited with exit code $code');
    });

    terminal.onOutput = (data) {
      pty.write(const Utf8Encoder().convert(data));
    };

    terminal.onResize = (w, h, pw, ph) {
      pty.resize(h, w);
    };
  }




   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: 
        Padding(
          padding: const EdgeInsets.only(top: 25),
          child: SafeArea(
            child: TerminalView(
              terminal,
              controller: terminalController,
              autofocus: true,
              //backgroundOpacity: 0.7,
              onSecondaryTapDown: (details, offset) async {
                final selection = terminalController.selection;
                if (selection != null) {
                  final text = terminal.buffer.getText(selection);
                  terminalController.clearSelection();
                  await Clipboard.setData(ClipboardData(text: text));
                } else {
                  final data = await Clipboard.getData('text/plain');
                  final text = data?.text;
                  if (text != null) {
                    terminal.paste(text);
                  }
                }
              },
            ),
          ),
        ),



      );
    
  }
}


String get shell {
  if (Platform.isMacOS || Platform.isLinux) {
    return Platform.environment['SHELL'] ?? 'bash';
  }

  if (Platform.isWindows) {
    return 'cmd.exe';
  }

  return 'sh';
}





















































 
  



 
 




           
                


                
                    
                                                            
                      
                   







