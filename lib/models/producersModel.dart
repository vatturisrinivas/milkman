class Milkman{
  String id;
  String name;
  String phone;

  Milkman({required this.id,required this.name, required this.phone});

  //convert firestore data to model
  factory Milkman.fromMap(String id,Map<String,dynamic> data){
    return Milkman(
      id: id,
      name: data['name']??'',
      phone: data['phone']??''
    );
  }

  //convert model to firestore data
  Map<String,dynamic> toMap(){
    return{
      'name': name,
      'phone': phone
    };
  }
}