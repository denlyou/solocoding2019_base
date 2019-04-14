import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:async';

void main() => runApp(MyApp());

// This widget is the root of your application.
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MyAppState();
}

class MyAppState extends State<MyApp> {
	bool _isInitData = false; // 초기 데이터(위치 가져오기) 완료 여부
	bool _isError = false; // 오류 발생 여부
	String _errorMessage = ""; // 에러시 메세지
	LocationData _nowLocationData; // 현재 위치를 가져 올 변수

	@override
	void initState() {
		// 현재 위치 구하기 (async)
		_getLocation().then( (LocationData nowLocationData) {
			setState(() {
				_isInitData = true;
				_nowLocationData = nowLocationData;
			});
		}).catchError((err) {
			setState(() {
				_isInitData = true;
			});
		});
		super.initState();
	}

	@override
	Widget build(BuildContext context) { print("MyAppState.build()");
		return MaterialApp(
			title: "🌞☔⚡🌈",
			theme: ThemeData(
				primarySwatch: Colors.amber,
			),
			home: Scaffold(
				appBar: AppBar(
					title: Text("🌞☔⚡🌈"), // app bar title
				),
				body: _buildBody()
				
			),
		);
	}

	/// 내용을 만듭니다.
	Widget _buildBody(){
		// 데이터 초기화가 안됬으면...
		if(_isInitData == false) return _buildBodyLoading();

		// 현재 좌표 구하기
		final lat = _nowLocationData.latitude;
		final long = _nowLocationData.longitude;

		return !_isInitData ? _buildBodyLoading() : Center(
			child: Text("lat:$lat \nlong:$long  "), // center text
		);
	}

	///
	Widget _buildBodyLoading(){
		return Center(
			child: Text("현재 위치를 가져오는 중입니다.")
		);
	}
	

	/// 현재 위치를 가져오는 메소드
	Future<LocationData> _getLocation() async {
		LocationData currentLocation;
		final location = new Location();

		try {
			currentLocation = await location.getLocation();
		} catch (e) {
			if (e.code == "PERMISSION_DENIED") {
				setState(() {
					_isError = true;
					_errorMessage = "위치 정보를 가져올 권한이 없습니다.";
				});
			} 
			currentLocation = null;		
		}
		return currentLocation;
	}
}
