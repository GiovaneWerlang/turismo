import 'dart:convert';
import 'package:http/http.dart';
import '../model/cep.dart';

class CepService{
  static const _base_url = 'https://viacep.com.br/ws/:cep/json/';

  Future<Map<String, dynamic>> findCep(String cep) async {
    final url = _base_url.replaceAll(':cep', cep);
    final uri = Uri.parse(url);
    final Response response = await get(uri);
    if(response.statusCode != 200 || response.body.isEmpty){
      throw Exception();
    }
    final decodedBody = json.decode(response.body);
    return Map<String, dynamic>.from(decodedBody);
  }

  Future<Cep> findCepAsObject(String cep) async{
    final map = await findCep(cep);
    return Cep.fromJson(map);
  }

}