import 'dart:io';

import 'package:agenda_de_contatos/Helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Contact_Page.dart';

enum orderOptions {orderA_Z, orderZ_A}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  /*
  *  Carrega as informações do banco antes de renderizar o layout.
  * */
  @override
  void initState() {
    super.initState();
    this.getAllData();
  }

  /*
  *  param contact: opcional -> devemos passar o contato caso deseje atualizar
  *  as informações
  *  return recContact: -> Retorno das informações da tela de cadastro de
  *  um novo contato ou atualização
  *
  *  if recContat != null -> e o contact atuak também, então atualizaremos os
  *  valores, caso contrário basta salvar o recContact.
  * */
  void _showContactPage({Contact contact}) async{
    final recContact = await Navigator.push(context,
      MaterialPageRoute(
          builder: (context){
            return ContactPage(contact: contact);
          })
    );
    if(recContact != null){
      if(contact != null)
        await helper.updateContact(recContact);
      else
        await helper.saveContact(recContact);
      this.getAllData();
    }
  }

  /*
  *  Lista todos os registros do banco e atribui ao um List de contados.
  * */
  void getAllData(){
    helper.getAllContacts().then((list){
      setState(() {
        this.contacts = list;
        print(list);
      });
    });
  }

  /*
  *  Ordena os valores da lista em ordem alfabética (cresncente e decrenscente
  *  ( A_Z e Z_A)
  * */
  void _orderList(orderOptions result){
    switch(result){
      case orderOptions.orderA_Z:
        this.contacts.sort((a,b){
          return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        });
        break;
      case orderOptions.orderZ_A:
        this.contacts.sort((a,b){
          return b.nome.toLowerCase().compareTo(a.nome.toLowerCase());
        });
        break;
      default:
        break;
    }
    setState(() {
    });
  }

  void _showOptions(BuildContext context, int index){
    showModalBottomSheet(
        context: context,
        builder: (context){
          return BottomSheet(
            builder: (context){
              return Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Ligar', style: TextStyle(color: Colors.blue, fontSize: 20),),
                      onPressed: () {
                        launch('tel:${contacts[index].telefone}');
                        Navigator.pop(context);
                        },
                    ),
                    FlatButton(
                      child: Text('Editar', style: TextStyle(color: Colors.blue, fontSize: 20),),
                        onPressed: () {
                          Navigator.pop(context);
                          this._showContactPage(contact: this.contacts[index]);
                        }
                    ),
                    FlatButton(
                      child: Text('Remover', style: TextStyle(color: Colors.blue, fontSize: 20),),
                        onPressed: () {
                          helper.deleteContact(contacts[index].id);
                          Navigator.pop(context);
                          setState(() {
                            this.contacts.removeAt(index);
                          });
                        }
                    ),
                    FlatButton(
                        child: Text('Mensagem', style: TextStyle(color: Colors.blue, fontSize: 20),),
                        onPressed: () {
                          Navigator.pop(context);
                          launch('sms:${this.contacts[index].telefone}');
                        }
                    ),
                  ],
                ),
              );
            }, onClosing: () {},
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Contatos', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<orderOptions>(
            itemBuilder: (context){
              return <PopupMenuEntry<orderOptions>>[
                const PopupMenuItem<orderOptions>(
                    child: Text('Ordenar de A-Z'),
                  value: orderOptions.orderA_Z,
                ),
                const PopupMenuItem<orderOptions>(
                  child: Text('Ordenar de Z-A'),
                  value: orderOptions.orderZ_A,
                )
              ];
            },
            onSelected: (result){
             return this._orderList(result);
            },
          )
        ],
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white,),
        onPressed: (){
          this._showContactPage();
        }
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(5),
          itemBuilder: (context, index){
            return _contactCard(context, index);
          },
        itemCount: this.contacts.length,
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: this.contacts[index].img != null ? FileImage(
                        File(contacts[index].img)
                      ) : AssetImage('images/avatar.png'),
                    fit: BoxFit.cover
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(this.contacts[index].nome ?? '', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    Text(this.contacts[index].email ?? '', style: TextStyle(fontSize: 18)),
                    Text(this.contacts[index].telefone ?? '', style: TextStyle(fontSize: 18))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: (){
        this._showOptions(context, index);
      },
    );
  }
}
