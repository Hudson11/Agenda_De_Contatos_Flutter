import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String contactTable = 'contactTable';
const String idColumn = 'idColumn';
const String nomeColumn = 'nomeColumn';
const String emailColumn = 'emailColumn';
const String telefoneColumn = 'telefoneColumn';
const String imgColumn = 'imgColumn';

class ContactHelper{

  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  // SqLite Instance
  Database _db;

  Future<Database> get db async{
    if(_db != null){
      return _db;
    } else{
      _db = await initDb();
    return _db;
    }
  }

  /*
  *  Inicia o Banco de Dados -> Cria a tabela contactTable
  *  params
  *  return: Future<Database> -> Um dado futuro.
  * */
  Future<Database> initDb() async{
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'contactsNew2.db');

    return await openDatabase(path, version: 1, onCreate: (Database db, int newVersion) async{
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY not null, $nomeColumn TEXT, $emailColumn TEXT,"
              "$telefoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async{
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async{
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable, columns: [idColumn,
      nomeColumn, emailColumn, telefoneColumn, imgColumn], where: '$idColumn = ?',
        whereArgs: [id]);

    if(maps.length > 0)
      return Contact.fromMap(maps.first);

    return null;
  }

  Future<int> deleteContact(int id) async{
    Database dbContact = await db;
    return
      await dbContact.delete(contactTable, where: '$idColumn = ?', whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async{
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(), where: '$idColumn = ?'
        , whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async{
    Database dbContact = await db;
    List<Map> maps = await dbContact.rawQuery('SELECT * FROM $contactTable');
    List<Contact> contacts = List();
    for(Map a in maps)
      contacts.add(Contact.fromMap(a));
    return contacts;
  }

  Future<int> getNumber() async{
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery('SELECT COUNT(*) FROM $contactTable'));
  }

  Future close() async{
    Database dbContact = await db;
    dbContact.close();
  }

}

/*
*  Model Class
* */
class Contact{

  int id;
  String nome;
  String email;
  String telefone;
  String img;

  Contact.fromMap(Map map){
    this.id = map[idColumn];
    this.nome = map[nomeColumn];
    this.email = map[emailColumn];
    this.telefone = map[telefoneColumn];
    this.img = map[imgColumn];
  }

  Contact();

  Map toMap(){
    Map<String, dynamic> map = {
      nomeColumn: this.nome,
      emailColumn: this.email,
      telefoneColumn: this.telefone,
      imgColumn: this.img
    };
    if(this.id != null){
      map[idColumn] =  this.id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $nome, email: $email, phone: $telefone, img: $img)";
  }

}