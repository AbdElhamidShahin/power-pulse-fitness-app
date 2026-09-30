package com.powerteam.powerpulse

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // تفعيل Edge-to-Edge
        window.setDecorFitsSystemWindows(false)
    }
}
