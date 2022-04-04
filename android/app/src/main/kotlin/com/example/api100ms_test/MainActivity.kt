package com.example.api100ms_test

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import live.hms.hmssdk_flutter.Constants
import live.hms.hmssdk_flutter.HmssdkFlutterPlugin

class MainActivity : FlutterActivity() {

    // ****************************************** VARS ***************************************** //

    private lateinit var mediaProjectionManager: MediaProjectionManager

    // *************************************** LIFECYCLE *************************************** //

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mediaProjectionManager = activity?.getSystemService(Context.MEDIA_PROJECTION_SERVICE) as
                MediaProjectionManager
    }

    // ************************************* PUBLIC METHODS ************************************ //

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == Constants.SCREEN_SHARE_INTENT_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            HmssdkFlutterPlugin.hmssdkFlutterPlugin?.requestScreenShare(data)
        }
    }

}
