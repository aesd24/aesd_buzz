class Dictionnary {

  // accountTypes
  static Type faithFul = Type(code: "fidele", name: "Fidèle");
  static Type servant = Type(code: "serviteur_de_dieu", name: "Serviteur de Dieu");
  static Type singer = Type(code: "chantre", name: "Chantre");

  static List<Type> get accountTypes => [faithFul, servant, singer];

  // churchs types
  static Type catholic = Type(code: "Catholique", name: "Catholique");
  static Type evangelic = Type(code: "Evangelique", name: "Evangélique");
  static Type orthodox = Type(code: "Orthodoxe", name: "Orthodoxe");
  static Type protestant = Type(code: "Protestante", name: "Protestante");
  static Type baptist = Type(code: "Baptiste", name: "Baptiste");

  static List<Type> get churchTypes => [catholic, evangelic, orthodox, protestant, baptist];

  // servant calls
  static Type apostal = Type(code: "APO", name: "Apôtre");
  static Type evangelist = Type(code: "EVA", name: "Evangéliste");
  static Type pastor = Type(code: "PAS", name: "Pasteur");
  static Type prophet = Type(code: "PRO", name: "Prophète");
  static Type doctor = Type(code: "DOC", name: "Docteur");

  static List<Type> get servantCalls => [
    apostal, evangelist, pastor, prophet, doctor
  ];
}


class Type {
  late String code;
  late String name;

  Type({required this.code, required this.name});
}