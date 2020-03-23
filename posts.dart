import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/rendering.dart';
import 'classes.dart';
import 'main.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
class PostPage extends StatefulWidget{
  PostPage({Key key,this.dio, this.name, this.description, this.date, this.pic, this.pic1, this.pic2, this.creator,
  this.location, this.profilepic,this.price,this.currency,this.tags,this.id,this.rest, this.reviewers,this.reviews}):super(key:key);
  final name,description,date,pic,pic1,pic2,creator,location,profilepic,price,currency,tags,id,rest,reviewers,reviews;
  final Dio dio;  
  @override
  PostPageState createState()=> PostPageState();
}
class CommentsPage extends StatefulWidget{
  CommentsPage({Key key,this.id,this.dio}):super(key:key);
  final id;
  final Dio dio;
  CommentsPageState createState()=>CommentsPageState(); 
}
class PostDetailsPage extends StatefulWidget{
  PostDetailsPage({Key key,this.dio}):super(key:key);
  final Dio dio;
  PostDetailsPageState createState() => PostDetailsPageState();
}
class CreatePostPage extends StatefulWidget{
  CreatePostPage({Key key,this.name, this.dio,this.delivery,this.description, this.tags, this.currency, this.estimate, this.items, this.location, this.price}):
  super(key:key);
  final Dio dio;
  final String name,description,currency, tags, delivery, location, estimate, items,price;
  CreatePostPageState createState()=>CreatePostPageState();
}

class PostPageState extends State<PostPage>{
  final textcontroller = TextEditingController();double errOpacity = 0;
  
  double sendOpacity = 0;String err=''; TextStyle errStyle = TextStyle(color: Colors.redAccent,fontSize: 18);
  items(data){
    var children = <Widget> [];
    if(data!=null){
      if(data.runtimeType.toString()== "List<dynamic>"){
        for(var i= 0;i < data.length;i++){
          children.add(Text(data[i],style: TextStyle(fontSize: 20),)); 
        }
        return children;
      }else if(data.runtimeType.toString()== '_InternalLinkedHashMap<String, dynamic>'){
        var casted =Map.castFrom(widget.reviews);
        iterIcons(num,reviewers){
          var retIcons = <Widget>[];
          for(int i= 0; i<num;i++){
            retIcons.add(Icon(Icons.star,size:30,color:Colors.yellow),);
          }
          retIcons.add(Text(' ${reviewers.length}',style: TextStyle(color: Colors.blueAccent,fontSize: 30),));
          return retIcons;
        }
        casted.forEach((rating,reviewers){
            if(rating == 'one'){children.add(Row(children:iterIcons(1, reviewers)));}else if(rating == 'two'){children.add(Row(children:iterIcons(2, reviewers)));}
            else if(rating == 'three'){children.add(Row(children:iterIcons(3, reviewers)));}if(rating == 'four'){children.add(Row(children:iterIcons(4, reviewers)));}
            else if(rating == 'five'){children.add(Row(children:iterIcons(5, reviewers)));}
        });
        return children;
      }else if(data.runtimeType.toString() == 'String'){
        var parsedTags = data.split(',');
        for (var i = 0; i < parsedTags.length; i++) { 
          children.add(RaisedButton(child: Text(parsedTags[i],style: TextStyle(fontSize: 20,color: Colors.blueAccent),),onPressed: (){
          },color: Colors.white,)); 
        }
        return children;
      }
    }else{
      return children;
    }
  }
  @override
  Widget build(BuildContext context){
    
    return SafeArea(
        child: Container(
            height: MediaQuery.of(context).size.height-170,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: 1,
              itemBuilder: (BuildContext context, index){
                List<Widget> images(list){
                  List returned = <Widget>[];
                  for(var i in list){
                    returned.add(
                      Image.network(i)
                    );
                  }
                  return returned;
                }
                return Column(
                  children: <Widget>[
                    Container(child: GestureDetector(child: Icon(Icons.close,color: Colors.white,),onTap: ()=>Scaffold.of(context).hideCurrentSnackBar(),),
                      width: 40,padding: EdgeInsets.only(right: 1 ),decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Colors.blueAccent),),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white,),
                      child: Row(
                        children: <Widget>[
                      Container(height: 65,width: 65,decoration: BoxDecoration(borderRadius: BorderRadius.circular(200),image: DecorationImage(image: 
                          NetworkImage(url.substring(0,url.lastIndexOf('/'))+widget.profilepic,)),),
                      ),                      
                      Text(widget.creator,style: TextStyle(color: Colors.grey,fontSize: 30),),
                      ],),),
                      Container(
                        margin: EdgeInsets.only(left: 10,top: 10),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(color: Colors.white,),
                        child:
                          Text(widget.name,style: TextStyle(color: Colors.grey,fontSize: 25)),
                      ),
                      Container(
                        child: SizedBox(height: 500,width: MediaQuery.of(context).size.width,
                          child: Carousel(images: 
                            images([url.substring(0,url.lastIndexOf('/'))+widget.pic,url.substring(0,url.lastIndexOf('/'))+widget.pic1,url.substring(0,url.lastIndexOf('/'))+widget.pic2]),
                            dotSize: 6,dotBgColor: Colors.white,dotColor: Colors.blueAccent,dotIncreasedColor: Colors.blue,dotHorizontalPadding: 0,autoplay: false,dotVerticalPadding: 0,
                            ), 
                        ),
                      ),
                      Container(
                        child: Column(
                          children: <Widget>[
                            Container(child: Text(widget.description,style: TextStyle(color: Colors.grey,fontSize: 20)),width: MediaQuery.of(context).size.width,padding: EdgeInsets.all(5),
                            constraints: BoxConstraints(maxHeight: 50),decoration: BoxDecoration(color: Colors.white)),
                            Container(child: Text(widget.date ,style: TextStyle(color: Colors.grey,fontSize: 17)),
                            width: MediaQuery.of(context).size.width,color: Colors.white,padding: EdgeInsets.all(5),),
                            Container(child: Text(widget.currency +' '+ widget.price.toString(),style: TextStyle(color: Colors.grey,fontSize: 17)),
                            width: MediaQuery.of(context).size.width,color: Colors.white,padding: EdgeInsets.all(5),),
                            Container(child: Text(widget.location,style: TextStyle(color: Colors.grey,fontSize: 17)),
                            width: MediaQuery.of(context).size.width,color: Colors.white,padding: EdgeInsets.all(5),)
                          ],
                        ),
                      ),
                      Opacity(opacity: errOpacity,child: Text(err,style: errStyle,)),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(color: Colors.white),
                        child: TextField(
                          maxLength: null,
                          controller: textcontroller,
                          onChanged: (val){if(val.length>0){setState(()=>sendOpacity=1.0);}else{setState(() {sendOpacity=0;});}},
                          autocorrect: true,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(color: Colors.blueAccent,fontSize: 20),
                          decoration: InputDecoration(contentPadding: EdgeInsets.only(top:15,left: 5),suffix:Opacity(opacity: sendOpacity,child: FlatButton(child: Icon(Icons.send,color: Colors.blueAccent,),onPressed: (){
                            setState((){err='Sending comment';errStyle=TextStyle(color: Colors.grey,fontSize: 18);});
                            widget.dio.post(url+'/comment',data: {'comment':textcontroller.text,'type':'post','username':'seth','creator':widget.creator,'dp':'profilepic','post':widget.id})
                            .then((val){setState((){sendOpacity=0;textcontroller.text='';});}).catchError((err){
                              setState((){err= 'Error while commenting. Try again';errOpacity=1;sendOpacity=1;errStyle=TextStyle(color: Colors.redAccent,fontSize: 18);});
                            });
                          },)), 
                          hintStyle: TextStyle(fontSize: 19,color: Colors.blueAccent),hintText: 'Comment',prefix: Icon(Icons.comment,color: Colors.blueAccent),)
                        ),
                      ),
                      Container(child: ListView(children: items(widget.tags),padding: EdgeInsets.all(1),shrinkWrap: true,scrollDirection: Axis.horizontal,),margin: EdgeInsets.only(top: 10,bottom: 10),constraints: 
                      BoxConstraints(maxHeight:50)),
                      Container(
                        margin: EdgeInsets.all(5),
                        width: MediaQuery.of(context).size.width - 50,
                        child: RaisedButton(child: Text('Show reviews',style: TextStyle(color: Colors.blueAccent,fontSize: 20),),onPressed: (){
                          Scaffold.of(context).hideCurrentSnackBar();
                          Scaffold.of(context).showSnackBar(SnackBar(duration: Duration(hours: 1),
                          content: Container(child: Column(children: items(widget.reviews),),constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height-150),
                          height: MediaQuery.of(context).size.height - 180,),
                          backgroundColor: Colors.white,));},color: Colors.white,)
                      ),
                      RaisedButton(child: Text('Show Comments'),color: Colors.blueAccent,onPressed: (){
                        Scaffold.of(context).hideCurrentSnackBar();
                        Scaffold.of(context).showSnackBar(SnackBar(content:Container(child: CommentsPage(id:widget.id),height: MediaQuery.of(context).size.height - 180,),
                        duration: Duration(days: 1),backgroundColor: Colors.white,));
                      },)
                  ],
                );
              } ,          
            ),
          ),
        );
  }
}
class PostDetailsPageState extends State<PostDetailsPage>{
  Widget build(BuildContext context){
    return FutureBuilder(
      future: Dio(BaseOptions(headers: {'clienttype':'App'})).get(url),
      builder: (BuildContext context,snapshot){
        if(snapshot.hasData){
          var parseData =snapshot.data.toString().substring(1,snapshot.data.toString().length - 1).split('},{');          
          dynamic posts(index){
            Map postMap;
                if(parseData[index][0]=='{'){
                  postMap = jsonDecode(parseData[index]+'}');
                }else if(parseData[index][parseData[index].length-1]!= '}'){
                  postMap= jsonDecode('{'+parseData[index]+'}');
                }
                
            dynamic posts = new Posts.fromJson(postMap);
            return posts;
          }
          return Container(width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, index){
              List<Widget>images(list,index){
                List returnedImages = <Widget>[];
                  for(var i in list){
                  returnedImages.add(FlatButton(child: Image.network(url.substring(0,url.lastIndexOf('/'))+i),onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder:(context)=>PostPage(name: posts(index).name,description: posts(index).description,
                        date: '${posts(index).datePosted} ${posts(index).timePosted}',pic: posts(index).pic,pic1: posts(index).pic1,
                        pic2: posts(index).pic2,creator: posts(index).creator,location: posts(index).location,profilepic: posts(index).profilepic,
                        tags: posts(index).tags,price: posts(index).price,currency: posts(index).currency,id: posts(index).id,reviews:posts(index).reviews,
                        reviewers:posts(index).reviewers)));
                      }),);
                  }
                  return returnedImages;
                }
                  return Column(
                  children: <Widget>[
                    Container(child: GestureDetector(child: Icon(Icons.close,color: Colors.white,),onTap: ()=>Scaffold.of(context).hideCurrentSnackBar(),),
                    width: 40,padding: EdgeInsets.only(right: 1 ),decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Colors.blueAccent),),
                    Container(width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white,),
                      child: Row(
                        children: <Widget>[
                        Container(height: 65,width: 65,decoration: BoxDecoration(borderRadius: BorderRadius.circular(200),image: DecorationImage(image: 
                        NetworkImage(url.substring(0,url.lastIndexOf('/'))+posts(index).profilepic,)),),
                         ),
                        Text(posts(index).creator,style: TextStyle(color: Colors.grey,fontSize: 30),),
                      ],),),
                      Container(
                        margin: EdgeInsets.only(left: 10,top: 10),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(color: Colors.white,),
                        child:
                          Text(posts(index).name,style: TextStyle(color: Colors.grey,fontSize: 25)),
                      ),
                      Container(width: MediaQuery.of(context).size.width,
                        child: SizedBox(height: 500,width: MediaQuery.of(context).size.width,
                          child: Carousel(images: 
                            images([posts(index).pic,posts(index).pic1,posts(index).pic2,],index),
                            dotSize: 6,dotBgColor: Colors.white,dotColor: Colors.blueAccent,dotIncreasedColor: Colors.blue,dotHorizontalPadding: 0,autoplay: false,dotVerticalPadding: 0,
                            ), 
                        ),
                      ),
                      Container(width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: <Widget>[
                            Container(child: Text(posts(index).description,style: TextStyle(color: Colors.grey,fontSize: 20)),width: MediaQuery.of(context).size.width,padding: EdgeInsets.all(5),
                            constraints: BoxConstraints(maxHeight: 50),decoration: BoxDecoration(boxShadow: [BoxShadow(color: Color.fromRGBO(230, 230, 230, 1),offset: Offset(-5,-5))],color: Colors.white)),
                            Container(child: Text(posts(index).datePosted +' '+ posts(index).timePosted,style: TextStyle(color: Colors.grey,fontSize: 17)),
                            width: MediaQuery.of(context).size.width,color: Colors.white,padding: EdgeInsets.all(5),),
                            Container(child: Text(posts(index).currency +' '+ posts(index).price.toString(),style: TextStyle(color: Colors.grey,fontSize: 17)),
                            width: MediaQuery.of(context).size.width,color: Colors.white,padding: EdgeInsets.all(5),),
                            Container(child: Text(posts(index).location,style: TextStyle(color: Colors.grey,fontSize: 17)),
                            width: MediaQuery.of(context).size.width,color: Colors.white,padding: EdgeInsets.all(5),)
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        }else if(snapshot.hasError){
          return Center(
            child: RaisedButton(
              child: Text('Sorry an error occurred. Click to try again', style: TextStyle(fontSize: 20,color: Colors.redAccent),),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));
              },
            ),
          );
        }else{
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
class CommentsPageState extends State<CommentsPage>{
  int lenght;
  TextStyle textStyle = TextStyle(color: Colors.black,fontSize: 19);
  Widget build(BuildContext context){
    return FutureBuilder(
      future: widget.dio.post(url+'/comment',data: {'post':widget.id}),
      builder: (context, snapshot){
        if(snapshot.hasData){
          dynamic comments(data,index){
            var parseData =snapshot.data.toString().substring(1,snapshot.data.toString().length - 1).split('},{');    
            Map commentsMap;
            if(parseData[index][0]=='{'){
              commentsMap = jsonDecode('{"_id":"5d334eea667181333b71d4a2","username":"seth","dp":"/media/profiles/IMG_20181010_132708_935.jpg","post":"5c755b28e4b8823303ffc681","dateCreated":"2019-7-20","timeCreated":"18:27:6","comment":"This is amazing","postcreator":"seth"}');
            }else if(parseData[index][parseData[index].length-1]!= '}'){
              commentsMap = jsonDecode('{'+parseData[index]+'}');
            }
              dynamic comments = new Comments.fromJson(commentsMap);
            return comments;
          }
          return ListView.builder(
            itemCount: 1,
            itemBuilder: (context,index){
              return Card(child: Container(width: MediaQuery.of(context).size.width,margin: EdgeInsets.all(5),
                child: Column(children: <Widget>[
                  Row(children: <Widget>[
                    Container(width:50,height: 50,decoration: BoxDecoration(borderRadius: BorderRadius.circular(200),image: DecorationImage(image: 
                      NetworkImage(url.substring(0,url.lastIndexOf('/'))+comments(snapshot.data.toString(), index).profilepic,))
                      )),
                      Container(child: Text(comments(snapshot.data.toString(),index).username,style: textStyle,),margin: EdgeInsets.only(left: 20),),
                  ],),
                    Container(child: Wrap(children: [Text(comments(snapshot.data.toString(),index).comment,style: textStyle,)]),margin: EdgeInsets.only(left: 0),),

                ],),
              ),color: Colors.white,);
              // return Text(comments(snapshot.data.toString(),index).comment,style: textStyle,);
            },
          );
        }else if(snapshot.hasError){
          return Center(child: Text('An Error occurred'),);
        }else{
          return Center(child: CircularProgressIndicator(),);
        }
      },
    );
  }
}
class CreatePostPageState extends State<CreatePostPage>{
  static String  _err='';static double errOpacity=0; 
  final _nameController =TextEditingController(),
        _descriptionController =TextEditingController(),
        _tagsController =TextEditingController(),
        _currencyController =TextEditingController(),
        _priceController =TextEditingController(),
        _itemsController =TextEditingController(text: ''),
        _deliveryController =TextEditingController(),
        _estimateController =TextEditingController(),
        _locationController =TextEditingController(),
        pageController = PageController();
  
  int index = 0;
  
  Widget build(BuildContext context){
    List<TextEditingController> controllers= <TextEditingController>[_nameController,_descriptionController,_tagsController,_currencyController,_priceController,_itemsController,_deliveryController,
    _estimateController,_locationController];
    List args = [widget.name,widget.description,widget.tags,widget.currency,widget.price,widget.items,widget.delivery,widget.estimate,widget.location];
    @override
    initState(){
      super.initState();
      for(int i = 0; i< controllers.length; i++){
        controllers[i].text=args[i];
      }
      
    }
    List<Widget> shopChildren = <Widget>[
        Center(child: RaisedButton(child: Icon(Icons.navigate_before,color: Colors.white,),onPressed: (){
          pageController.previousPage(duration: Duration(seconds: 1),curve: Curves.bounceOut);},color: Colors.blueAccent,)
        ),
        Container(margin: EdgeInsets.all(10),child: Center(child: Opacity(opacity: errOpacity,child: Text(_err,style: TextStyle(color: Colors.redAccent,fontSize: 19,fontWeight: FontWeight.w900),)))),
        Container(
          margin: EdgeInsets.all(10),
          child: TextFormField(controller: _itemsController,autofocus: true, 
            decoration: InputDecoration(fillColor: Colors.white,filled: true,hintText: "comma, seperated, items",
            border:OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10)),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: TextFormField(controller: _locationController, 
            decoration: InputDecoration(fillColor: Colors.white,hintText: "Location to buy items from",border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10)),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: TextFormField(controller: _deliveryController,decoration: InputDecoration(fillColor: Colors.white,filled: true,hintText:
           "Where to buy items from",border:OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10)),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: TextFormField(controller: _currencyController,decoration: InputDecoration(fillColor: Colors.white,filled: true,hintText: "Currency",
            border:OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10)), 
          ),
        ),

        Container(
          margin: EdgeInsets.all(10),
          child: TextFormField(controller: _priceController, keyboardType: TextInputType.number,
            decoration: InputDecoration(fillColor: Colors.white,filled: true,hintText: "Price. Price to pay shopper",
            border:OutlineInputBorder(borderRadius: BorderRadius.circular(20)),contentPadding: EdgeInsets.all(10),),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: TextFormField(controller: _estimateController,keyboardType: TextInputType.number,
            decoration: InputDecoration(fillColor: Colors.white,filled: true,hintText: "Total item price shouldn't exceed",
            border:OutlineInputBorder(borderRadius: BorderRadius.circular(20)),contentPadding: EdgeInsets.all(10),),
          ),
        ),
        Center(child: FlatButton(color: Colors.blueAccent,child: Text('Create Post',style: TextStyle(color: Colors.white),),onPressed: (){
          bool confirm = false;
          for(var i in [_itemsController,_locationController,_deliveryController,_currencyController,_priceController,_estimateController]){
            if(i.text.isEmpty){setState((){errOpacity=1;_err='All fields must be filled';});break;}
          }
          if(confirm){
            widget.dio.post(url+'/createshop',data: {'name':_nameController.text,'currency':_currencyController.text,'description':_descriptionController.text,'price':_priceController.text,'tags':_tagsController.text,'creator':'seth'})
            .then((val){if(val.toString()=='success'){
              Scaffold.of(context).showSnackBar(SnackBar(content:Text('Successfully posted',style: TextStyle(color: Colors.black54,fontSize: 19),),backgroundColor: 
              Colors.white,));}
              for(var i in [_itemsController,_locationController,_deliveryController,_currencyController,_priceController,_estimateController]){
                i.text = '';
              }
            }).catchError((err){Scaffold.of(context).showSnackBar(SnackBar(content:Text('Sorry an error occurred Try again',style:TextStyle(
              color: Colors.white
            )),backgroundColor: Colors.redAccent,));});
          }
        },),)
      ];
      List<Widget> postChildren = <Widget>[
        Center(child: RaisedButton(child: Icon(Icons.navigate_next,color: Colors.white,),onPressed: (){
          pageController.nextPage(duration: Duration(seconds: 1),curve: Curves.bounceOut);},color: Colors.blueAccent,)
        ),
        Container(margin: EdgeInsets.all(10),child: Center(child: Opacity(opacity: errOpacity,child: Text(_err,style: TextStyle(color: Colors.redAccent,fontSize: 19,fontWeight: FontWeight.w900),)))),
        Container(
          margin: EdgeInsets.all(10),
          child: TextFormField(controller: _nameController,
            autofocus: true,decoration: InputDecoration(fillColor: Colors.white,filled: true,hintText: "Name",border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10)),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: TextFormField(controller: _descriptionController,decoration: InputDecoration(fillColor: Colors.white,filled: true,hintText:
           "Description",border:OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10)),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: TextFormField(controller: _tagsController, 
            decoration: InputDecoration(fillColor: Colors.white,filled: true,hintText: "comma, seperated, tags",
            border:OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10)),
          ),
        ),

        Container(
          margin: EdgeInsets.all(10),
          child: TextFormField(controller: _currencyController,decoration: InputDecoration(fillColor: Colors.white,filled: true,hintText: "Currency",
            border:OutlineInputBorder(borderRadius: BorderRadius.circular(20),),contentPadding: EdgeInsets.all(10),),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: TextFormField(controller: _priceController,keyboardType: TextInputType.number,
            decoration: InputDecoration(fillColor: Colors.white,filled: true,hintText: "Price. Leave 0 if it's free",
            border:OutlineInputBorder(borderRadius: BorderRadius.circular(20)),contentPadding: EdgeInsets.all(10),),
          ),
        ),
        Center(child: FlatButton(color: Colors.blueAccent,child: Text('Create Post',style: TextStyle(color: Colors.white),),onPressed: (){
          bool confirm = false;
          for(var i in [_nameController,_descriptionController,_tagsController,_currencyController,_priceController]){
            if(i.text.isEmpty){setState((){errOpacity=1;_err='All fields must be filled';});break;}confirm = true;
          }
          if(confirm){
            widget.dio.post(url+'/createpost',data: {'name':_nameController.text,'currency':_currencyController.text,'description':_descriptionController.text,'price':_priceController.text,'tags':_tagsController.text,'creator':'seth'})
            .then((val){if(val.toString()=='success'){
              Scaffold.of(context).showSnackBar(SnackBar(content:Text('Successfully posted',style: TextStyle(color: Colors.black54,fontSize: 19),),backgroundColor: 
              Colors.blueAccent,));}
              for(var i in [_nameController,_descriptionController,_tagsController,_currencyController,_priceController]){
                i.text= '';
              }
            });
          }
        },),)
      ];
    return Container(color: Colors.white,
      child:PageView(controller: pageController,children:[ListView(children: postChildren),ListView(children:shopChildren),])
    );
  }
}
