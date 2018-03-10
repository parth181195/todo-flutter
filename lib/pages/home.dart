import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  @override
  State createState() => new HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin{
  TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
  }
  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("To Do"),
        centerTitle: true,
      ),
      body: new TabBarView(
        controller: _tabController,
        children: new List.generate( 2, (i) {
          List statusList = [true,false];
          return new Tasks(statusList[i]);
        })
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.add,),
        onPressed: () {
          Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => new AddTask()));
        },
      ),
      bottomNavigationBar: new TabBar(
        controller: _tabController,
        tabs: <Widget>[
          new Tab(child: new Icon(Icons.assignment)),
          new Tab(child: new Icon(Icons.assignment_turned_in)),
        ],
      ),
    );
  }
}

class Tasks extends StatefulWidget {
  final bool isDone;
  Tasks(this.isDone);
  @override
  State createState() => new TasksState();
}

class TasksState extends State<Tasks>{
  File jsonFile;
  Directory dir;
  String fileName = "Todo.json";
  bool fileExists = false;
  Map<String, dynamic> filecontent;
  String status;
  @override
  void initState() {
    super.initState();
    status = widget.isDone.toString();
    getApplicationDocumentsDirectory().then((Directory directory){
      dir = directory;
      print(dir);
      jsonFile = new File(dir.path + '/' + fileName);
      fileExists = jsonFile.existsSync();
      if(fileExists) {this.setState(() => filecontent = JSON.decode(jsonFile.readAsStringSync()));}
      else {
        print("Creating file!");
        File file = new File(dir.path + "/" + fileName);
        file.createSync();
        fileExists = true;
        file.writeAsStringSync(JSON.encode({'true' : [],'false' : []}));
        this.setState(() => filecontent = {'true' : [],'false' : []});
      }
      print(filecontent);
    });
  }
  
  @override
  Widget build(BuildContext context){
    return filecontent != null ? new Container(
    child: filecontent[status].length == 0 ? new Center(
      child: new Text('No tasks'),
      ) : new ListView.builder(
        itemCount: filecontent[status].length,
        itemBuilder: (context,index) {
          print(filecontent[status].length);
          var data = filecontent[status]; 
          Key key = new Key('Dismissible' + index.toString());
          return new Dismissible(
            key: key,
            background: new Container(
              padding: new EdgeInsets.only(left: 10.0),
              color: widget.isDone ? Colors.green : Colors.red,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[new Text(widget.isDone ? 'Task Done' : 'Task Removed from done',style: new TextStyle(fontSize: 16.0))],
              ),
            ),
            secondaryBackground: new Container(
              padding: new EdgeInsets.only(right: 10.0),
              color: widget.isDone ? Colors.green : Colors.red,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[new Text(widget.isDone ? 'Task Done' : 'Task Removed from done',style: new TextStyle(fontSize: 16.0))],
              ),
            ),
            onDismissed: (DismissDirection dir) {
              var currentData = filecontent[status][index];
              filecontent[status].removeAt(index);
              filecontent[(!widget.isDone).toString()].add(currentData);
              jsonFile.writeAsStringSync(JSON.encode(filecontent));
            },
            child: new Container(
              constraints: new BoxConstraints(minHeight: 50.0,minWidth: double.MAX_FINITE),
              padding: new EdgeInsets.symmetric(horizontal: 5.0,vertical: 10.0),
              decoration: new BoxDecoration(
                border: new BorderDirectional(bottom: new BorderSide(width: 0.5,color: Colors.white30))
              ),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[new Text(data[index]['text'],style: new TextStyle(fontSize: 16.0))],
              )
            )
          );
        },
      ) 
    ) : new Center(child: new Text('no data'),);
  }
}


class AddTask extends StatefulWidget {
  @override
  State createState() => new AddTaskState();
}

class AddTaskState extends State<AddTask>{
  TextEditingController textInputController = new TextEditingController();
  bool isText = false;
  File jsonFile;
  Directory dir;
  String fileName = "Todo.json";
  bool fileExists = false;
  Map<String, dynamic> filecontent;

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((Directory directory){
      dir = directory;
      print(dir);
      jsonFile = new File(dir.path + '/' + fileName);
      fileExists = jsonFile.existsSync();
      if(fileExists) this.setState(() => filecontent = JSON.decode(jsonFile.readAsStringSync()));
      print(filecontent);
    });
  }
  void writeToFile(String text) {
    if(fileExists){
      print('called');
      filecontent['true'].add({'text':text,"status": true});
      this.setState(() {
        textInputController.clear();
        jsonFile.writeAsStringSync(JSON.encode(filecontent));
      });
      print(filecontent);
      var future = new Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => new Home()));
      });
    } else {
    print("Creating file!");
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    fileExists = true;
    filecontent = {'true' : [{'isdone':false,'text':text}]};
    file.writeAsStringSync(JSON.encode(filecontent));

    }
  }
  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Add Task')
      ),
      body: new Container(
        padding: new EdgeInsets.all(10.0),
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new TextField(
                controller: textInputController,
                decoration: new InputDecoration(
                  hintText: 'Add Task'
                ),
                onSubmitted: (String str) {
                  writeToFile(str);
                },
                onChanged: (String str) {
                  if(str.length != 0) this.setState(() => isText = true);
                  else  this.setState(() => isText = false);;
                },
              ),
              new Padding(
                padding: new EdgeInsets.only(bottom: 30.0),
              ),
              new RaisedButton(
                child: new Text('Submit'),
                onPressed: !isText ? null : () => writeToFile(textInputController.text),
              )
            ],
          ),
        ),
      )
    );
  }
}
