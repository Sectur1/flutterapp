class Posts{
  final name,datePosted,timePosted,creator,profilepic, location,description,pic,pic1,pic2,type,price,currency,tags,id,
  reviewers,reviews;
  Posts({this.name, this.datePosted, this.timePosted, this.creator, this.profilepic, this.location, this.description, this.id,
  this.pic, this.pic1, this.pic2, this.type, this.price, this.currency,this.tags, this.reviewers, this.reviews});
  Posts.fromJson(Map <dynamic, dynamic> json):
  name = json['name'],datePosted = json['datePosted'], timePosted = json['timePosted'], creator = json['creator'],
  profilepic = json['profilepic'],location = json['location'], description = json['description'],pic = json['pic'],
  pic1 = json['pic1'], pic2 = json['pic2'],type = json['type'],price = json['price'], currency = json['currency'],tags = json['tags'],
  reviewers = json['reviewers'],reviews = json['reviews'],id=json['_id'];
}
class Shops{
  final String id, creator, location, items, delivery, estimate, dp, phone, price, currency, dateCreated, timeCreated,pic,approved;
  final List interested;
  Shops({this.id, this.creator,this.location,this.items,this.delivery,this.estimate,this.dp, this.phone,this.price,this.pic, this.currency,
  this.dateCreated,this.timeCreated,this.approved,this.interested});
  Shops.fromJson(Map<dynamic,dynamic> json): 
  id = json['_id'],creator=json['creator'],location=json['location'],items=json['items'],delivery=json['delivery'],estimate=json['estimate'],
  dp=json['dp'],phone=json['phone'],price=json['price'],currency=json['currency'],dateCreated=json['dateCreated'],timeCreated=json['timeCreated'],
  pic=json['pic'],approved=json['approved'],interested=json['interested'];
}
class PostMap{
  final data,name;
  PostMap(this.data,this.name);
  PostMap.fromJson(Map<dynamic,dynamic>json):data=json['data'],name=json['name'];
  // PostMap _postsJson(Map <String,dynamic>json)=>
}

class Comments{
  final String username,profilepic, post, datePosted, timePosted, comment;
  Comments({this.username, this.post, this.datePosted, this.timePosted, this.comment, this.profilepic,});
  Comments.fromJson(Map<dynamic, dynamic>json):
  username = json['username'], post = json['post'], datePosted = json['datePosted'], timePosted = json['timePosted'],comment =json['comment'],
  profilepic=json['dp']; 
}
class NetworkNotification{
  final String creator, post, type, dateCreated, timeCreated, shop;
  NetworkNotification({this.creator,this.dateCreated, this.post, this.shop, this.timeCreated, this.type});
  NetworkNotification.fromJson(Map<dynamic,dynamic>json):creator = json['creator'],post=json['post'],type=json['type'],
  dateCreated=json['dateCreated'],shop=json['shop'],timeCreated=json['timeCreated'];
}