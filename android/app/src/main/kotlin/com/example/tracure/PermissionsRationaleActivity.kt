package com.tracure.main

import android.app.Activity
import android.os.Bundle
import android.widget.TextView

class PermissionsRationaleActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val explanation = TextView(this)
        explanation.text = "This app uses your step and sleep data to help you track your health. No data is shared externally."
        explanation.textSize = 16f
        explanation.setPadding(32, 64, 32, 32)

        setContentView(explanation)
    }
}
