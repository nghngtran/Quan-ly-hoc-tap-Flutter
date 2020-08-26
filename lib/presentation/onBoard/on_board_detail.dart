import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scheduleapp/application/color_app.dart';

class OnBoardDetail {
  String imgUrl;
  String title;
  String des;
  Widget loginFB;
  Widget loginGG;
  Widget continueBtn;
  bool skipOnboard;
  OnBoardDetail({@required String img, @required String title, @required String des,
    @required Widget loginFacebook, @required Widget loginGoogle, @required Widget continueBtn, @required bool skip}):
        imgUrl = img,
        title = title,
        des = des,
        loginFB = loginFacebook,
        loginGG = loginGoogle,
        continueBtn = continueBtn,
        skipOnboard = skip;
}

class OnBoardInfo extends StatelessWidget {
  OnBoardDetail item;
  OnBoardInfo(OnBoardDetail _item) : item = _item;
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width / 100;
    double h = MediaQuery.of(context).size.height / 100;
    return Container(margin: EdgeInsets.fromLTRB(0, h*15, w*3, h*6),
        padding: EdgeInsets.fromLTRB(w*4, 0, w*2, 0),
        width: w*100,height: h*100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              item.imgUrl,
              fit: BoxFit.cover,
              width: w * 100,
              height: h * 42,
            ),
            SizedBox(height: h*3),
            item.title != ""  ? Expanded(
              child: Container(margin: EdgeInsets.fromLTRB(w*2, h*3, w*2, 0),child: Text(item.title,
                  style: TextStyle(fontSize: 36, color: ColorApp.backgroundColor,fontWeight: FontWeight.w600))),
            ) : LoginGoogle(),
            Expanded(child:Container(margin: EdgeInsets.fromLTRB(w*2, h, w*2, 0),child:Text(item.des, style: TextStyle(fontSize: 18, color: Colors.black.withOpacity(0.7), fontWeight: FontWeight.w400)))),
            SizedBox(height: h * 4),
            Align(alignment: Alignment.bottomRight,child: InkWell(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('login_screen');
                },
                child: item.skipOnboard ? Text("Bỏ qua",
                    style: TextStyle(fontSize: 16, color: Colors.grey)): Container()))

          ],
        ));
  }
}
class LoginGoogle extends StatefulWidget
{
  LoginGoogleState createState() => LoginGoogleState();
}
class LoginGoogleState extends State<LoginGoogle> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isUserSignedIn = false;

  @override
  void initState() {
    super.initState();

    checkIfUserIsSignedIn();
  }
  void checkIfUserIsSignedIn() async {
    var userSignedIn = await _googleSignIn.isSignedIn();

    setState(() {
      isUserSignedIn = userSignedIn;
    });
  }

  Future<FirebaseUser> _handleSignIn() async {
    FirebaseUser user;
    bool userSignedIn = await _googleSignIn.isSignedIn();

    setState(() {
      isUserSignedIn = userSignedIn;
    });

    if (isUserSignedIn) {
      user = await _auth.currentUser();
    }
    else {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      user = (await _auth.signInWithCredential(credential)).user;
      userSignedIn = await _googleSignIn.isSignedIn();
      setState(() {
        isUserSignedIn = userSignedIn;
      });
    }

    return user;
  }
  void onGoogleSignIn(BuildContext context) async {
    FirebaseUser user = await _handleSignIn();
    var userSignedIn = await Navigator.of(context).pushNamed('personal_information');


    setState(() {
      isUserSignedIn = userSignedIn == null ? true : false;
    });
  }
  Widget build(BuildContext context) {
    double w = MediaQuery
        .of(context)
        .size
        .width / 100;
    double h = MediaQuery
        .of(context)
        .size
        .height / 100;
    return GestureDetector(
      onTap: () async {
        onGoogleSignIn(context);
      },
      child: Container(width: w * 75,
        height: h * 8,
        decoration: BoxDecoration(shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            color: ColorApp.Blue),
        padding: EdgeInsets.fromLTRB(w * 2, h, w * 8, h),
        child: Row(mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: w * 3),
            SizedBox(width: w * 8,
                height: w * 8,
                child: CircleAvatar(backgroundColor: Colors.white,
                    child: Image.asset(
                        "assets/gg_logo.png", width: h * 3, height: h * 3))),
            SizedBox(width: w * 3),
            Expanded(
              child: Text("Đăng nhập bằng Google", style: TextStyle(
                  fontSize: 18, color: Colors.white
              )),
            )
          ],
        ),),
    );
  }
}
