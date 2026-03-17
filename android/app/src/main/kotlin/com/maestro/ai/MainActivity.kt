package com.maestro.ai

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.maestro.ai.services.SystemCommandExecutor
import com.maestro.ai.services.MaestroAccessibilityService

class MainActivity : FlutterActivity() {
    private val CHANNEL = "maestro_ai/native"
    private lateinit var commandExecutor: SystemCommandExecutor
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        commandExecutor = SystemCommandExecutor(this)
    }
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                handleMethodCall(call, result)
            }
    }
    
    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val command = call.method
        val arguments = call.arguments as? Map<String, Any> ?: emptyMap()
        
        try {
            when (command) {
                // System Commands
                "executeCommand" -> {
                    val cmd = arguments["command"] as? String ?: ""
                    val params = arguments["params"] as? Map<String, Any> ?: emptyMap()
                    val executionResult = commandExecutor.executeCommand(cmd, params)
                    result.success(executionResult)
                }
                
                // Accessibility
                "getScreenText" -> {
                    val text = MaestroAccessibilityService.instance?.getCurrentScreenText() ?: ""
                    result.success(text)
                }
                
                "performClick" -> {
                    val targetText = arguments["text"] as? String ?: ""
                    val success = MaestroAccessibilityService.instance?.performClickOnText(targetText) ?: false
                    result.success(success)
                }
                
                "isAccessibilityEnabled" -> {
                    result.success(MaestroAccessibilityService.isServiceEnabled)
                }
                
                // Permissions
                "checkPermissions" -> {
                    val permissions = checkPermissions()
                    result.success(permissions)
                }
                
                "requestPermission" -> {
                    val permissionType = arguments["type"] as? String ?: ""
                    requestPermission(permissionType, result)
                }
                
                // Special intents
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                
                "openNotificationSettings" -> {
                    val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                            putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                        }
                    } else {
                        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.parse("package:$packageName")
                        }
                    }
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                
                "openBatteryOptimizationSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                
                "ignoreBatteryOptimizations" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val packageName = packageName
                        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
                        if (!powerManager.isIgnoringBatteryOptimizations(packageName)) {
                            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                            intent.data = Uri.parse("package:$packageName")
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                        }
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                
                "openAppSettings" -> {
                    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                    intent.data = Uri.parse("package:$packageName")
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                
                "openWifiSettings" -> {
                    val intent = Intent(Settings.ACTION_WIFI_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                
                "openBluetoothSettings" -> {
                    val intent = Intent(Settings.ACTION_BLUETOOTH_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                
                "openLocationSettings" -> {
                    val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                
                "openDisplaySettings" -> {
                    val intent = Intent(Settings.ACTION_DISPLAY_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                
                "openSoundSettings" -> {
                    val intent = Intent(Settings.ACTION_SOUND_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                
                // Device Info
                "getDeviceInfo" -> {
                    val deviceInfo = commandExecutor.executeCommand("DEVICE_INFO", emptyMap())
                    result.success(deviceInfo)
                }
                
                "getBatteryStatus" -> {
                    val batteryStatus = commandExecutor.executeCommand("BATTERY_STATUS", emptyMap())
                    result.success(batteryStatus)
                }
                
                "getStorageInfo" -> {
                    val storageInfo = commandExecutor.executeCommand("STORAGE_INFO", emptyMap())
                    result.success(storageInfo)
                }
                
                "getMemoryInfo" -> {
                    val memoryInfo = commandExecutor.executeCommand("MEMORY_INFO", emptyMap())
                    result.success(memoryInfo)
                }
                
                // Installed Apps
                "getInstalledApps" -> {
                    val apps = commandExecutor.executeCommand("GET_APPS", emptyMap())
                    result.success(apps)
                }
                
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("EXECUTION_ERROR", e.message, null)
        }
    }
    
    private fun checkPermissions(): Map<String, Boolean> {
        return mapOf(
            "recordAudio" to checkPermission(android.Manifest.permission.RECORD_AUDIO),
            "sendSms" to checkPermission(android.Manifest.permission.SEND_SMS),
            "readSms" to checkPermission(android.Manifest.permission.READ_SMS),
            "makeCalls" to checkPermission(android.Manifest.permission.CALL_PHONE),
            "readContacts" to checkPermission(android.Manifest.permission.READ_CONTACTS),
            "accessLocation" to checkPermission(android.Manifest.permission.ACCESS_FINE_LOCATION),
            "readStorage" to checkPermission(android.Manifest.permission.READ_EXTERNAL_STORAGE),
            "writeStorage" to checkPermission(android.Manifest.permission.WRITE_EXTERNAL_STORAGE),
            "camera" to checkPermission(android.Manifest.permission.CAMERA),
            "bluetooth" to checkPermission(android.Manifest.permission.BLUETOOTH),
            "bluetoothConnect" to checkPermission(android.Manifest.permission.BLUETOOTH_CONNECT)
        )
    }
    
    private fun checkPermission(permission: String): Boolean {
        return checkSelfPermission(permission) == android.content.pm.PackageManager.PERMISSION_GRANTED
    }
    
    private fun requestPermission(type: String, result: MethodChannel.Result) {
        val permissionMap = mapOf(
            "microphone" to android.Manifest.permission.RECORD_AUDIO,
            "sms" to android.Manifest.permission.SEND_SMS,
            "calls" to android.Manifest.permission.CALL_PHONE,
            "contacts" to android.Manifest.permission.READ_CONTACTS,
            "location" to android.Manifest.permission.ACCESS_FINE_LOCATION,
            "storage" to android.Manifest.permission.READ_EXTERNAL_STORAGE,
            "camera" to android.Manifest.permission.CAMERA,
            "bluetooth" to android.Manifest.permission.BLUETOOTH_CONNECT
        )
        
        val permission = permissionMap[type]
        if (permission != null) {
            requestPermissions(arrayOf(permission), 100)
            result.success(true)
        } else {
            result.success(false)
        }
    }
}
