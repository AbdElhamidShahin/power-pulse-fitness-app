package com.yourcompanyname.yourappname
import android.os.Bundle  // 👈 لازم تضيف السطر ده

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // تفعيل Edge-to-Edge
        window.setDecorFitsSystemWindows(false)
    }
}