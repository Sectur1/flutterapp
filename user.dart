import 'dart:core';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/rendering.dart';
import 'main.dart';

class Signup extends StatefulWidget{
  Signup({Key key}):super(key:key);
  SignupState createState()=>SignupState();
}
class Login extends StatefulWidget{
  Login({Key key}):super(key:key);
  LoginState createState()=>LoginState();
}
class LoginState extends State<Login>{
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController(); 
  String error = '';  
  double opacity = 0.0;
  Color color = Colors.blueAccent;
  Widget build(BuildContext context){
    return Container(
      child: Center(child: Wrap(
            children: <Widget>[
              Container(child: Center(child: Image.asset('assets/logo.png',height: 200,width: 200,)),color: Colors.white,),
              Center(
                child: Opacity(opacity:opacity,child: Container(child: Text(error,style: TextStyle(fontFamily: 'Comic',color: Colors.white, fontSize: 20,),),padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: color,),),
                ),),
              Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  autofocus: true,
                  onEditingComplete: ()=>setState(()=>opacity=0.0),
                  controller: _usernameController,
                  decoration: InputDecoration(icon: Icon(Icons.person,color: Colors.white,),fillColor: Colors.white,filled: true,hintText: "Username",border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10)),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  onEditingComplete: ()=>setState(()=>opacity=0.0),
                  decoration: InputDecoration(icon: Icon(Icons.enhanced_encryption,color: Colors.white,),fillColor: Colors.white,filled: true,hintText: "Password",border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10)),
                ),
              ),
              Container(margin: EdgeInsets.only(left:50,right: 50),constraints: BoxConstraints(maxHeight: 35),
                child: Container(margin: EdgeInsets.only(left: 100),decoration: BoxDecoration(borderRadius: BorderRadius.circular(7),color: Colors.blueAccent),width: 100,
                  child: FlatButton(child: Center(child: Text('Login',style: TextStyle(color: Colors.white,fontSize: 20),)),
                  onPressed: (){
                    if(_usernameController.text.isNotEmpty&&_passwordController.text.isNotEmpty){
                      void post()async{
                        FormData form = FormData.from({'username': _usernameController.text,'password': _passwordController.text});                        
                        await dio.post(url+'/login',data: form,).then((data)async{
                          if(data.toString() != 'error' ){  
                            await storage.write(key: 'status',value: 'loggedin');
                            String parseData = data.toString();
                            await storage.write(key: 'sessionid',value: parseData.substring(parseData.indexOf('=')+1,parseData.indexOf(';')));
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>Home())).catchError(()=>setState(()=>error='An error occurred try again'));
                          }else{
                            setState(() {
                              opacity = 1.0;
                              error = 'Invalid username or password';color = Colors.redAccent;
                            });
                          }
                        }).catchError((err){setState(() {
                          print(err);
                          setState(() {
                            opacity = 1.0;
                          error='Sorry an error occurred';color = Colors.redAccent;
                          });
                        });});
                      }
                      post();
                    }else{
                      opacity = 1.0;
                      setState(() {
                        error='Fill all the field';
                      });
                    }
                  },),
                ),
              decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(20)),)
            ],
          ),
          ),
          decoration: BoxDecoration(color: Colors.white),
    );
  }
}

class SignupState extends State<Signup>{
  String error='';
  double errorOpacity = 0;
  String _dobController,_genderController;
  FocusNode confirmFocusNode;
  FocusNode userFocusNode;
  FocusNode passwordFocusNode;
  FocusNode emailFocusNode;
  FocusNode nameFocusNode;
  FocusNode genderFocusNode;
  FocusNode phoneFocusNode;
  final GlobalKey<ScaffoldState> _scaffoldKey= GlobalKey();
  final ScrollController scrollController= ScrollController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();    
  final _nameController = TextEditingController();    
  final _emailController = TextEditingController();    
  final _phoneController = TextEditingController();    
  final _facebookController = TextEditingController();    
  final _twitterController = TextEditingController();    
  final _instagramController = TextEditingController();
  @override
  void initState(){
    super.initState();
    userFocusNode = FocusNode();
    confirmFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    emailFocusNode= FocusNode();
    nameFocusNode = FocusNode();
    phoneFocusNode = FocusNode();
  }
  @override
  void dispose(){
    userFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmFocusNode.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }    
  Widget build(BuildContext context){
    return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
        child: Container(color: Colors.white,
          child: Center(child: ListView(
            controller: scrollController,
            children: <Widget>[
            Container(child: Center(child: Image.asset('assets/logo.png',height: 80,width: 200,)),color: Colors.white,margin: EdgeInsets.all(10),),
              Center(child: Opacity(opacity: errorOpacity,child: Text(error,style: TextStyle(color: Colors.red,fontSize: 23)),)),                
              Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  autofocus: true,
                  focusNode: userFocusNode,
                  controller: _usernameController,
                  onEditingComplete: ()async{
                    await dio.post(url+'/confirm/username',data:_usernameController.text).then((val){
                      if(val.toString()== 'Already existed'){setState(() {
                        errorOpacity=1;error = 'User already exist change username';_usernameController.text = '';
                      });}else{setState(() {
                        error = '';errorOpacity=0;
                      });}
                    }).catchError((err)=>setState((){errorOpacity=0;error='An Error Occurred';errorOpacity=1;}));
                  },
                  decoration: InputDecoration(icon: Icon(Icons.person,color: Colors.white,),fillColor: Colors.white,filled: true,hintText: "Username",border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10)),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  onChanged: (val){if(val.length<8){setState((){errorOpacity=1;error='Password must not be less than 8 characters';});}else{
                    setState((){errorOpacity=0;error='Passwords did not match';});
                  }},
                  focusNode: passwordFocusNode,
                  decoration: InputDecoration(icon: Icon(Icons.enhanced_encryption,color: Colors.white,),fillColor: Colors.white,filled: true,hintText: "Password (min 8 characters)",border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10)),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  obscureText: true,
                  controller: _confirmController,
                  focusNode: confirmFocusNode,
                  onChanged: (val){if(val !=_passwordController.text){setState((){errorOpacity=1;error='Passwords did not match';});FocusScope.of(context).requestFocus(confirmFocusNode);}else{
                    setState((){errorOpacity=0;error='Passwords did not match';});FocusScope.of(context).requestFocus(nameFocusNode);
                  }},
                  decoration: InputDecoration(icon: Icon(Icons.enhanced_encryption,color: Colors.white,),fillColor: Colors.white,filled: true,
                  hintText: "Confirm Password",border:OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10)),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  controller: _nameController,
                  focusNode: nameFocusNode,
                  decoration: InputDecoration(icon: Icon(Icons.person,color: Colors.white,),fillColor: Colors.white,filled: true,hintText: 
                  "First name Last name",border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10)),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  focusNode: emailFocusNode,
                  onEditingComplete: (){
                    dio.post(url+'/confirm/email',data:_emailController.text).then((val){
                      if(val.toString()== 'Already existed'){
                        setState((){
                        errorOpacity=1.0;error = 'Email already exist change the email';_emailController.text='';
                      });}else{setState((){
                        errorOpacity=0;error = '';
                      });}
                    }).catchError((err)=>setState((){errorOpacity=0;error='An error occurred';errorOpacity=1;}));
                  },
                  decoration: InputDecoration(icon: Icon(Icons.person,color: Colors.white,),fillColor: Colors.white,filled: true,hintText: 
                  "Email",border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10)),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  focusNode: phoneFocusNode,
                  decoration: InputDecoration(icon: Icon(Icons.phone,color: Colors.white,),fillColor: Colors.white,filled: true,hintText: 
                  "Phone",border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10)),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: Center(
                    child: DropdownButton(items: ["Male",'Female'].map<DropdownMenuItem<String>>((String item){
                    return DropdownMenuItem<String>(value: item,child: Text(item),);
                  }).toList(),onChanged: (value)=>_genderController = value,hint: Text('Gender'),),
                ),
              ),
              Center(
                  child: RaisedButton(child: Text('Date of birth'),color: Colors.white,onPressed: (){
                  DatePicker.showDatePicker(context,maxTime: DateTime(DateTime.now().year - 13),onConfirm: (date){
                    _dobController='${date.year}-${date.month}-${date.day}';});
                },),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  keyboardType: TextInputType.url,
                  controller: _facebookController,
                  decoration: InputDecoration(icon: Icon(Icons.person,color: Colors.white,),fillColor: Colors.white,filled: true,hintText: 
                  "Facebook profile url(Optional)",border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10)),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  keyboardType: TextInputType.url,
                  controller: _instagramController,
                  decoration: InputDecoration(icon: Icon(Icons.person,color: Colors.white,),fillColor: Colors.white,filled: true,hintText: 
                  "Instagram profile url(Optional)",border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10)),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  keyboardType: TextInputType.url,
                  controller: _twitterController,
                  decoration: InputDecoration(icon: Icon(Icons.person,color: Colors.white,),fillColor: Colors.white,filled: true,hintText: 
                  "Twitter profile url(Optional)",border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10)),
                ),
              ),
              Opacity(opacity: errorOpacity,child: Center(child: Text('Sorry an Error Occurred try again'),)),
              Container(child: RaisedButton(padding: EdgeInsets.all(5),color: Colors.white,child: Text('Sign',style: TextStyle(color: Colors.blueAccent,fontSize: 20),),onPressed: (){
                bool confirm = true;
                for(var field in <TextEditingController>[_usernameController,_passwordController,_emailController,_phoneController,_nameController]){
                  if(field.text.isEmpty){
                    confirm = false; 
                  }
                }
                for(var field in [_dobController,_genderController]){
                  if(field!= null&&field.isEmpty){
                    confirm = false;
                  }
                }
                if(_passwordController.text.length <8){
                    confirm = false;
                    passwordFocusNode.requestFocus();
                    setState(() {
                      errorOpacity=1;error='Passwords must not be less than 8 characters';
                    });  
                    scrollController.position.animateTo(10,duration: Duration(seconds: 1),curve: Curves.bounceOut);
                } 
                if(confirm){
                dio.post(url+'/signup',data: {'username':_usernameController.text,'password':_passwordController.text,'dob':_dobController,'facebook':_facebookController.text,'twitter':
                _twitterController.text,'instagram':_instagramController.text,'name':_nameController.text,'email':_emailController.text,'gender':_genderController}).then((res)async{
                  if(res.toString().contains(',')){
                    List parseData=res.toString().split(',');
                    await storage.write(key: 'id',value: parseData[0]);
                    await storage.write(key: 'username',value: parseData[1]);
                    await storage.write(key: 'profilepic',value: parseData[2]);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));}
                  else if(res.toString()!= 'usernameExist'){
                    userFocusNode.requestFocus();
                    setState(() {
                      errorOpacity=1;error='Username Already exists';
                    });  
                    scrollController.position.animateTo(10,duration: Duration(seconds: 1),curve: Curves.bounceOut);
                  }
                }).catchError((err){
                  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Sorry an Error Occurred try again',style: TextStyle(color: Colors.white,fontSize: 22),),
                    backgroundColor: Colors.redAccent,),);
                    setState(() {
                      error='Sorry an Error Occurred try again';errorOpacity=1;
                    });
                });
                }else{
                  setState(() {
                    errorOpacity=1;error='All fields must fields filled';
                  });
                  scrollController.position.animateTo(10,duration: Duration(seconds: 1),curve: Curves.bounceOut);
                }
              }))
            ],
          ),
          ),
        ),
      ),
    );
  }
}