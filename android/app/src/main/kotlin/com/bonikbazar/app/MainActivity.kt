package com.bonikbazar.app


import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
}



//import android.os.Bundle
//import io.flutter.embedding.android.FlutterFragmentActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
//import io.flutter.plugins.GeneratedPluginRegistrant
//import io.flutter.view.FlutterMain
////import android.os.Build;
//import android.view.WindowManager
//
//
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.android.FlutterFragmentActivity
//import com.google.android.gms.maps.MapsInitializer;
//import com.google.android.gms.maps.MapsInitializer.Renderer
//import com.google.android.gms.maps.OnMapsSdkInitializedCallback
//import android.util.Log;

/*
class MainActivity: FlutterFragmentActivity(), OnMapsSdkInitializedCallback{
//    override
//    fun onCreate(savedInstanceState: Bundle?){
//        super.onCreate(savedInstanceState);
//        MapsInitializer.initialize(applicationContext, Renderer.LATEST, this)
//    }
override fun onMapsSdkInitialized(renderer: MapsInitializer.Renderer) {
when (renderer) {
Renderer.LATEST -> Log.d("NewRendererLog", "The latest version of the renderer is used.")
Renderer.LEGACY -> Log.d("NewRendererLog","The legacy version of the renderer is used.")
}
}
}
class MainActivity: FlutterActivity() {
}
*/

//class MainActivity:  FlutterFragmentActivity(), OnMapsSdkInitializedCallback{
//    override
//    fun onCreate(savedInstanceState: Bundle?){
//        super.onCreate(savedInstanceState);
//        MapsInitializer.initialize(applicationContext, Renderer.LATEST, this)
//    }
//
//    override fun onMapsSdkInitialized(renderer: MapsInitializer.Renderer) {
//        when (renderer) {
//            Renderer.LATEST -> {
//                // Do something for the latest version of the renderer
//            }
//            Renderer.LEGACY -> {
//                // Do something for the legacy version of the renderer
//            }
//        }
//    }
//}