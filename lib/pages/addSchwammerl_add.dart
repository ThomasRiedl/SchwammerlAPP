import 'package:schwammerlapp/constraints.dart/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {

  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {

  //form key
  final _formkey = GlobalKey<FormState>();
  // text for textfield
  String name = '';
  String info = '';
  // textfield

  final nameController = TextEditingController();
  final infoController = TextEditingController();

  _clearText() {
    nameController.clear();
    infoController.clear();
  }

  //Registering Users
  CollectionReference addCar =
      FirebaseFirestore.instance.collection('places');
  Future<void> _registerSchwammerl() {
    return addCar
        .add({'name': name, 'info': info})
        .then((value) => print('Schwammerl Added'))
        .catchError((_) => print('Something Error In registering Schwammerl'));
  }

  //Disposing Textfield
  @override
  void dispose() {
    nameController.dispose();
    infoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schwammerlplätze'),
      ),
      body: Form(
        key: _formkey,
        child: ListView(
          children: [
            CustomTextEditField(
              controller: nameController,
              labettxt: 'Name',
            ),
            CustomTextEditField(
              controller: infoController,
              labettxt: 'Info',
              valid: true,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _clearText,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.orange),
                  ),
                  child: const Text('Löschen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      setState(() {
                        name = nameController.text;
                        info = infoController.text;
                        _registerSchwammerl();
                        _clearText();
                        Navigator.pop(context);
                      });
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.orange),
                  ),
                  child: const Text('Platz speichern'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
