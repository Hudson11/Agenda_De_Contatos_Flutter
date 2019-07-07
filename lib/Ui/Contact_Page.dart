import 'dart:io';

import 'package:agenda_de_contatos/Helpers/contact_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {

  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  Contact _editedContact;

  bool _userEdited;

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();

  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if(widget.contact == null)
      this._editedContact = Contact();
    else
      this._editedContact = Contact.fromMap(widget.contact.toMap());

    this._nomeController.text = this._editedContact.nome;
    this._emailController.text = this._editedContact.email;
    this._telefoneController.text = this._editedContact.telefone;
  }

  Future<bool> _requestPop(){
    if(this._userEdited == true){
      showDialog(context: context,
        builder: (context){
        return AlertDialog(
          title: Text('Descartar Altarações ?'),
          content: Text('Se sair as alterações seram perdidas'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancelar'),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('Sim'),
              onPressed: (){
                Navigator.pop(context);
                Navigator.pop(context);
              },
            )
          ],
        );
      }
      );
      return Future.value(false);
    } else{
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: this._requestPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editedContact.nome ?? 'Novo Contato'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if(this._nomeController.text.isNotEmpty && this._nomeController != null)
              Navigator.pop(context, this._editedContact);
            else
              FocusScope.of(context).requestFocus(this._nameFocus);
          },
          backgroundColor: Colors.green,
          child: Icon(Icons.save, color: Colors.white,),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  ImagePicker.pickImage(source: ImageSource.camera).then((file){
                    if(file == null)
                      return;
                    setState(() {
                      this._editedContact.img = file.path;
                    });
                  });
                },
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: this._editedContact.img != null ? FileImage(
                              File(this._editedContact.img)
                          ) : AssetImage('images/avatar.png'),
                        fit: BoxFit.cover
                      )
                  ),
                ),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Nome', ),
                onChanged: (text){
                  this._userEdited = true;
                  setState(() {
                    _editedContact.nome = text;
                  });
                },
                controller: this._nomeController,
                focusNode: this._nameFocus,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Email', ),
                onChanged: (text){
                  this._userEdited = true;
                  this._editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
                controller: this._emailController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Telefone',),
                onChanged: (text){
                  this._userEdited = true;
                  this._editedContact.telefone = text;
                },
                keyboardType: TextInputType.number,
                controller: this._telefoneController,
              )
            ],
          ),
        ),
      ),
    );
  }

}

