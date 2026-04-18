package com.feathermoments.votera

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // Called when the app is already running (singleTop) and a new deep-link
    // intent arrives. FlutterActivity handles the cold-start case automatically.
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        val data: Uri? = intent.data
        if (data != null) {
            val inviteCode = data.lastPathSegment
            if (!inviteCode.isNullOrBlank()) {
                // Forward the full URI to the app_links plugin so the Flutter
                // uriLinkStream fires and the Dart handler can navigate.
                setIntent(intent)
            }
        }
    }
}
