import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      accentColor: Colors.blueAccent,
      primaryColor: Colors.blue,
    ),
  ));
}

class Home extends StatefulWidget {
  @override

  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _tarefas = [];
  TextEditingController _controlador = TextEditingController();

  void _adicionarLista() {
    if(_controlador.text.trim().isEmpty) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Tarefa vazia não pode ser incluida!"),
        duration: Duration(seconds: 1),
      ));
    } else {
    setState(() {
      Map<String, dynamic> Lista = Map();
      Lista["title"] = _controlador.text;
      _controlador.text = "";
      Lista["ok"] = false;
      _tarefas.add(Lista);
      _SaveData();
    });
  }}

  Map<String, dynamic> _lastRemove;
  int _LastRemovePos;

  Future<Null> _resetar() async{
    await Future.delayed((Duration(seconds: 1)));

    setState(() {
      _tarefas.sort((a, b){
        if(a["ok"] && !b["ok"]) return 1;
        else if(!a["ok"] && b["ok"]) return -1;
        else return 0;
      });
      _SaveData();
    });

    return null;
  }

  GlobalKey<FormState> _chave = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Form(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      key: _chave,
                      decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.blueAccent),
                      ),
                      controller: _controlador,
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  RaisedButton(
                    color: Colors.blueAccent,
                    textColor: Colors.white,
                    child: Text("ADD"),
                    onPressed: () {
                        _adicionarLista();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(onRefresh: _resetar,
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 10.0),
                    itemCount: _tarefas.length,
                    itemBuilder: itemBuilder),),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemBuilder(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.redAccent,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white,),
        )
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_tarefas[index]["title"]),
        value: _tarefas[index]["ok"],
        onChanged: (c) {
          setState(() {
            _tarefas[index]["ok"] = c;
            _SaveData();
          });
        },
        secondary: CircleAvatar(
          child: Icon(_tarefas[index]["ok"] ? Icons.check : Icons.error),
        ),
      ),
      onDismissed: (direction){
        setState(() {
          _lastRemove = Map.from(_tarefas[index]);
          _LastRemovePos = index;
          _tarefas.removeAt(index);

          _SaveData();

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemove["title"]}\" Removida"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _tarefas.insert(_LastRemovePos, _lastRemove);
                  _SaveData();
                });
              },
            ),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }




  @override
  void initState() {
    super.initState();
    _ReadData().then((data) {
      setState(() {
        _tarefas = json.decode(data);
      });
    });
  }

  Future<File> _arquivo() async {
    final local = await getApplicationDocumentsDirectory();
    return File("${local.path}/tarefas.json");
  }

  Future<File> _SaveData() async {
    String data = json.encode(_tarefas);
    final arquivoCriado = await _arquivo();
    arquivoCriado.writeAsString(data);
  }

  Future<String> _ReadData() async {
    try {
      final arquivoCriado = await _arquivo();
      return arquivoCriado.readAsString();
    } catch (error) {
      return null;
    }
  }
}

