package com.platonicdating.giggles

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.window.OnBackInvokedDispatcher
import android.window.OnBackInvokedCallback
import android.os.Build
import androidx.annotation.NonNull

class MainActivity: FlutterActivity() {
    private var backCallback: OnBackInvokedCallback? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        if (Build.VERSION.SDK_INT >= 33) {
            backCallback = OnBackInvokedCallback {
                // Handle back press
                moveTaskToBack(true)
            }
            onBackInvokedDispatcher.registerOnBackInvokedCallback(
                OnBackInvokedDispatcher.PRIORITY_DEFAULT,
                backCallback!!
            )
        }
    }

    override fun onDestroy() {
        if (Build.VERSION.SDK_INT >= 33) {
            backCallback?.let {
                onBackInvokedDispatcher.unregisterOnBackInvokedCallback(it)
            }
        }
        super.onDestroy()
    }
}
