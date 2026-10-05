package com.hardwarescan.desktop

import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application
import androidx.compose.ui.window.rememberWindowState
import com.hardwarescan.desktop.data.HardwareScanner
import com.hardwarescan.desktop.theme.HardwareScanTheme
import com.hardwarescan.desktop.ui.HardwareScanApp

fun main() = application {
    val windowState = rememberWindowState(width = 1100.dp, height = 750.dp)
    val scanner = HardwareScanner()

    Window(
        onCloseRequest = ::exitApplication,
        state = windowState,
        title = "Hardware Scan - PC Diagnostics"
    ) {
        HardwareScanTheme {
            HardwareScanApp(scanner = scanner)
        }
    }
}
