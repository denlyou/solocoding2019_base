import "package:flutter/material.dart";
import "package:solocoding2019_base/views/intro.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: "🌈",
			home:  IntroPage(),
		);
	}
}
