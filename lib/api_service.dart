
import 'package:dio/dio.dart';

class ApiService{
   String baseUrl ='https://notification-server-7x4h.onrender.com';
   Dio dio =Dio();
   Future<void> sentNotification(
       String title,
       String body,
       String token
       )async{
try{
   final response = await dio.post('${baseUrl}/send',data:{
      "fcm_token": token,
      "title": title,
      "body": body
   } ,
       options: Options(headers: {
          'Content-Type': 'application/json',
       })
   ); print('Response data: ${response.data}');
}catch(e){
   print('Error occurred: $e');
}
   }
}