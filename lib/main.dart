import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Firebase phone auth test';

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body: const MyCustomForm(),
      ),
    );
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String phoneNumber = '';
  String receivedID = '';
  bool flag = false;
// =================================== logical code ====================================
  // just a SnackBar
  void alert({required String massage}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(massage)),
    );
  }

  void verifyUserPhoneNumber() {
    auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value) {
          debugPrint('Logged In Successfully');
          alert(massage: 'Successful 1');
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint("Error :>> ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        receivedID = verificationId;
        flag = true;
        setState(() {});
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint('TimeOut');
      },
    );
  }

/* Verify OTP Code */

  Future<void> verifyOTPCode(String otp) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: receivedID,
      smsCode: otp,
    );
    await auth.signInWithCredential(credential).then((value) {
      debugPrint('User Login In Successful');
      alert(massage: 'Successful 2');
    });
  }

// =================================== logical code end ====================================

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter number';
              } else {
                phoneNumber = value;
                return null;
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                debugPrint(phoneNumber);
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  if (flag) {
                    verifyOTPCode(phoneNumber);
                  } else {
                    verifyUserPhoneNumber();
                  }
                  // fo
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
